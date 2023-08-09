const idColumn = 'id';
const emailColumn = 'email';
const textNotesColumn = 'text';
const isSynchedWithCloudColumn = "is_synced_with_cloud";
const userIdColumn = 'user_id';
const dbName = 'notes.db';
const noteTable = 'notes';
const userTable = 'user';

const createNotesTable = '''
      CREATE TABLE IF NOT EXISTS "notes" (
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
