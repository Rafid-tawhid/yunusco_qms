import 'dart:async';
import 'package:http_interceptor/http_interceptor.dart';
import '../utils/constants.dart';

class CustomInterceptor implements InterceptorContract {
  @override
  FutureOr<bool> shouldInterceptRequest() => true;

  @override
  FutureOr<bool> shouldInterceptResponse() => true;

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) {
    // Add Bearer token to the headers
    request.headers["Authorization"] = "Bearer ${AppConstants.token}";

    // Save start time in request headers (just for tracking)
    request.headers["request-start-time"] =
        DateTime.now().millisecondsSinceEpoch.toString();

    // Log request
    print("➡️ Request URL: ${request.url}");
    print("➡️ Request Headers: ${request.headers}");

    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) {
    // Get start time from request headers
    final startTimeStr = response.request?.headers["request-start-time"];
    if (startTimeStr != null) {
      final startTime = int.tryParse(startTimeStr) ?? 0;
      final endTime = DateTime.now().millisecondsSinceEpoch;
      final duration = endTime - startTime;

      print("⏱️ API executed in $duration ms (status: ${response.statusCode})");
    }

    // Log response
    print("⬅️ Response Status Code: ${response.statusCode}");
    print("⬅️ Response Headers: ${response.headers}");

    return response;
  }
}
