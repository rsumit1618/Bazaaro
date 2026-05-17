class Failure implements Exception {
  const Failure(this.message, {this.code, this.stackTrace});

  final String message;
  final String? code;
  final StackTrace? stackTrace;

  @override
  String toString() => code == null ? message : '$code: $message';
}
