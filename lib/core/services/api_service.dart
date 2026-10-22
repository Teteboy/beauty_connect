import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  /// Backend base URL. Defaults to the Android emulator host alias.
  /// Override at run time, e.g. for Waydroid:
  ///   flutter run --dart-define=API_URL=http://192.168.240.1:5000/api
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:5000/api',
  );

  /// Origin of the backend (no `/api` suffix) — used to resolve
  /// relative asset URLs such as `/uploads/images/x.jpg`.
  static String get serverOrigin =>
      baseUrl.substring(0, baseUrl.length - '/api'.length);

  /// Resolves a backend-provided image path to an absolute URL.
  /// Returns the input unchanged when it is already absolute or empty.
  static String? resolveImageUrl(String? url) {
    if (url == null || url.isEmpty) return url;
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.startsWith('/')) return '$serverOrigin$url';
    return url;
  }

  static String? _token;

  static String? get token => _token;
  static bool get hasToken => _token != null && _token!.isNotEmpty;

  static Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
  }

  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  static Map<String, String> get _headers {
    final headers = {
      'Content-Type': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      print('GET $endpoint - Status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('GET $endpoint error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      print('POST $endpoint - Status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('POST $endpoint error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
        body: json.encode(data),
      );

      print('PUT $endpoint - Status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('PUT $endpoint error: $e');
      throw Exception('Network error: $e');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _headers,
      );

      print('DELETE $endpoint - Status: ${response.statusCode}');
      print('Response body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('DELETE $endpoint error: $e');
      throw Exception('Network error: $e');
    }
  }

  /// Uploads an image file as base64 to `POST /upload/image`.
  /// Returns the absolute image URL on success.
  static Future<String?> uploadImage(File file) async {
    final bytes = await file.readAsBytes();
    final ext = file.path.split('.').last.toLowerCase();
    final mimeType = switch (ext) {
      'jpg' || 'jpeg' => 'image/jpeg',
      'png' => 'image/png',
      'webp' => 'image/webp',
      'gif' => 'image/gif',
      _ => 'image/jpeg',
    };
    final response = await post('/upload/image', {
      'imageBase64': base64Encode(bytes),
      'mimeType': mimeType,
    });
    final imageUrl = response['imageUrl'] as String?;
    return resolveImageUrl(imageUrl);
  }

  static Future<dynamic> postWithFile(String endpoint,
      Map<String, dynamic> data, File file, String fieldName) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // Add headers
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add form fields
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print(
          '${request.method} ${request.url} - Status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(responseBody);
      } else {
        throw Exception('HTTP ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('${endpoint} error: $e');
      throw e;
    }
  }

  static Future<dynamic> putWithFile(String endpoint, Map<String, dynamic> data,
      File file, String fieldName) async {
    try {
      final uri = Uri.parse('$baseUrl$endpoint');
      final request = http.MultipartRequest('PUT', uri);

      // Add headers
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      // Add form fields
      data.forEach((key, value) {
        request.fields[key] = value.toString();
      });

      // Add file
      final fileStream = http.ByteStream(file.openRead());
      final fileLength = await file.length();
      final multipartFile = http.MultipartFile(
        fieldName,
        fileStream,
        fileLength,
        filename: file.path.split('/').last,
        contentType: MediaType('image', 'jpeg'),
      );
      request.files.add(multipartFile);

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print(
          '${request.method} ${request.url} - Status: ${response.statusCode}');
      print('Response body: $responseBody');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return json.decode(responseBody);
      } else {
        throw Exception('HTTP ${response.statusCode}: $responseBody');
      }
    } catch (e) {
      print('${endpoint} error: $e');
      throw e;
    }
  }

  static dynamic _handleResponse(http.Response response) {
    try {
      if (response.body.isEmpty) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return {};
        }
      }

      final data = json.decode(response.body);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return data;
      } else {
        if (response.statusCode == 401) {
          throw Exception('Token expired');
        } else if (response.statusCode == 403) {
          throw Exception('Access denied');
        } else if (response.statusCode == 404) {
          throw Exception('Resource not found');
        } else if (response.statusCode == 422) {
          throw Exception(data['message'] ?? 'Validation error');
        } else if (response.statusCode == 500) {
          throw Exception('Server error. Please try again later.');
        }

        throw Exception(data['message'] ??
            'Request failed with status ${response.statusCode}');
      }
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Failed to parse response: $e');
    }
  }
}
