import 'mediaflow_snapshot.dart';

class MediaTitle {
  final Map<String, dynamic> raw;
  const MediaTitle(this.raw);
  String get id => plain(raw['id']);
  String get title => plain(raw['title'], 'Untitled');
  String get cover => plain(raw['coverUrl']);
  String get categoryId => plain(raw['categoryId']);
  String get status => plain(raw['status'], 'planned');
  String get priority => plain(raw['priority'], 'medium');
  int get progress => numeric(raw['progress']).toInt();
  int get total => numeric(raw['total']).toInt();
  String get description => plain(raw['description']);
  double get rating => numeric(raw['rating']);
  List<String> get tags => raw['tags'] is List
      ? (raw['tags'] as List).map((e) => e.toString()).toList()
      : <String>[];
}

class MediaCategory {
  final Map<String, dynamic> raw;
  const MediaCategory(this.raw);
  String get id => plain(raw['id']);
  String get name => plain(raw['name'], 'Category');
  String get iconUrl => plain(raw['iconUrl']);
  String get icon => plain(raw['icon']);
}

class MediaCollection {
  final Map<String, dynamic> raw;
  const MediaCollection(this.raw);
  String get id => plain(raw['id']);
  String get title => plain(raw['title'], 'Untitled Collection');
  String get description => plain(raw['description']);
  String get cover => plain(raw['coverUrl']);
  List<String> get titleIds => raw['titleIds'] is List
      ? (raw['titleIds'] as List).map((e) => e.toString()).toList()
      : [];
}

class MediaSession {
  final Map<String, dynamic> raw;
  const MediaSession(this.raw);
  String get id => plain(raw['id']);
  String get categoryId => plain(raw['categoryId']);
  String get note => plain(raw['note']);
  String get date => plain(raw['date']);
  String get unit => plain(raw['unit']);
  String get title => plain(raw['title'], 'Consumption session');
  int get amount => numeric(raw['actualAmount']).toInt();
  int get minutes => numeric(raw['minutes']).toInt();
  int get timestamp => numeric(raw['timestamp']).toInt();
}

class MediaWorkspace {
  final Map<String, dynamic> json;
  MediaWorkspace(this.json);
  late final List<MediaTitle> titles =
      asObjects(json['library']).map(MediaTitle.new).toList();
  late final List<MediaCategory> categories =
      asObjects(json['categories']).map(MediaCategory.new).toList();
  late final List<MediaCollection> collections =
      asObjects(json['collections']).map(MediaCollection.new).toList();
  late final List<MediaSession> sessions =
      asObjects(json['sessions']).map(MediaSession.new).toList();
  Map<String, dynamic> get settings => asObject(json['settings']);
  Map<String, dynamic> get orderPlan => asObject(json['orderPlan']);
  List<String> get orderedIds => orderPlan['titleIds'] is List
      ? (orderPlan['titleIds'] as List).map((e) => e.toString()).toList()
      : <String>[];
  MediaCategory? categoryFor(String categoryId) {
    for (final category in categories) {
      if (category.id == categoryId) return category;
    }
    return null;
  }
}
