import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'database.g.dart';

class Folders extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 60)();
  IntColumn get colorValue => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 40).unique()();

  @override
  Set<Column> get primaryKey => {id};
}

class Notes extends Table {
  TextColumn get id => text()();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get content => text().withDefault(const Constant(''))();
  TextColumn get plainText => text().withDefault(const Constant(''))();

  TextColumn get folderId =>
      text().nullable().references(Folders, #id, onDelete: KeyAction.setNull)();

  IntColumn get colorValue => integer().nullable()();

  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  BoolColumn get isPinned => boolean().withDefault(const Constant(false))();
  BoolColumn get isLocked => boolean().withDefault(const Constant(false))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get deletedAt => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class NoteTags extends Table {
  TextColumn get noteId =>
      text().references(Notes, #id, onDelete: KeyAction.cascade)();
  TextColumn get tagId =>
      text().references(Tags, #id, onDelete: KeyAction.cascade)();

  @override
  Set<Column> get primaryKey => {noteId, tagId};
}

@DriftDatabase(tables: [Folders, Tags, Notes, NoteTags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createFtsTable(this);
          await _createFtsTriggers(this);
        },
        onUpgrade: (m, from, to) async {},
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<List<Note>> searchNotes(String query) async {
    if (query.trim().isEmpty) return [];
    final sanitized = query.replaceAll('"', '""');
    final rows = await customSelect(
      'SELECT notes.* FROM notes_fts '
      'JOIN notes ON notes.id = notes_fts.id '
      'WHERE notes_fts MATCH ? AND notes.is_deleted = 0 '
      'ORDER BY rank LIMIT 200',
      variables: [Variable.withString('"$sanitized"*')],
      readsFrom: {notes},
    ).get();
    return rows.map((row) => notes.map(row.data)).toList();
  }
}

Future<void> _createFtsTable(AppDatabase db) async {
  await db.customStatement('''
    CREATE VIRTUAL TABLE IF NOT EXISTS notes_fts USING fts5(
      id UNINDEXED,
      title,
      plain_text,
      content='notes',
      content_rowid='rowid'
    );
  ''');
}

Future<void> _createFtsTriggers(AppDatabase db) async {
  await db.customStatement('''
    CREATE TRIGGER IF NOT EXISTS notes_ai AFTER INSERT ON notes BEGIN
      INSERT INTO notes_fts(rowid, id, title, plain_text)
      VALUES (new.rowid, new.id, new.title, new.plain_text);
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER IF NOT EXISTS notes_ad AFTER DELETE ON notes BEGIN
      INSERT INTO notes_fts(notes_fts, rowid, id, title, plain_text)
      VALUES ('delete', old.rowid, old.id, old.title, old.plain_text);
    END;
  ''');
  await db.customStatement('''
    CREATE TRIGGER IF NOT EXISTS notes_au AFTER UPDATE ON notes BEGIN
      INSERT INTO notes_fts(notes_fts, rowid, id, title, plain_text)
      VALUES ('delete', old.rowid, old.id, old.title, old.plain_text);
      INSERT INTO notes_fts(rowid, id, title, plain_text)
      VALUES (new.rowid, new.id, new.title, new.plain_text);
    END;
  ''');
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'notes.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
