import 'models.dart';

enum LibraryDisplay { list, compact, cards, covers, coversTitles }
enum LibrarySorting { title, progress, total, rating, priority, lastUpdated }
enum LibraryCoverFilter { all, hasCover, missingCover }

/// Efficient, UI-independent native Library filtering. Does not modify cloud data.
abstract final class LibraryFilters {
  static List<MediaTitle> apply(
    List<MediaTitle> library, {
    String query = '',
    String status = 'all',
    String category = 'all',
    String priority = 'all',
    LibraryCoverFilter covers = LibraryCoverFilter.all,
    LibrarySorting sorting = LibrarySorting.title,
    bool descending = false,
  }) {
    final needle = query.trim().toLowerCase();
    final result = library.where((title) {
      if (needle.isNotEmpty &&
          !title.title.toLowerCase().contains(needle) &&
          !title.tags.any((tag) => tag.toLowerCase().contains(needle))) {
        return false;
      }
      if (status != 'all' && title.status != status) return false;
      if (category != 'all' && title.categoryId != category) return false;
      if (priority != 'all' && title.priority != priority) return false;
      if (covers == LibraryCoverFilter.hasCover && title.cover.isEmpty) return false;
      if (covers == LibraryCoverFilter.missingCover && title.cover.isNotEmpty) return false;
      return true;
    }).toList(growable: true);
    int compare(MediaTitle a, MediaTitle b) {
      final primary = switch (sorting) {
        LibrarySorting.title => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        LibrarySorting.progress => a.progress.compareTo(b.progress),
        LibrarySorting.total => a.total.compareTo(b.total),
        LibrarySorting.rating => a.rating.compareTo(b.rating),
        LibrarySorting.priority => _priority(a.priority).compareTo(_priority(b.priority)),
        LibrarySorting.lastUpdated =>
          _modified(a.raw).compareTo(_modified(b.raw)),
      };
      final value = descending ? -primary : primary;
      if (value != 0) return value;
      return a.title.toLowerCase().compareTo(b.title.toLowerCase());
    }
    result.sort(compare);
    return result;
  }

  static int _priority(String value) => switch (value.toLowerCase()) {
    'high' => 3,
    'medium' => 2,
    'low' => 1,
    _ => 0,
  };

  static int _modified(Map<String, dynamic> value) {
    final stamp = value['updatedAt'] ?? value['modifiedAt'] ?? value['lastUpdated'] ?? 0;
    if (stamp is num) return stamp.toInt();
    return int.tryParse(stamp.toString()) ?? DateTime.tryParse(stamp.toString())?.millisecondsSinceEpoch ?? 0;
  }
}
