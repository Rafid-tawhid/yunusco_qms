import 'dart:async';
import 'package:http_interceptor/http_interceptor.dart';
import '../utils/constants.dart';
import '../utils/dashboard_helpers.dart';


class CustomInterceptor implements InterceptorContract {
  @override
  FutureOr<bool> shouldInterceptRequest() {
    // This method indicates whether the request should be intercepted.
    // In most cases, you'd return `true` to always intercept.
    return true;
  }

  @override
  FutureOr<bool> shouldInterceptResponse() {
    // This method indicates whether the response should be intercepted.
    // In most cases, you'd return `true` to always intercept.
    return true;
  }

  @override
  FutureOr<BaseRequest> interceptRequest({required BaseRequest request}) {
    // Add Bearer token to the headers
    request.headers["Authorization"] = "Bearer ${AppConstants.token}";
    // Optionally log the request for debugging
    print("Request URL: ${request.url}");
    print("Request Headers: ${request.headers}");
    // Return the request after modification
    return request;
  }

  @override
  FutureOr<BaseResponse> interceptResponse({required BaseResponse response}) {
    // Optionally log the response for debugging
    print("Response Status Code: ${response.statusCode}");
    print("Response Headers: ${response.headers}");
    // print("Response Token: ${response.headers['token']}");
    return response;
  }
}
