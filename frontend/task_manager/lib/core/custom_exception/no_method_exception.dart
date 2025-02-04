class NoMethodException implements Exception {
  final String message;

  NoMethodException({this.message = "No method provided"});

  @override
  String toString() {
    return message.isNotEmpty
        ? 'NoMethodException: $message'
        : 'NoMethodException: Please pass a method to call';
  }
}