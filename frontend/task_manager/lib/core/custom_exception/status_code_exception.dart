class StatusCodeException implements Exception{
  final String message;
  final int statusCode;
  StatusCodeException({required this.statusCode,required this.message}):super();

  @override
  String toString() {
   return "StatusCodeException with statusCode: $statusCode with message: $message";
  }
}
