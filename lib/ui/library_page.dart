import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/library_filters.dart';
import '../data/library_preferences.dart';
import '../data/mediaflow_repository.dart';
import '../data/models.dart';
import 'design.dart';

/// Native Library workspace. All display/filter settings are device-local;
/// the only cloud-backed mutations are explicitly staged priority edits.
class LibraryPage extends StatefulWidget {
  final MediaFlowRepository repo;
  final void Function(MediaTitle) openTitle;
  const LibraryPage({super.key, required this.repo, required this.openTitle});
  @override State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  final search = TextEditingController();
  String status = 'all', category = 'all', priority = 'all';
  LibrarySorting sorting = LibrarySorting.title;
  LibraryCoverFilter covers = LibraryCoverFilter.all;
  LibraryDisplay display = LibraryDisplay.list;
  bool descending = false, filtersExpanded = false, selecting = false;
  final Set<String> selected = {};
  late LibraryPreferences preferences;

  @override
  void initState() {
    super.initState();
    preferences = LibraryPreferences(widget.repo.ownerId);
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final saved = await preferences.read();
    if (!mounted) return;
    setState(() {
      display = LibraryDisplay.values.firstWhere((v) => v.name == saved['display'], orElse: () => LibraryDisplay.list);
      sorting = LibrarySorting.values.firstWhere((v) => v.name == saved['sorting'], orElse: () => LibrarySorting.title);
      covers = LibraryCoverFilter.values.firstWhere((v) => v.name == saved['covers'], orElse: () => LibraryCoverFilter.all);
      descending = saved['descending'] == true;
      filtersExpanded = saved['filtersExpanded'] == true;
    });
  }

  Future<void> _savePreferences() => preferences.write({
    'display': display.name, 'sorting': sorting.name, 'covers': covers.name,
    'descending': descending, 'filtersExpanded': filtersExpanded,
  });

  @override
  void dispose() { search.dispose(); super.dispose(); }

  void _switchSelection() => setState(() {
    selecting = !selecting;
    if (!selecting) selected.clear();
  });

