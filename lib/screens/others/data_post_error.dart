class PostError extends Error {
  final String message;

  PostError(this.message);

  @override
  String toString() {
    return message;
  }
}

class PostException implements Exception {
  final String message;

  PostException(this.message);

  @override
  String toString() {
    return message;
  }
}
