class HttpException implements Exception {
  final String message;
  final int statusCode;
  HttpException(this.message, {this.statusCode = 400});

  @override
  String toString() {
    return message;
  }
}
