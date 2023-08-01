import "package:flutter/foundation.dart";
import "package:sqflite/sqflite.dart";
import "package:path_provider/path_provider.dart"
    show getApplicationDocumentsDirectory, MissingPlatformDirectoryException;
import "package:path/path.dart" show join;
import "../crud/crud_exception.dart";

class NotesService {
  Database? _db;

  Future<DatabaseNotes> updateNotes({
    required DatabaseNotes note,
    required String text,
  }) async {
    final db = _getDataBaseOrThrow();

    await getNote(id: note.id);

    final updatedCount = await db.update(noteTable, {
      textNotesColumn: text,
      isSynchedWithCloudColumn: 0,
    });

    if (updatedCount == 0) {
      throw CouldNotUpdateNotes();
    } else {
      return await getNote(id: note.id);
    }
  }

  Future<Iterable<DatabaseNotes>> getAllNotes() async {
    final db = _getDataBaseOrThrow();
    final notes = await db.query(noteTable);

    if (notes.isEmpty) {
      throw CouldNotFindNotes();
    } else {
      final result = notes.map((notesRow) => DatabaseNotes.fromRow(notesRow));
      return result;
    }
  }

  Future<DatabaseNotes> getNote({required int id}) async {
    final db = _getDataBaseOrThrow();
    final notes = await db.query(
      noteTable,
      limit: 1,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (notes.isEmpty) {
      throw CouldNotFindNotes();
    } else {
      return DatabaseNotes.fromRow(notes.first);
    }
  }

  Future<int> deleteAllNotes() async {
    final db = _getDataBaseOrThrow();
    return await db.delete(noteTable);
  }

  Future<void> deleteNote({required int id}) async {
    final db = _getDataBaseOrThrow();
    final deletedCount = await db.delete(
      noteTable,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (deletedCount == 0) {
      throw CouldNotDeleteNote();
    }
  }

  Future<DatabaseNotes> createNote({required DatabaseUser owner}) async {
    final db = _getDataBaseOrThrow();
    final dbUser = await getUser(email: owner.email);

    if (dbUser != owner) {
      throw CouldNotFindUser();
    }
    const text = '';

    final notesID = await db.insert(
      noteTable,
      {
        userIdColumn: owner.id,
        textNotesColumn: text,
        isSynchedWithCloudColumn: 1,
      },
    );

    final note = DatabaseNotes(
      id: notesID,
      userId: owner.id,
      text: text,
      isSyncedWithCloud: true,
    );

    return note;
  }

  Future<DatabaseUser> getUser({required String email}) async {
    final db = _getDataBaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isEmpty) {
      throw UserNotFound();
    } else {
      //? First row which was read from the userTable.
      return DatabaseUser.fromRow(results.first);
    }
  }

  Future<DatabaseUser> createUser({required String email}) async {
    final db = _getDataBaseOrThrow();
    final results = await db.query(
      userTable,
      limit: 1,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (results.isNotEmpty) {
      throw UserAlreadyExists();
    }

    // This actually return the userID
    final userID = await db.insert(
      userTable,
      {
        emailColumn: email.toLowerCase(),
      },
    );

    return DatabaseUser(id: userID, email: email);
  }

  Future<void> deleteUser({required String email}) async {
    final db = _getDataBaseOrThrow();
    final deletedCount = await db.delete(
      userTable,
      where: 'email = ?',
      whereArgs: [email.toLowerCase()],
    );

    if (deletedCount != 1) {
      throw CouldNotDeleteUser();
    }
  }

  //To get the DataBase.
  Database _getDataBaseOrThrow() {
    final db = _db;
    if (db == null) {
      throw DataBaseNotOpen();
    } else {
      return db;
    }
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) {
      throw DataBaseNotOpen();
    } else {
      await db.close();
      _db = null;
    }
  }

  Future<void> open() async {
    if (_db != null) {
      throw DataBaseAlreadyOpenException();
    }
    try {
      final docsPath = await getApplicationDocumentsDirectory();
      final dbPath = join(docsPath.path, dbName);
      final db = await openDatabase(dbPath);

      //Assigning the Database.
      _db = db;

      //Creating the tables
      await db.execute(createUserTable);
      await db.execute(createNotesTable);
    } on MissingPlatformDirectoryException {
      throw UnableToGetDocumentsDirectory();
    }
  }
}

//? These classes are basically the structure of the Objects to be stored in the database.
@immutable
class DatabaseUser {
  final int id;
  final String email;

  const DatabaseUser({
    required this.id,
    required this.email,
  });

  //? Creating a DatabaseUser from the map.
  DatabaseUser.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        email = map[emailColumn] as String;

  @override
  String toString() => 'Person, ID => @$id, email = $email';

  @override
  bool operator ==(covariant DatabaseUser other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class DatabaseNotes {
  final int id;
  final int userId;
  final String text;
  final bool isSyncedWithCloud;

  DatabaseNotes({
    required this.id,
    required this.userId,
    required this.text,
    required this.isSyncedWithCloud,
  });

  //Converting the Text into the Database Notes object.
  DatabaseNotes.fromRow(Map<String, Object?> map)
      : id = map[idColumn] as int,
        userId = map[userIdColumn] as int,
        text = map[textNotesColumn] as String,
        isSyncedWithCloud =
            (map[isSynchedWithCloudColumn] as int) == 1 ? true : false;

  @override
  String toString() =>
      'Note, ID = $id, userID = $userId, isSynchedWithCloud = $isSyncedWithCloud';

  @override
  bool operator ==(covariant DatabaseNotes other) => id == other.id;

  @override
  int get hashCode => id.hashCode;
}

const idColumn = 'id';
const emailColumn = 'email';
const textNotesColumn = 'text';
const isSynchedWithCloudColumn = 'is_synched_with_cloud';
const userIdColumn = 'user_id';
const dbName = 'notes.db';
const noteTable = 'note';
const userTable = 'user';

const createNotesTable = '''
      CREATE TABLE "notes" (
	    "id"	INTEGER NOT NULL,
	    "user_id"	INTEGER NOT NULL,
	    "text"	TEXT,
	    "is_synced_with_cloud"	INTEGER NOT NULL DEFAULT 0,
	    PRIMARY KEY("id"),
	    FOREIGN KEY("user_id") REFERENCES "user"("id")
      ); ''';

const createUserTable = '''
      CREATE TABLE IF NOT EXISTS "user" (
	    "id"	INTEGER NOT NULL,
	    "email"	TEXT NOT NULL UNIQUE,
	    PRIMARY KEY("id" AUTOINCREMENT)
      ); ''';
