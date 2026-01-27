import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';
import 'package:http/http.dart' as http;

/*class ApiClient {
  final String baseUrl;
  String? token;
  final int timeoutInSeconds;

  late Map<String, String> _headers;

  ApiClient({
    required this.baseUrl,
    this.token,
    this.timeoutInSeconds = 30,
  }) {
    _headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Update token or headers dynamically
  void updateToken(String? newToken) {
    token = newToken;
    if (token != null) {
      _headers['Authorization'] = 'Bearer $token';
    } else {
      _headers.remove('Authorization');
    }
  }

  void updateHeaders(Map<String, String> newHeaders) {
    _headers.addAll(newHeaders);
  }

  Map<String, String> get headers => _headers;

  // GET request
  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$path'), headers: headers ?? _headers)
          .timeout(Duration(seconds: timeoutInSeconds));
      return response;
    } catch (e) {
      if (kDebugMode) print('GET error: $e');
      rethrow;
    }
  }

  // POST request
  Future<http.Response> post(String path, {dynamic body, Map<String, String>? headers}) async {
    try {
      final jsonBody = body != null ? jsonEncode(body) : null;
      final response = await http
          .post(Uri.parse('$baseUrl$path'), headers: headers ?? _headers, body: jsonBody)
          .timeout(Duration(seconds: timeoutInSeconds));
      return response;
    } catch (e) {
      if (kDebugMode) print('POST error: $e');
      rethrow;
    }
  }

  // PUT request
  Future<http.Response> put(String path, {dynamic body, Map<String, String>? headers}) async {
    try {
      final jsonBody = body != null ? jsonEncode(body) : null;
      final response = await http
          .put(Uri.parse('$baseUrl$path'), headers: headers ?? _headers, body: jsonBody)
          .timeout(Duration(seconds: timeoutInSeconds));
      return response;
    } catch (e) {
      if (kDebugMode) print('PUT error: $e');
      rethrow;
    }
  }

  // DELETE request
  Future<http.Response> delete(String path, {Map<String, String>? headers}) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$path'), headers: headers ?? _headers)
          .timeout(Duration(seconds: timeoutInSeconds));
      return response;
    } catch (e) {
      if (kDebugMode) print('DELETE error: $e');
      rethrow;
    }
  }

  // Multipart POST
  Future<http.Response> postMultipart(
      String path, {
        Map<String, String>? fields,
        List<MultipartFileData>? files,
        Map<String, String>? headers,
      }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));
      request.headers.addAll(headers ?? _headers);

      // Add fields
      if (fields != null) request.fields.addAll(fields);

      // Add files
      if (files != null) {
        for (var fileData in files) {
          if (fileData.bytes != null) {
            request.files.add(http.MultipartFile.fromBytes(
              fileData.field,
              fileData.bytes!,
              filename: fileData.filename,
              contentType: fileData.contentType,
            ));
          } else if (fileData.filePath != null) {
            final file = File(fileData.filePath!);
            request.files.add(await http.MultipartFile.fromPath(
              fileData.field,
              file.path,
              contentType: fileData.contentType,
            ));
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return response;
    } catch (e) {
      if (kDebugMode) print('Multipart error: $e');
      rethrow;
    }
  }
}

/// Helper class for multipart files
class MultipartFileData {
  final String field;
  final String? filePath; // local file path
  final Uint8List? bytes; // bytes for web
  final String filename;
  final MediaType? contentType;

  MultipartFileData({
    required this.field,
    this.filePath,
    this.bytes,
    required this.filename,
    this.contentType,
  });
}


/// Media type helper
class MediaType {
  final String type;
  final String subtype;
  MediaType(this.type, this.subtype);

  @override
  String toString() => '$type/$subtype';
}*/





import 'package:http_parser/http_parser.dart';
import '../../core/helper/logger_helper.dart';
import '../../core/network/api_constants.dart';
import '../../db/shared_pref_manager.dart';
import '../../widgets/custom_snack_bar.dart';
import 'appUrls.dart';


