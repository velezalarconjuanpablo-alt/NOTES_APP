import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/database/database.dart';
import '../../../../core/database/database_provider.dart';
import '../../data/notes_repository.dart';

part 'notes_providers.g.dart';

@Riverpod(keepAlive: true)
NotesRepository notesRepository(NotesRepositoryRef ref) {
  final db = ref.watch(appDatabaseProvider);
  return DriftNotesRepository(db);
}

@riverpod
Stream<List<Note>> allNotes(AllNotesRef ref) {
  return ref.watch(notesRepositoryProvider).watchAll();
}

@riverpod
Stream<List<Note>> favoriteNotes(FavoriteNotesRef ref) {
  return ref.watch(notesRepositoryProvider).watchFavorites();
}

@riverpod
Stream<List<Note>> trashNotes(TrashNotesRef ref) {
  return ref.watch(notesRepositoryProvider).watchTrash();
}

@riverpod
Stream<List<Note>> notesInFolder(NotesInFolderRef ref, String folderId) {
  return ref.watch(notesRepositoryProvider).watchByFolder(folderId);
}

@riverpod
class SearchQuery extends _$SearchQuery {
  @override
  String build() => '';

  void update(String value) => state = value;
}

@riverpod
Future<List<Note>> searchResults(SearchResultsRef ref) async {
  final query = ref.watch(searchQueryProvider);
  if (query.trim().isEmpty) return [];
  return ref.watch(notesRepositoryProvider).search(query);
}

@riverpod
class GroupedNotes extends _$GroupedNotes {
  @override
  Map<String, List<Note>> build() {
    final notes = ref.watch(allNotesProvider).valueOrNull ?? [];
    return _group(notes);
  }

  Map<String, List<Note>> _group(List<Note> notes) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final result = <String, List<Note>>{};

    for (final note in notes) {
      if (note.isPinned) {
        result.putIfAbsent('Fijadas', () => []).add(note);
        continue;
      }
      final d = note.updatedAt;
      final noteDay = DateTime(d.year, d.month, d.day);
      final diff = today.difference(noteDay).inDays;

      final String bucket;
      if (diff == 0) {
        bucket = 'Hoy';
      } else if (diff == 1) {
        bucket = 'Ayer';
      } else if (diff <= 7) {
        bucket = 'Ultimos 7 dias';
      } else if (diff <= 30) {
        bucket = 'Ultimos 30 dias';
      } else if (d.year == now.year) {
        bucket = _monthName(d.month);
      } else {
        bucket = d.year.toString();
      }
      result.putIfAbsent(bucket, () => []).add(note);
    }
    return result;
  }

  static String _monthName(int month) {
    const names = [
      'Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio',
      'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre',
    ];
    return names[month - 1];
  }
}
