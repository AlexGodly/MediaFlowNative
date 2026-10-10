import 'package:flutter_test/flutter_test.dart';
import 'package:mediaflow_native/data/mediaflow_snapshot.dart';
import 'package:mediaflow_native/data/models.dart';

void main() {
  final sample = <String, dynamic>{
    'library': [
      {'id':'a1','title':'Sample Anime','coverUrl':'https://example.com/a.jpg',
        'categoryId':'anime','status':'watching','priority':'high','progress':12,'total':24,
        'futureV999Field':{'keep':[1,2,3]}},
    ],
    'categories':[{'id':'anime','name':'Anime'}],
    'sessions':[{'id':'h1','minutes':24,'actualAmount':1}],
    'settings':{'theme':'dark','v999Unknown':true},
    'xpLedger':{'libraryAdditions':{'a1':120}},
    'collections':[{'id':'c1','title':'Favorites','titleIds':['a1']}],
    'orderPlan':{'titleIds':['a1']},
  };

  test('gzip JSONB wrapper compatible with v372 retains all fields', () {
    final compressed=MediaFlowSnapshotCodec.encodeCloud({
      ...sample,'padding':List.generate(300000,(i)=>i%10).join(),
    });
    expect(compressed['__mediaflowCompressed'],'gzip');
    final decoded=MediaFlowSnapshotCodec.decodeCloud(compressed);
    expect(decoded['xpLedger'],sample['xpLedger']);
    expect((decoded['library'] as List).first['futureV999Field'],{'keep':[1,2,3]});
  });

  test('small uncompressed snapshots round-trip', () {
    expect(MediaFlowSnapshotCodec.decodeCloud(MediaFlowSnapshotCodec.encodeCloud(sample)),sample);
  });

  test('local compressed cache restores full state', () {
    expect(MediaFlowSnapshotCodec.decodeLocal(MediaFlowSnapshotCodec.encodeLocal(sample)),sample);
  });

  test('read-only models understand title, category and order', () {
    final model=MediaWorkspace(sample);
    expect(model.titles.single.progress,12);
    expect(model.titles.single.priority,'high');
    expect(model.categoryFor('anime')?.name,'Anime');
    expect(model.collections.single.titleIds,['a1']);
    expect(model.orderedIds,['a1']);
  });

  test('broken gzip does not silently replace Library data', () {
    expect(()=>MediaFlowSnapshotCodec.decodeCloud({'__mediaflowCompressed':'gzip','data':'abc'}),throwsA(isA<Exception>()));
  });
}
