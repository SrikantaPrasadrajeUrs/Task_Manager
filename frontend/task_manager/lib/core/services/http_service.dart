import 'dart:convert';
import 'dart:developer';
import 'package:task_manager/core/custom_exception/custom_exception.dart';
import 'package:http/http.dart' as http;
import 'package:task_manager/core/utils/sp_helper.dart';


class HTTPService {
   static String xAuthToken = "x-auth-token";
  static const Map<String, String> headers = {
    "Content-Type": "application/json",
  };

  static Future<dynamic> get(String endPoint, {int? statusCode}) async {
    return await _sendRequest(null, null, http.get, endPoint, null, statusCode);
  }

  static Future<dynamic> post(String endPoint, Map<String, dynamic>? data,
      {int? statusCode,
        bool wantErrorData = false,
        bool wantException = false,
        bool wantLogs = false,
        bool printData = false,
        bool sendHeaders = true}) async {
    return await _sendRequest(null, http.post, null, endPoint, data, statusCode,
        wantErrorData: wantErrorData,
        wantException: wantException,
        wantLogs: wantLogs,
        printData: printData,
        sendHeaders: sendHeaders);
  }

  static Future<dynamic> put(String endPoint, Map<String, dynamic>? data,
      {int? statusCode, bool wantException = false}) async {
    return await _sendRequest(null, http.put, null, endPoint, data, statusCode,
        wantException: wantException);
  }

  static Future<dynamic> delete(String endPoint,
      {int? statusCode, bool wantErrorData = false}) async {
    return await _sendRequest(
        http.delete, null, null, endPoint, null, statusCode,
        wantErrorData: wantErrorData);
  }

  static Future<dynamic> _sendRequest(
      Future<http.Response> Function(Uri url,
          {Map<String, String>? headers, Object? body})?
      delete,
      Future<http.Response> Function(Uri url,
          {Map<String, String>? headers, Object? body})?
      putOrPost,
      Future<http.Response> Function(Uri url, {Map<String, String>? headers})?
      get,
      String endPoint,
      Map<String, dynamic>? data,
      int? statusCode,
      {bool wantErrorData = false,
        bool wantException = false,
        bool wantLogs = false,
        bool printData = false,
        bool sendHeaders = true}) async {
    try {
      String? token = await SpHelper().getToken();
      if(token==null) throw Exception("Some Error Occurred!");
      // Default status code to 200 if null
      if (putOrPost != null && get != null && delete != null) {
        throw Exception("Please pass either put or post or get method");
      }
      statusCode ??= 200;
      final http.Response? response;
      if (putOrPost != null) {
        response = await putOrPost(
          Uri.parse(endPoint),
          body: jsonEncode(data),
          headers: sendHeaders
              ? {
            ...headers,
            xAuthToken: token,
          } : null,
        );
      } else if (get != null) {
        response = await get.call(
          Uri.parse(endPoint),
          headers: {
            ...headers,
            xAuthToken: token,
          },
        );
      } else {
        response = await delete?.call(
          Uri.parse(endPoint),
          headers: {
            ...headers,
            xAuthToken: token,
          },
        );
      }
      if(printData) log("${response?.body}");
      if (response == null) throw NoMethodException();
      if (response.statusCode == statusCode) {
        return jsonDecode(response.body);
      } else {
        if (wantErrorData) {
          return jsonDecode(response.body);
        } else {
          throw StatusCodeException(
              statusCode: response.statusCode,
              message: jsonDecode(response.body)?['message'] ??
                  response.reasonPhrase ??
                  "Unknown error occurred");
        }
      }
    } catch (e, stackTrace) {
      if (wantLogs) log("Error while calling $endPoint", error: e, stackTrace: stackTrace);
      if (wantException) {
        rethrow;
      } else {
        return null;
      }
    }
  }
}