/*class ApiServices extends GetxService {
  final Duration _timeout = const Duration(seconds: 60);

  /// Common GET method
  Future<Map<String, dynamic>?> callGet(
      String endpoint, {
        Map<String, dynamic>? queryParams,
      }) async {
    final uri = Uri.parse(
      "${AppUrls.baseUrl}$endpoint",
    ).replace(queryParameters: queryParams);

    print("authnticationtoken : " + SharedPrefManager().userToken.toString());
    return _safeCall(() async {
      final response = await http
          .get(uri, headers: _defaultHeaders())
          .timeout(_timeout);

      print("getapiresponse : " + response.body);
      return _parseResponse(response);
    });
  }

  /// Common POST method
  Future<Map<String, dynamic>?> callPost(
      String endpoint, {
        required Map<String, dynamic> data,
        bool isUserRequired = false,
        bool isFormData = false,
      }) async {
    if (isUserRequired) {
      final userId = {
        ApiKeys.userId: (SharedPrefManager().user?.id ?? "").toString(),
      };
      data.addAll(userId);
    }

    final uri = Uri.parse("${AppUrls.baseUrl}$endpoint");

    logApiMessage("Request --> ${uri.toString()}");

    return _safeCall(() async {
      if (isFormData) {
        final request = http.MultipartRequest("POST", uri);
        request.headers.addAll(_defaultHeaders());

        data.forEach((key, value) {
          if (value is String) {
            request.fields[key] = value;
          }
        });

        logApiMessage("Request --> ${uri.toString()}");

        for (final entry in data.entries) {
          if (entry.value is File) {
            final file = entry.value as File;
            final fileStream = http.ByteStream(file.openRead());
            final length = await file.length();
            final multipartFile = http.MultipartFile(
              entry.key,
              fileStream,
              length,
              filename: file.path.split("/").last,
            );
            request.files.add(multipartFile);
          }
        }

        final streamedResponse = await request.send().timeout(_timeout);
        final response = await http.Response.fromStream(streamedResponse);
        return _parseResponse(response);
      } else {
        final response = await http
            .post(uri, headers: _defaultHeaders(), body: jsonEncode(data))
            .timeout(_timeout);
        return _parseResponse(response);
      }
    });
  }

  Future<Map<String, dynamic>?> callDelete(
      String endpoint, {
        Map<String, dynamic>? data,
        bool isUserRequired = false,
      }) async {
    Map<String, dynamic> bodyData = data ?? {};

    if (isUserRequired) {
      final userId = {
        ApiKeys.userId: (SharedPrefManager().user?.id ?? "").toString(),
      };
      bodyData.addAll(userId);
    }

    final uri = Uri.parse("${AppUrls.baseUrl}$endpoint");

    logApiMessage("DELETE --> ${uri.toString()}");
    if (bodyData.isNotEmpty) {
      logApiMessage("DELETE BODY --> ${jsonEncode(bodyData)}");
    }

    return _safeCall(() async {
      http.Response response;

      if (bodyData.isNotEmpty) {
        // DELETE with body
        response = await http.Request(
          "DELETE",
          uri,
        ).sendWithBody(_defaultHeaders(), jsonEncode(bodyData));
      } else {
        response = await http
            .delete(uri, headers: _defaultHeaders())
            .timeout(_timeout);
      }

      return _parseResponse(response);
    });
  }

  /// Default headers
  Map<String, String> _defaultHeaders() => {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    "Authorization":
    "Bearer ${SharedPrefManager().userToken }",
  };

  /// Safe API call wrapper
  Future<Map<String, dynamic>?> _safeCall(
      Future<Map<String, dynamic>?> Function() call,
      ) async {
    try {
      return await call();
    } on SocketException catch (e) {
      _handleError("Network error: $e");
    } on TimeoutException catch (e) {
      _handleError("Request timed out: $e");
    } catch (e, stackTrace) {
      printMessage("Unexpected error: $e\n$stackTrace");
      CustomSnackBar.showError(message: "An unexpected error occurred.");
    }
    return null;
  }

  /// Parse response body safely
  Map<String, dynamic>? _parseResponse(http.Response response) {
    try {
      final body = response.body.isNotEmpty ? jsonDecode(response.body) : {};
      logApiMessage(" Response --> $body  ${response.statusCode}");
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return body is Map<String, dynamic> ? body : {"data": body};
      } else if (response.statusCode == 401 || response.statusCode == 404) {
        _handleError(body['message']);
        return body;
      } else if (response.statusCode == 422) {
        return body;
      } else {
        _handleError(
          "Server returned ${response.statusCode}: ${response.reasonPhrase}",
        );
      }
    } catch (e) {
      _handleError("Invalid JSON: $e");
    }
    return null;
  }

  /// Error handler
  void _handleError(String message) {
    printMessage("HTTP ERROR: $message");
    CustomSnackBar.showError(message: message);
  }

  /// Logging helpers
  void logApiError(String message) => printMessage("⚠️ $message");

  void logApiMessage(String message) => printMessage("📡 $message");
}

extension DeleteRequestWithBody on http.Request {
  Future<http.Response> sendWithBody(
      Map<String, String> headers,
      String body,
      ) async {
    this.headers.addAll(headers);
    this.body = body;

    final streamedResponse = await this.send();
    return http.Response.fromStream(streamedResponse);
  }
}*/

