import 'dart:developer' show log;

Future<T?> executeSafely<T>(
    Function() function, {
      T? defaultValue,
      Function(dynamic error, StackTrace stackTrace)? onError,
      String? functionName = "UnknownFunction"
    }) async {
  try {
    return await function();
  } catch (error, stackTrace) {
    if (onError != null) {
      return onError(error, stackTrace);
    } else {
      log("functionName: $functionName, at: ${DateTime.now()}",error: error, stackTrace: stackTrace);
    }
    return defaultValue;
  }
}