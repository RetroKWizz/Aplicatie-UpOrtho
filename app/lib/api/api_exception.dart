class ApiException implements Exception {
  const ApiException({
    required this.status,
    required this.code,
    required this.message,
    this.details = const {},
  });

  final int status;
  final String code;
  final String message;
  final Map<String, dynamic> details;

  bool get isUnauthorized => status == 401;

  @override
  String toString() => 'ApiException($status $code: $message)';
}
