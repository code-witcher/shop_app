class HttpException implements Exception {
  final String msg;
  HttpException({required this.msg});

  @override
  String toString() {
    return 'Exception: $msg';
  }
}
