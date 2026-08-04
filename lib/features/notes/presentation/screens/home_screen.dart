import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/note_navigation.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_card.dart';
import 'editor_screen.dart';
import 'search_screen.dart';
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});
  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}
class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _railIndex = 0;
  static const _railDestinations = [
    _NavItem('Todas las notas', Icons.notes_rounded),
    _NavItem('Carpetas', Icons.folder_rounded),
    _NavItem('Favoritos', Icons.star_rounded),
    _NavItem('Etiquetas', Icons.label_rounded),
    _NavItem('Papelera', Icons.delete_rounded),
    _NavItem('Configuracion', Icons.settings_rounded),
  ];
  @override
  Widget build(BuildContext context) {
    final isLarge = AppBreakpoints.isLarge(context);
    return isLarge ? _buildLargeLayout(context) : _buildCompactLayout(context);
  }
  Widget _buildLargeLayout(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _railIndex,
            onDestinationSelected: (i) => setState(() => _railIndex = i),
            extended: MediaQuery.sizeOf(context).width >= 1000,
            leading: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Icon(Icons.edit_note_rounded, size: 32)),
            destinations: _railDestinations.map((d) => NavigationRailDestination(icon: Icon(d.icon), label: Text(d.label))).toList(),
          ),
          const VerticalDivider(width: 1),
          Expanded(child: _NotesListPane(sectionIndex: _railIndex)),
        ],
      ),
      floatingActionButton: _railIndex == 0 ? const _NewNoteFab() : null,
    );
  }
  Widget _buildCompactLayout(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          IconButton(icon: const Icon(Icons.search_rounded), tooltip: 'Buscar', onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SearchScreen()))),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (i) => setState(() => _railIndex = i),
            itemBuilder: (_) => _railDestinations.asMap().entries.map((e) => PopupMenuItem(value: e.key, child: Row(children: [Icon(e.value.icon, size: 20), const SizedBox(width: 12), Text(e.value.label)]))).toList(),
          ),
        ],
      ),
      body: _NotesListPane(sectionIndex: _railIndex),
      floatingActionButton: _railIndex == 0 ? const _NewNoteFab() : null,
    );
  }
}
class _NewNoteFab extends ConsumerWidget {
  const _NewNoteFab();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FloatingActionButton(
      onPressed: () async {
        final repo = ref.read(notesRepositoryProvider);
        final note = await repo.create();
        if (context.mounted) {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditorScreen(noteId: note.id)));
        }
      },
      child: const Icon(Icons.add_rounded),
    );
  }
}
class _NavItem {
  const _NavItem(this.label, this.icon);
  final String label;
  final IconData icon;
}
class _NotesListPane extends ConsumerWidget {
  const _NotesListPane({required this.sectionIndex});
  final int sectionIndex;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (sectionIndex != 0) {
      return const Center(child: Text('Proximamente'));
    }
    final grouped = ref.watch(groupedNotesProvider);
    if (grouped.isEmpty) {
      return const _EmptyState();
    }
    const order = ['Fijadas', 'Hoy', 'Ayer', 'Ultimos 7 dias', 'Ultimos 30 dias'];
    final keys = grouped.keys.toList()..sort((a, b) {
      final ia = order.indexOf(a);
      final ib = order.indexOf(b);
      if (ia != -1 && ib != -1) return ia.compareTo(ib);
      if (ia != -1) return -1;
      if (ib != -1) return 1;
      return 0;
    });
    return CustomScrollView(
      slivers: [
        for (final key in keys) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              child: Text(key, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700, color: Theme.of(context).colorScheme.outline)),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList.separated(
              itemCount: grouped[key]!.length,
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final note = grouped[key]![i];
                return NoteCard(note: note, onTap: () => openNote(context, ref, note));
              },
            ),
          ),
        ],
        const SliverToBoxAdapter(child: SizedBox(height: 80)),
      ],
    );
  }
}
class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.edit_note_rounded, size: 64, color: scheme.outlineVariant),
          const SizedBox(height: 12),
          Text('Aun no tienes notas', style: TextStyle(color: scheme.outline)),
          const SizedBox(height: 4),
          Text('Toca + para crear la primera', style: TextStyle(color: scheme.outline, fontSize: 13)),
        ],
      ),
    );
  }
}
