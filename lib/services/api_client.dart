import 'dart:convert';
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/api_response.dart';

class UnauthorizedException implements Exception {
  final String message;
  UnauthorizedException([this.message = 'Session expired. Please log in again.']);

  @override
  String toString() => message;
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  final _storage = const FlutterSecureStorage();
  final String _baseUrl = kApiBaseUrl;

  Future<Map<String, String>> _getHeaders({bool requireAuth = true}) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (requireAuth) {
      final token = await _storage.read(key: 'access_token');
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  ApiResponse<Map<String, dynamic>> _parseResponse(http.Response resp) {
    final body = jsonDecode(resp.body) as Map<String, dynamic>;
    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return ApiResponse.success(body, resp.statusCode);
    }
    return ApiResponse.error(
      body['error'] as String? ?? 'server_error',
      body['message'] as String? ?? 'Something went wrong.',
      resp.statusCode,
    );
  }

  Future<bool> _tryRefresh() async {
    final refreshToken = await _storage.read(key: 'refresh_token');
    if (refreshToken == null) return false;
    try {
      final resp = await http.post(
        Uri.parse('$_baseUrl/api/v1/auth/refresh'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'refresh_token': refreshToken}),
      );
      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body) as Map<String, dynamic>;
        await _storage.write(key: 'access_token', value: data['access_token'] as String);
        await _storage.write(key: 'refresh_token', value: data['refresh_token'] as String);
        return true;
      }
    } catch (_) {}
    return false;
  }

  Future<ApiResponse<Map<String, dynamic>>> post(
    String path,
    Map<String, dynamic> body, {
    bool requireAuth = true,
  }) async {
    final headers = await _getHeaders(requireAuth: requireAuth);
    final resp = await http.post(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (resp.statusCode == 401 && requireAuth) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders(requireAuth: true);
        final retryResp = await http.post(
          Uri.parse('$_baseUrl$path'),
          headers: retryHeaders,
          body: jsonEncode(body),
        );
        if (retryResp.statusCode == 401) {
          await _clearTokens();
          throw UnauthorizedException();
        }
        return _parseResponse(retryResp);
      } else {
        await _clearTokens();
        throw UnauthorizedException();
      }
    }

    return _parseResponse(resp);
  }

  Future<ApiResponse<Map<String, dynamic>>> get(String path, {Map<String, String>? queryParams}) async {
    final headers = await _getHeaders();
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }
    final resp = await http.get(uri, headers: headers);

    if (resp.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final retryHeaders = await _getHeaders();
        var retryUri = Uri.parse('$_baseUrl$path');
        if (queryParams != null && queryParams.isNotEmpty) {
          retryUri = retryUri.replace(queryParameters: queryParams);
        }
        final retryResp = await http.get(retryUri, headers: retryHeaders);
        if (retryResp.statusCode == 401) {
          await _clearTokens();
          throw UnauthorizedException();
        }
        return _parseResponse(retryResp);
      } else {
        await _clearTokens();
        throw UnauthorizedException();
      }
    }

    return _parseResponse(resp);
  }

  Future<ApiResponse<Map<String, dynamic>>> patch(
    String path,
    Map<String, dynamic> body,
  ) async {
    final headers = await _getHeaders();
    final resp = await http.patch(
      Uri.parse('$_baseUrl$path'),
      headers: headers,
      body: jsonEncode(body),
    );

    if (resp.statusCode == 401) {
      await _clearTokens();
      throw UnauthorizedException();
    }

    return _parseResponse(resp);
  }

  Future<ApiResponse<Map<String, dynamic>>> delete(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final headers = await _getHeaders();
    final req = http.Request('DELETE', Uri.parse('$_baseUrl$path'));
    req.headers.addAll(headers);
    if (body != null) req.body = jsonEncode(body);

    final streamedResp = await req.send();
    final resp = await http.Response.fromStream(streamedResp);

    if (resp.statusCode == 401) {
      await _clearTokens();
      throw UnauthorizedException();
    }

    return _parseResponse(resp);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(key: 'access_token', value: accessToken);
    await _storage.write(key: 'refresh_token', value: refreshToken);
  }

  Future<void> _clearTokens() async {
    await _storage.delete(key: 'access_token');
    await _storage.delete(key: 'refresh_token');
  }

  Future<void> clearTokens() => _clearTokens();

  Future<String?> getAccessToken() => _storage.read(key: 'access_token');

  Future<ApiResponse<Map<String, dynamic>>> uploadMultipart(
    String path,
    File file, {
    String fieldName = 'file',
    Map<String, String>? queryParams,
  }) async {
    final token = await _storage.read(key: 'access_token');
    var uri = Uri.parse('$_baseUrl$path');
    if (queryParams != null && queryParams.isNotEmpty) {
      uri = uri.replace(queryParameters: queryParams);
    }

    Future<http.StreamedResponse> send({String? authToken}) async {
      final req = http.MultipartRequest('POST', uri);
      if (authToken != null) {
        req.headers['Authorization'] = 'Bearer $authToken';
      }
      req.files.add(await http.MultipartFile.fromPath(fieldName, file.path));
      return req.send();
    }

    var streamed = await send(authToken: token);
    if (streamed.statusCode == 401) {
      final refreshed = await _tryRefresh();
      if (refreshed) {
        final newToken = await _storage.read(key: 'access_token');
        streamed = await send(authToken: newToken);
        if (streamed.statusCode == 401) {
          await _clearTokens();
          throw UnauthorizedException();
        }
      } else {
        await _clearTokens();
        throw UnauthorizedException();
      }
    }

    final resp = await http.Response.fromStream(streamed);
    return _parseResponse(resp);
  }
}
