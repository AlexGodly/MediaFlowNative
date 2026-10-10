import 'package:flutter_test/flutter_test.dart';
import 'package:mediaflow_native/data/library_filters.dart';
import 'package:mediaflow_native/data/models.dart';

void main() {
  final library = [
    MediaTitle({'id':'a','title':'Blue Horizon','status':'active','priority':'high',
      'categoryId':'anime','coverUrl':'https://cdn.example/a.jpg','tags':['mecha'],
      'progress':11,'total':12,'rating':9.5,'updatedAt':50}),
    MediaTitle({'id':'b','title':'Amber Heart','status':'completed','priority':'low',
      'categoryId':'books','coverUrl':'','tags':['romance'],
      'progress':1,'total':1,'rating':8,'updatedAt':20}),
    MediaTitle({'id':'c','title':'Copper Road','status':'active','priority':'medium',
      'categoryId':'anime','coverUrl':'','tags':['action'],
      'progress':3,'total':24,'rating':5,'updatedAt':40}),
  ];

  test('combined search, category, status, priority and cover filters', () {
    expect(LibraryFilters.apply(library, query:'mecha', category:'anime',
      status:'active', priority:'high', covers:LibraryCoverFilter.hasCover)
      .map((t)=>t.id), ['a']);
    expect(LibraryFilters.apply(library, covers:LibraryCoverFilter.missingCover)
      .map((t)=>t.id), ['b','c']);
    expect(LibraryFilters.apply(library,query:'nonexistent'),isEmpty);
  });
  test('sort fields preserve source order and content', () {
    expect(LibraryFilters.apply(library, sorting:LibrarySorting.progress,descending:true)
      .map((t)=>t.id), ['a','c','b']);
    expect(LibraryFilters.apply(library, sorting:LibrarySorting.priority,descending:true)
      .map((t)=>t.id), ['a','c','b']);
    expect(LibraryFilters.apply(library, sorting:LibrarySorting.rating)
      .map((t)=>t.id), ['c','b','a']);
    expect(library.map((t)=>t.id), ['a','b','c']);
  });
  test('large library filtering returns correct subset', () {
    final many = List.generate(30000, (i)=>MediaTitle({
      'id':'id-$i','title':'Title $i','status':'active',
      'priority': i % 10 == 0 ? 'high' : 'medium',
      'categoryId': i.isEven ? 'anime' : 'books',
      'coverUrl': i.isEven ? 'https://example.com/$i.jpg' : '',
      'progress':i%15,'total':24,
    }));
    final result = LibraryFilters.apply(many, category:'anime',
      priority:'high',covers:LibraryCoverFilter.hasCover,
      sorting:LibrarySorting.progress,descending:true);
    expect(result.length,3000);
    expect(result.every((t)=>t.categoryId=='anime' && t.priority=='high'),isTrue);
  });
}