class ApiClient {
  final String baseUrl;
  String? token;
  final int timeoutInSeconds;

  late Map<String, String> _headers;

  ApiClient({
    required this.baseUrl,
    this.token,
    this.timeoutInSeconds = 30,
  }) {
    _headers = {
      'Content-Type': 'application/json; charset=UTF-8',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Update token or headers dynamically
  void updateToken(String? newToken) {
    token = newToken;
    if (token != null) {
      _headers['Authorization'] = 'Bearer $token';
    } else {
      _headers.remove('Authorization');
    }
  }

  void updateHeaders(Map<String, String> newHeaders) {
    _headers.addAll(newHeaders);
  }

  Map<String, String> get headers => _headers;

  // GET request
  Future<http.Response> get(String path, {Map<String, String>? headers}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$path'), headers: headers ?? _headers)
          .timeout(Duration(seconds: timeoutInSeconds));
      return response;
    } catch (e) {
      if (kDebugMode) print('GET error: $e');
      rethrow;
    }
  }

  // POST request
  Future<http.Response> post(String path, {dynamic body, Map<String, String>? headers}) async {
    try {
      final jsonBody = body != null ? jsonEncode(body) : null;
      final response = await http
          .post(Uri.parse('$baseUrl$path'),
          headers: headers ?? _headers,
          body: jsonBody)
          .timeout(Duration(seconds: timeoutInSeconds));
      return response;
    } catch (e) {
      if (kDebugMode) print('POST error: $e');
      rethrow;
    }
  }

  // PUT request
  Future<http.Response> put(String path, {dynamic body, Map<String, String>? headers}) async {
    try {
      final jsonBody = body != null ? jsonEncode(body) : null;
      final response = await http
          .put(Uri.parse('$baseUrl$path'),
          headers: headers ?? _headers,
          body: jsonBody)
          .timeout(Duration(seconds: timeoutInSeconds));
      return response;
    } catch (e) {
      if (kDebugMode) print('PUT error: $e');
      rethrow;
    }
  }

  // PATCH request
  Future<http.Response> patch(String path, {dynamic body, Map<String, String>? headers}) async {
    try {
      final jsonBody = body != null ? jsonEncode(body) : null;
      final response = await http
          .patch(Uri.parse('$baseUrl$path'),
          headers: headers ?? _headers,
          body: jsonBody)
          .timeout(Duration(seconds: timeoutInSeconds));
      return response;
    } catch (e) {
      if (kDebugMode) print('PATCH error: $e');
      rethrow;
    }
  }

  // DELETE request
  Future<http.Response> delete(String path, {Map<String, String>? headers}) async {
    try {
      final response = await http
          .delete(Uri.parse('$baseUrl$path'), headers: headers ?? _headers)
          .timeout(Duration(seconds: timeoutInSeconds));
      return response;
    } catch (e) {
      if (kDebugMode) print('DELETE error: $e');
      rethrow;
    }
  }

  /// ENHANCED MULTIPART POST - FIXED VERSION
  Future<http.Response> postMultipart(
      String path, {
        Map<String, String>? fields,
        List<MultipartFileData>? files,
        Map<String, String>? headers,
      }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));

