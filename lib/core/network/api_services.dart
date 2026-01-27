import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:edu_cluezer/core/network/api_constants.dart';
import 'package:get/get.dart' hide FormData, Response;

import '../../db/shared_pref_manager.dart';
import '../../widgets/custom_snack_bar.dart';
import '../helper/general_dialogs.dart';
import '../helper/logger_helper.dart';
import 'retry_interceptor.dart';

class ApiServices extends GetxService {
  late final Dio _dio;

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.apiBaseUrl,
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          "Accept": "application/json",
          ApiConstants.xApiKey: ApiConstants.xApiValue,
        },
        validateStatus: (status) {
          return status != null && status > 0;
        },
      ),
    );
    _dio.interceptors.add(_buildLogger());
    _dio.interceptors.add(_buildRetry());
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final HttpClient client = HttpClient();
      client.badCertificateCallback = (cert, host, port) => true;
      return client;
    };
  }

  LogInterceptor _buildLogger() {
    return LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseBody: true,
      responseHeader: false,
      error: true,
    );
  }

  RetryInterceptor _buildRetry() {
    return RetryInterceptor(
      dio: _dio,
      retries: 3,
      retryEvaluator: (error, attempt) {
        return error.type == DioExceptionType.connectionError ||
            error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout;
      },
    );
  }

  void logApiError(String message) {
    printMessage("⚠️ API Error: $message");
  }

  Future<ResponseModel> callPost(
    String endpoint, {
    Map<String, dynamic> req = const {},
    FormData? multipartRequest,
    bool isUserRequired = false,
    bool isBodyData = false,
  }) async {
    try {
      final headers = <String, String>{
        "Accept": "application/json",
        "Content-Type": "application/json",
      };
      if (isUserRequired) {
        final token = SharedPrefManager().userToken;
        if (token.isNotEmpty) {
          headers[ApiConstants.authorization] = "Bearer $token";
        }
      }
      final options = Options(headers: headers);
      printMessage(
        "📡 POST [${ApiConstants.apiBaseUrl}$endpoint] Request $req",
      );
      dynamic requestData;
      if (multipartRequest != null) {
        requestData = multipartRequest;
      } else if (isBodyData) {
        requestData = req;
      } else {
        requestData = FormData.fromMap(req);
      }
      final response = await _dio.post(
        endpoint,
        data: requestData,
        options: options,
      );
      return checkResponseModel(response);
    } catch (e, stk) {
      logApiError("Exception in POST $endpoint → $e \n$stk");
      return ResponseModel(false, "Unexpected error occurred", null);
    }
  }

  Future<ResponseModel> callGet(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool isUserRequired = true,
  }) async {
    try {
      final headers = <String, String>{
        "Accept": "application/json",
        "Content-Type": "application/json",
      };
      if (isUserRequired) {
        final token = SharedPrefManager().userToken;
        if (token.isNotEmpty) {
          headers[ApiConstants.authorization] = "Bearer $token";
        }
      }
      final options = Options(headers: headers);
      var response = await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: options,
      );
      return checkResponseModel(response);
    } catch (e, stk) {
      logApiError("Exception in GET $endpoint → $e \n $stk");
      return ResponseModel(false, "Unexpected error occurred", null);
    }
  }
}

Future<ResponseModel> checkResponseModel(Response response) async {
  printMessage("Status Code: ${response.statusCode}");
  printMessage("Status Message: ${response.statusMessage}");
  printMessage("Response Data: ${json.encode(response.data)}");

  /// ✅ Success responses
  if (response.statusCode == 200 || response.statusCode == 201) {
    final status = response.data[ApiKeys.success] ?? false;
    final message = response.data[ApiKeys.message] ?? '';
    final data = response.data[ApiKeys.response];
    return ResponseModel(status, message, status ? data : null);
  }

  /// ❌ Unauthorized (Invalid login, token expired, etc.) else
  if (response.statusCode == 401) {
    final message = response.data[ApiKeys.message] ?? "Unauthorized access";
    CustomSnackBar.showError(message: message);
    return ResponseModel(false, message, null);
  }

  if (response.statusCode == 422) {
    final message = response.data[ApiKeys.message] ?? "Invalid Login";
    if (response.data.containsKey(ApiKeys.errors)) {
      showErrorDialog(response.data[ApiKeys.errors]);
    }
    return ResponseModel(false, message, null);
  }

  /// ❌ Other errors (500, 400, etc.) else {
  if (!response.data.toString().startsWith('{')) {
    CustomSnackBar.showError(message: 'Failed to connect to server.');
    return ResponseModel(false, 'Internal Server Error', null);
  } else {
    final status = false;
    final message = response.data[ApiKeys.message] ?? "Internal Server Error";
    CustomSnackBar.showError(message: message);
    return ResponseModel(status, message, null);
  }
}

class ResponseModel {
  final bool _status;
  final String _message;
  final dynamic _data;

  ResponseModel(this._status, this._message, this._data);

  String get message => _message;

  bool get status => _status;

  dynamic get data => _data;
}
