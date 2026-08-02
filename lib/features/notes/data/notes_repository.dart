import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../core/database/database.dart';
abstract class NotesRepository {
  Stream<List<Note>> watchAll();
  Stream<List<Note>> watchByFolder(String folderId);
  Stream<List<Note>> watchFavorites();
  Stream<List<Note>> watchTrash();
  Future<Note?> getById(String id);
  Future<List<Note>> search(String query);
  Future<Note> create({String? folderId});
  Future<void> updateContent({required String id, required String title, required String content, required String plainText});
  Future<void> setFavorite(String id, bool value);
  Future<void> setPinned(String id, bool value);
  Future<void> setLocked(String id, bool value);
  Future<void> setColor(String id, int? colorValue);
  Future<void> moveToFolder(String id, String? folderId);
  Future<void> softDelete(String id);
  Future<void> restore(String id);
  Future<void> permanentlyDelete(String id);
  Future<void> purgeExpiredTrash({Duration retention = const Duration(days: 30)});
}
class DriftNotesRepository implements NotesRepository {
  DriftNotesRepository(this._db);
  final AppDatabase _db;
  static const _uuid = Uuid();
  @override
  Stream<List<Note>> watchAll() {
    return (_db.select(_db.notes)..where((n) => n.isDeleted.equals(false))..orderBy([(n) => OrderingTerm.desc(n.isPinned), (n) => OrderingTerm.desc(n.updatedAt)])).watch();
  }
  @override
  Stream<List<Note>> watchByFolder(String folderId) {
    return (_db.select(_db.notes)..where((n) => n.isDeleted.equals(false) & n.folderId.equals(folderId))..orderBy([(n) => OrderingTerm.desc(n.updatedAt)])).watch();
  }
  @override
  Stream<List<Note>> watchFavorites() {
    return (_db.select(_db.notes)..where((n) => n.isDeleted.equals(false) & n.isFavorite.equals(true))..orderBy([(n) => OrderingTerm.desc(n.updatedAt)])).watch();
  }
  @override
  Stream<List<Note>> watchTrash() {
    return (_db.select(_db.notes)..where((n) => n.isDeleted.equals(true))..orderBy([(n) => OrderingTerm.desc(n.deletedAt)])).watch();
  }
  @override
  Future<Note?> getById(String id) {
    return (_db.select(_db.notes)..where((n) => n.id.equals(id))).getSingleOrNull();
  }
  @override
  Future<List<Note>> search(String query) => _db.searchNotes(query);
  @override
  Future<Note> create({String? folderId}) async {
    final id = _uuid.v4();
    final now = DateTime.now();
    final companion = NotesCompanion.insert(id: id, folderId: Value(folderId), createdAt: Value(now), updatedAt: Value(now));
    await _db.into(_db.notes).insert(companion);
    return (await getById(id))!;
  }
  @override
  Future<void> updateContent({required String id, required String title, required String content, required String plainText}) {
    return (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(NotesCompanion(title: Value(title), content: Value(content), plainText: Value(plainText), updatedAt: Value(DateTime.now())));
  }
  @override
  Future<void> setFavorite(String id, bool value) => _patch(id, NotesCompanion(isFavorite: Value(value), updatedAt: Value(DateTime.now())));
  @override
  Future<void> setPinned(String id, bool value) => _patch(id, NotesCompanion(isPinned: Value(value), updatedAt: Value(DateTime.now())));
  @override
  Future<void> setLocked(String id, bool value) => _patch(id, NotesCompanion(isLocked: Value(value), updatedAt: Value(DateTime.now())));
  @override
  Future<void> setColor(String id, int? colorValue) => _patch(id, NotesCompanion(colorValue: Value(colorValue), updatedAt: Value(DateTime.now())));
  @override
  Future<void> moveToFolder(String id, String? folderId) => _patch(id, NotesCompanion(folderId: Value(folderId), updatedAt: Value(DateTime.now())));
  @override
  Future<void> softDelete(String id) => _patch(id, NotesCompanion(isDeleted: const Value(true), deletedAt: Value(DateTime.now())));
  @override
  Future<void> restore(String id) => _patch(id, const NotesCompanion(isDeleted: Value(false), deletedAt: Value(null)));
  @override
  Future<void> permanentlyDelete(String id) {
    return (_db.delete(_db.notes)..where((n) => n.id.equals(id))).go();
  }
  @override
  Future<void> purgeExpiredTrash({Duration retention = const Duration(days: 30)}) async {
    final cutoff = DateTime.now().subtract(retention);
    await (_db.delete(_db.notes)..where((n) => n.isDeleted.equals(true) & n.deletedAt.isSmallerThanValue(cutoff))).go();
  }
  Future<void> _patch(String id, NotesCompanion companion) {
    return (_db.update(_db.notes)..where((n) => n.id.equals(id))).write(companion);
  }
}