      // Add headers - Remove Content-Type from multipart request headers
      final requestHeaders = Map<String, String>.from(headers ?? {});
      requestHeaders.remove('Content-Type'); // Let http package set this
      request.headers.addAll({
        ..._headers,
        ...requestHeaders,
        if (token != null) 'Authorization': 'Bearer $token',
      });

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null && files.isNotEmpty) {
        for (var fileData in files) {
          // Determine content type
          MediaType? contentType;
          if (fileData.contentType != null) {
            contentType = MediaType.parse(fileData.contentType!);
          } else {
            // Auto-detect from file extension
            final ext = fileData.filename.split('.').last.toLowerCase();
            contentType = _getContentTypeFromExtension(ext);
          }

          // Handle bytes (for web)
          if (fileData.bytes != null && fileData.bytes!.isNotEmpty) {
            final multipartFile = http.MultipartFile.fromBytes(
              fileData.field,
              fileData.bytes!,
              filename: fileData.filename,
              contentType: contentType,
            );
            request.files.add(multipartFile);
          }
          // Handle file path (for mobile/desktop)
          else if (fileData.filePath != null && fileData.filePath!.isNotEmpty) {
            final file = File(fileData.filePath!);
            if (await file.exists()) {
              final stream = file.openRead();
              final length = await file.length();

              final multipartFile = http.MultipartFile(
                fileData.field,
                stream,
                length,
                filename: fileData.filename,
                contentType: contentType,
              );
              request.files.add(multipartFile);
            }
          }
        }
      }

      // Send request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response;
    } catch (e) {
      if (kDebugMode) {
        print('Multipart POST error: $e');
        print('Stack trace: ${e.toString()}');
      }
      rethrow;
    }
  }

  /// MULTIPART PUT
  Future<http.Response> putMultipart(
      String path, {
        Map<String, String>? fields,
        List<MultipartFileData>? files,
        Map<String, String>? headers,
      }) async {
    try {
      final request = http.MultipartRequest('PUT', Uri.parse('$baseUrl$path'));

      // Add headers
      final requestHeaders = Map<String, String>.from(headers ?? {});
      requestHeaders.remove('Content-Type');
      request.headers.addAll({
        ..._headers,
        ...requestHeaders,
        if (token != null) 'Authorization': 'Bearer $token',
      });

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add files
      if (files != null && files.isNotEmpty) {
        for (var fileData in files) {
          MediaType? contentType;
          if (fileData.contentType != null) {
            contentType = MediaType.parse(fileData.contentType!);
          } else {
            final ext = fileData.filename.split('.').last.toLowerCase();
            contentType = _getContentTypeFromExtension(ext);
          }

          if (fileData.bytes != null && fileData.bytes!.isNotEmpty) {
            final multipartFile = http.MultipartFile.fromBytes(
              fileData.field,
              fileData.bytes!,
              filename: fileData.filename,
              contentType: contentType,
            );
            request.files.add(multipartFile);
          } else if (fileData.filePath != null && fileData.filePath!.isNotEmpty) {
            final file = File(fileData.filePath!);
            if (await file.exists()) {
              final multipartFile = await http.MultipartFile.fromPath(
                fileData.field,
                fileData.filePath!,
                filename: fileData.filename,
                contentType: contentType,
              );
              request.files.add(multipartFile);
            }
          }
        }
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response;
    } catch (e) {
      if (kDebugMode) print('Multipart PUT error: $e');
      rethrow;
    }
  }

  /// Helper method to get content type from file extension
  MediaType? _getContentTypeFromExtension(String extension) {
    switch (extension) {
      case 'jpg':
      case 'jpeg':
        return MediaType('image', 'jpeg');
      case 'png':
        return MediaType('image', 'png');
      case 'gif':
        return MediaType('image', 'gif');
      case 'pdf':
        return MediaType('application', 'pdf');
      case 'doc':
        return MediaType('application', 'msword');
      case 'docx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.wordprocessingml.document');
      case 'xls':
        return MediaType('application', 'vnd.ms-excel');
      case 'xlsx':
        return MediaType('application', 'vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      case 'txt':
        return MediaType('text', 'plain');
      default:
        return MediaType('application', 'octet-stream');
    }
  }

  /// Upload single file with progress callback
  Future<http.Response> uploadFile(
      String path,
      String fieldName,
      File file, {
        Map<String, String>? fields,
        Map<String, String>? headers,
        void Function(int sent, int total)? onProgress,
      }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse('$baseUrl$path'));

      // Add headers
      final requestHeaders = Map<String, String>.from(headers ?? {});
      requestHeaders.remove('Content-Type');
      request.headers.addAll({
        ..._headers,
        ...requestHeaders,
        if (token != null) 'Authorization': 'Bearer $token',
      });

      // Add fields
      if (fields != null) {
        request.fields.addAll(fields);
      }

      // Add file with content type detection
      final ext = file.path.split('.').last.toLowerCase();
      final contentType = _getContentTypeFromExtension(ext);

      final multipartFile = await http.MultipartFile.fromPath(
        fieldName,
        file.path,
        filename: file.path.split('/').last,
        contentType: contentType,
      );
      request.files.add(multipartFile);

      // Setup progress tracking
      if (onProgress != null) {
        final total = await file.length();
        request.finalize().listen(
              (data) {
            // Calculate progress
            // Note: This is approximate as data might be compressed
          },
          onDone: () => onProgress(total, total),
        );
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      return response;
    } catch (e) {
      if (kDebugMode) print('File upload error: $e');
      rethrow;
    }
  }

  /// Download file
  Future<Uint8List> downloadFile(String path, {Map<String, String>? headers}) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$path'), headers: headers ?? _headers)
          .timeout(Duration(seconds: timeoutInSeconds));

      if (response.statusCode == 200) {
        return response.bodyBytes;
      } else {
        throw Exception('Failed to download file: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) print('Download error: $e');
      rethrow;
    }
  }

  /// Check if response is successful
  static bool isSuccess(http.Response response) {
    return response.statusCode >= 200 && response.statusCode < 300;
  }

  /// Parse JSON response
  static Map<String, dynamic> parseJson(http.Response response) {
    try {
      return jsonDecode(response.body);
    } catch (e) {
      throw FormatException('Failed to parse JSON: ${response.body}', e.toString());
    }
  }
}

