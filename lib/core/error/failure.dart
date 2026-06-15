/// A user-facing failure (already mapped from an exception).
class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}
