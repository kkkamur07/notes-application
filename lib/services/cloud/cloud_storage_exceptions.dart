// Having a super class of exceptions helps .

class CloudStorageException implements Exception {
  const CloudStorageException();
}

// C in CRUD
class CouldNotCreateNotes implements CloudStorageException {}

// R in CRUD
class CouldNotGetNotes implements CloudStorageException {}

// U in CRUD
class CouldNotUpdateNotes implements CloudStorageException {}

// D in CRUD
class CouldNotDeleteNotes implements CloudStorageException {}
