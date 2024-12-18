
class AccessError extends Error {
  final String message;

  AccessError(this.message);

  @override
  String toString() {
    return message;
  }
}