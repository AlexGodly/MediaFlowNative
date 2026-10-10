import 'package:flutter_test/flutter_test.dart';
import 'package:mediaflow_native/data/order_mutations.dart';

void main() {
  final source = <String,dynamic>{
    'titleIds': ['a', 'b'],
    'collectionAssignments': [{'id': 'ca', 'collectionId': 'c1'}],
    'categoryQueues': {'anime': ['c:ca', 't:a', 't:b']},
    'v288QueueView': {'view': 'list'},
    'modifiedAt': 100,
  };
  test('reorder direct titles without destroying assigned Collections', () {
    final next = OrderMutations.changeDirectTitles(source, ['b', 'a'], {'a', 'b'}, modifiedAt: 500);
    expect(next['titleIds'], ['b', 'a']);
    expect(next['collectionAssignments'], source['collectionAssignments']);
    expect(next['categoryQueues'], source['categoryQueues']);
    expect(next['modifiedAt'], 500);
    expect(source['titleIds'], ['a', 'b']);
  });
  test('missing Library ids cannot enter Personal Order', () {
    expect(() => OrderMutations.changeDirectTitles(source, ['ghost'], {'a', 'b'}), throwsStateError);
  });
  test('duplicate direct ids removed without duplicating Library records', () {
    final next = OrderMutations.changeDirectTitles(source, ['a', 'a', 'b'], {'a', 'b'});
    expect(next['titleIds'], ['a', 'b']);
  });
  test('cloud order divergence rejects write before patching', () {
    final remote = {'orderPlan': {...source, 'titleIds': ['b', 'a']}};
    expect(() => OrderMutations.validateRemote(remote, source), throwsStateError);
  });
  test('order patch does not change Library, sessions, or xpLedger', () {
    final state = <String,dynamic>{'orderPlan': source,
      'library': [{'id':'a'}, {'id':'b'}],
      'sessions': [{'id':'s1'}], 'xpLedger': {'libraryAdditions': {'a':25}}};
    final next = OrderMutations.changeDirectTitles(source, ['b','a'], {'a','b'});
    OrderMutations.apply(state, next);
    expect((state['library'] as List).length, 2);
    expect((state['sessions'] as List).single['id'], 's1');
    expect(state['xpLedger'], {'libraryAdditions': {'a':25}});
  });
}