/// Enhanced MultipartFileData class
class MultipartFileData {
  final String field;
  final String? filePath; // local file path (for mobile/desktop)
  final Uint8List? bytes; // bytes for web/memory
  final String filename;
  final String? contentType; // e.g., "image/jpeg", "application/pdf"

  MultipartFileData({
    required this.field,
    this.filePath,
    this.bytes,
    required this.filename,
    this.contentType,
  }) {
    // Validate that either filePath or bytes is provided
    if (filePath == null && bytes == null) {
      throw ArgumentError('Either filePath or bytes must be provided');
    }
  }

  /// Factory constructor for creating from File
  factory MultipartFileData.fromFile({
    required String field,
    required File file,
    String? contentType,
  }) {
    return MultipartFileData(
      field: field,
      filePath: file.path,
      filename: file.path.split('/').last,
      contentType: contentType,
    );
  }

  /// Factory constructor for creating from bytes
  factory MultipartFileData.fromBytes({
    required String field,
    required Uint8List bytes,
    required String filename,
    String? contentType,
  }) {
    return MultipartFileData(
      field: field,
      bytes: bytes,
      filename: filename,
      contentType: contentType,
    );
  }

  /// Check if this is a web file (bytes-based)
  bool get isWebFile => bytes != null && filePath == null;

  /// Check if this is a mobile file (filePath-based)
  bool get isMobileFile => filePath != null && bytes == null;
}
