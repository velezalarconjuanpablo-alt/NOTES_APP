import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_providers.dart';
import '../widgets/note_card.dart';
import 'editor_screen.dart';
class SearchScreen extends ConsumerWidget {
  const SearchScreen({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resultsAsync = ref.watch(searchResultsProvider);
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          onChanged: (value) => ref.read(searchQueryProvider.notifier).update(value),
          decoration: const InputDecoration(hintText: 'Buscar por titulo, contenido, carpeta o etiqueta...', border: InputBorder.none),
        ),
      ),
      body: resultsAsync.when(
        data: (notes) {
          if (notes.isEmpty) {
            return const Center(child: Text('Sin resultados'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final note = notes[i];
              return NoteCard(note: note, onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditorScreen(noteId: note.id))));
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error al buscar: $e')),
      ),
    );
  }
}