  Future<void> _bulkPriority() async {
    if (selected.isEmpty) return;
    final value = await showModalBottomSheet<String>(context: context,
      showDragHandle: true, builder: (ctx) => SafeArea(child: Padding(
        padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Set priority for ${selected.length} selected titles', style: Theme.of(ctx).textTheme.titleMedium),
          const SizedBox(height: 10),
          for (final value in ['high', 'medium', 'low'])
            ListTile(title: Text('${value[0].toUpperCase()}${value.substring(1)} priority'),
              leading: Icon(value == 'high' ? Icons.flag : value == 'medium' ? Icons.flag_outlined : Icons.low_priority),
              onTap: () => Navigator.pop(ctx, value)),
        ]),
      )));
    if (value == null || !mounted) return;
    try {
      final count = await widget.repo.stageBulkPriority(Set<String>.of(selected), value);
      if (!mounted) return;
      setState(() { selected.clear(); selecting = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$count priority edits staged locally. Upload from Settings to sync.')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No changes staged: $e')));
    }
  }

  void _activate(MediaTitle title) {
    if (selecting) {
      setState(() { if (!selected.add(title.id)) selected.remove(title.id); });
    } else {
      widget.openTitle(title);
    }
  }

  Widget _menu<T>({required String label, required T value,
      required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged,
      double width = 150}) => SizedBox(width: width,
    child: DropdownButtonFormField<T>(key: ValueKey('$label-$value'),
      initialValue: value, isExpanded: true,
      decoration: InputDecoration(labelText: label, isDense: true),
      items: items, onChanged: onChanged));

  static String _displayLabel(LibraryDisplay view) => switch (view) {
    LibraryDisplay.list => 'List',
    LibraryDisplay.compact => 'Compact',
    LibraryDisplay.cards => 'Cards',
    LibraryDisplay.covers => 'Covers',
    LibraryDisplay.coversTitles => 'Covers+Titles',
  };

  static IconData _displayIcon(LibraryDisplay view) => switch (view) {
    LibraryDisplay.list => Icons.view_list,
    LibraryDisplay.compact => Icons.view_headline,
    LibraryDisplay.cards => Icons.view_module,
    LibraryDisplay.covers => Icons.grid_on,
    LibraryDisplay.coversTitles => Icons.view_comfy,
  };

  Widget _tools(List<MediaTitle> all, List<MediaTitle> visible, MediaWorkspace space) {
    final statuses = all.map((t) => t.status).toSet().toList()..sort();
    return Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 8), child: Column(
      crossAxisAlignment: CrossAxisAlignment.start, children: [
      ScreenHeader(label: 'Library', title: 'Every story, one place',
        subtitle: '${NumberFormat.decimalPattern().format(all.length)} titles · ${NumberFormat.decimalPattern().format(visible.length)} shown',
        icon: Icons.library_books_outlined),
      const SizedBox(height: 9),
      TextField(controller: search, onChanged: (_) => setState(() {}),
        decoration: InputDecoration(prefixIcon: const Icon(Icons.search),
          hintText: 'Search titles and tags',
          suffixIcon: search.text.isEmpty ? null : IconButton(icon: const Icon(Icons.clear),
            onPressed: () { search.clear(); setState(() {}); }))),
      const SizedBox(height: 8),
      Row(children: [
        OutlinedButton.icon(onPressed: () { setState(() => filtersExpanded = !filtersExpanded); _savePreferences(); },
          icon: Icon(filtersExpanded ? Icons.filter_list_off : Icons.filter_list),
          label: Text(filtersExpanded ? 'Hide filters' : 'Filters')),
        const SizedBox(width: 8),
        OutlinedButton.icon(onPressed: _switchSelection,
          icon: Icon(selecting ? Icons.close : Icons.checklist),
          label: Text(selecting ? 'Cancel selection' : 'Select')),
        const Spacer(),
        if (selecting) Text('${selected.length} selected', style: Theme.of(context).textTheme.labelSmall),
      ]),
      if (filtersExpanded) ...[
        const SizedBox(height: 11),
        Wrap(spacing: 8, runSpacing: 10, children: [
          _menu<String>(label: 'Status', value: status, width: 152,
            items: [const DropdownMenuItem(value: 'all', child: Text('All statuses')),
              ...statuses.map((s) => DropdownMenuItem(value: s, child: Text(s, overflow: TextOverflow.ellipsis)))],
            onChanged: (v) => setState(() => status = v ?? 'all')),
          _menu<String>(label: 'Category', value: category, width: 170,
            items: [const DropdownMenuItem(value: 'all', child: Text('All categories')),
              ...space.categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name, overflow: TextOverflow.ellipsis)))],
            onChanged: (v) => setState(() => category = v ?? 'all')),
          _menu<String>(label: 'Priority', value: priority, width: 130,
            items: const [DropdownMenuItem(value: 'all', child: Text('Any priority')),
              DropdownMenuItem(value: 'high', child: Text('High')),
              DropdownMenuItem(value: 'medium', child: Text('Medium')),
              DropdownMenuItem(value: 'low', child: Text('Low'))],
            onChanged: (v) => setState(() => priority = v ?? 'all')),
          _menu<LibraryCoverFilter>(label: 'Cover', value: covers, width: 142,
            items: const [DropdownMenuItem(value: LibraryCoverFilter.all, child: Text('All covers')),
              DropdownMenuItem(value: LibraryCoverFilter.hasCover, child: Text('Has cover')),
              DropdownMenuItem(value: LibraryCoverFilter.missingCover, child: Text('Missing cover'))],
            onChanged: (v) { setState(() => covers = v ?? LibraryCoverFilter.all); _savePreferences(); }),
          _menu<LibrarySorting>(label: 'Sort by', value: sorting, width: 158,
            items: LibrarySorting.values.map((s) => DropdownMenuItem(value: s,
              child: Text(s.name == 'lastUpdated' ? 'Last updated' : '${s.name[0].toUpperCase()}${s.name.substring(1)}'))).toList(),
            onChanged: (v) { setState(() => sorting = v ?? LibrarySorting.title); _savePreferences(); }),
          IconButton.filledTonal(tooltip: descending ? 'Descending' : 'Ascending',
            onPressed: () { setState(() => descending = !descending); _savePreferences(); },
            icon: Icon(descending ? Icons.arrow_downward : Icons.arrow_upward)),
          TextButton.icon(onPressed: () { setState(() { status = category = priority = 'all'; covers = LibraryCoverFilter.all; sorting = LibrarySorting.title; descending = false; }); _savePreferences(); },
            icon: const Icon(Icons.restart_alt), label: const Text('Reset')),
        ]),
      ],
      const SizedBox(height: 7),
      SizedBox(height: 40, child: ListView(scrollDirection: Axis.horizontal, children: [
        for (final mode in LibraryDisplay.values)
          Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(
            avatar: Icon(_displayIcon(mode), size: 16),
            label: Text(_displayLabel(mode)), selected: display == mode,
            onSelected: (_) { setState(() => display = mode); _savePreferences(); })),
      ])),
      if (selecting) ...[
        const SizedBox(height: 6),
        Wrap(spacing: 7, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: [
          OutlinedButton(onPressed: () => setState(() => selected.addAll(visible.map((t) => t.id))),
            child: const Text('Select visible')),
          TextButton(onPressed: () => setState(selected.clear), child: const Text('Clear')),
          FilledButton.icon(onPressed: selected.isEmpty ? null : _bulkPriority,
            icon: const Icon(Icons.flag_outlined, size: 17), label: const Text('Set priority')),
        ]),
      ],
    ]));
  }

  @override
  Widget build(BuildContext context) {
    final space = widget.repo.workspace;
    final all = space.titles;
    final visible = LibraryFilters.apply(all, query: search.text, status: status,
      category: category, priority: priority, covers: covers,
      sorting: sorting, descending: descending);
    final available = all.map((t) => t.id).toSet();
    selected.removeWhere((id) => !available.contains(id));
    final gridMode = display == LibraryDisplay.cards || display == LibraryDisplay.covers || display == LibraryDisplay.coversTitles;
    return Column(children: [
      _tools(all, visible, space),
      Expanded(child: visible.isEmpty ? const Center(child: Text('No titles match your filters.')) :
        gridMode ? LayoutBuilder(builder: (ctx, constraints) {
          final perRow = (constraints.maxWidth / (display == LibraryDisplay.cards ? 205 : 145)).floor().clamp(2, 8);
          final aspect = display == LibraryDisplay.covers ? .70 : display == LibraryDisplay.cards ? .83 : .63;
          return GridView.builder(padding: const EdgeInsets.all(12),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: perRow, mainAxisSpacing: 8, crossAxisSpacing: 8, childAspectRatio: aspect),
            itemCount: visible.length, itemBuilder: (ctx, i) => _coverTile(visible[i]));
        }) : ListView.builder(padding: const EdgeInsets.fromLTRB(12, 5, 12, 22),
          itemCount: visible.length, itemExtent: display == LibraryDisplay.compact ? 67 : 100,
          itemBuilder: (ctx, i) => _listTile(visible[i])),
      ),
    ]);
  }

  Widget _listTile(MediaTitle t) {
    final compact = display == LibraryDisplay.compact;
    return Padding(padding: const EdgeInsets.only(bottom: 7), child: MfCard(
      padding: EdgeInsets.symmetric(horizontal: 9, vertical: compact ? 4 : 8),
      child: InkWell(onTap: () => _activate(t), child: Row(children: [
        if (selecting) Checkbox(value: selected.contains(t.id), onChanged: (_) => _activate(t)),
        TitleCover(t.cover, width: compact ? 37 : 54, height: compact ? 49 : 74),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(t.title, maxLines: compact ? 1 : 2, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
          const SizedBox(height: 4),
          Text('${widget.repo.workspace.categoryFor(t.categoryId)?.name ?? 'Category'} · ${t.progress}${t.total > 0 ? '/${t.total}' : ''} · ${t.priority}',
            maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall),
          if (!compact) ...[
            const SizedBox(height: 4),
            Text(t.status, style: TextStyle(fontSize: 11, color: statusColor(t.status, Theme.of(context).colorScheme.primary))),
          ],
        ])),
        if (selected.contains(t.id)) Icon(Icons.check_circle, color: Theme.of(context).colorScheme.primary)
        else if (!selecting) const Icon(Icons.chevron_right_rounded, size: 18),
      ])),
    ));
  }

  Widget _coverTile(MediaTitle t) {
    final onlyCover = display == LibraryDisplay.covers;
    return MfCard(padding: const EdgeInsets.all(6), child: InkWell(
      onTap: () => _activate(t), child: Stack(children: [
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(10),
            child: FittedBox(fit: BoxFit.cover, child: TitleCover(t.cover, width: 120, height: 170)))),
          if (!onlyCover) ...[
            const SizedBox(height: 5),
            Text(t.title, maxLines: 2, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
            if (display == LibraryDisplay.cards) Text('${t.progress}${t.total > 0 ? '/${t.total}' : ''} · ${t.status}',
              maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.labelSmall),
          ],
        ]),
        if (selecting) Positioned(right: 1, top: 1, child: CircleAvatar(radius: 14,
          child: Icon(selected.contains(t.id) ? Icons.check : Icons.circle_outlined, size: 16))),
      ]),
    ));
  }
}
