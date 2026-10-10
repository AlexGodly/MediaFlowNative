import 'package:flutter_test/flutter_test.dart';
import 'package:mediaflow_native/data/collection_mutations.dart';

void main(){
  test('new Collection follows the v372 order, timestamps, and fields', () {
    final c=CollectionMutations.create('c2','  New Collection  ',titleIds:['a','b','a']);
    expect(c['title'],'New Collection');
    expect(c['titleIds'],['a','b']);
    expect(c['order'],['a','b']);
    expect(c['autoBackground'],true);
    expect(c['createdAt'],isA<int>());
  });
  test('changing Collection order does not remove unknown future properties', () {
    final old=CollectionMutations.create('c1','Original',titleIds:['a','b'])..['v999New']={'keep':true};
    final next=CollectionMutations.revise(old,titleIds:['b','a']);
    expect(next['order'],['b','a']);
    expect(next['v999New'],{'keep':true});
  });
  test('Collection deletion creates v372 tombstone without deleting Library', () {
    final state=<String,dynamic>{'library':[{'id':'a'}],
      'collections':[CollectionMutations.create('c1','One',titleIds:['a'])],
      'collectionTombstones':[]};
    CollectionMutations.apply(state,'c1',null);
    expect((state['collections'] as List),isEmpty);
    expect((state['library'] as List).length,1);
    expect((state['collectionTombstones'] as List).single['id'],'c1');
  });
  test('concurrent website changes reject stale Collection update', () {
    final original=CollectionMutations.create('c1','Original');
    final remote=<String,dynamic>{'collections':[CollectionMutations.revise(original,title:'Website')]};
    expect(()=>CollectionMutations.verifyBaseline(remote,'c1',original),throwsStateError);
  });
  test('independent additions and safe concurrent unchanged update', () {
    final original=CollectionMutations.create('c1','Original');
    final remote=<String,dynamic>{'collections':[original],'collectionTombstones':[],'library':[{'id':'a'}]};
    CollectionMutations.verifyBaseline(remote,'c1',original);
    CollectionMutations.apply(remote,'c2',CollectionMutations.create('c2','New'));
    expect((remote['collections'] as List).length,2);
    expect((remote['library'] as List).length,1);
  });
}
