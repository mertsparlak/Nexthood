/// API istemcisi — Backend ile iletişim katmanı.
///
/// Şu an [useMock] = true ile çalışır (backend bağlantısı kurulana kadar).
/// Backend hazır olduğunda [baseUrl] ve [useMock] = false yapılır.
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  // Backend bağlantısı kurulduğunda burası güncellenir
  String baseUrl = 'http://10.0.2.2:8000/api/v1'; // Android emulator → localhost
  String? _token;
  bool useMock = true; // TODO: Backend entegrasyonunda false yapılacak

  void setToken(String token) => _token = token;
  void clearToken() => _token = null;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  /// POST isteği gönderir. [useMock] = true ise sessizce başarılı döner.
  Future<Map<String, dynamic>?> post(String path, Map<String, dynamic> body) async {
    if (useMock) return {'status': 'mock_ok'};

    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    }
    return null;
  }

  /// GET isteği gönderir. [useMock] = true ise null döner.
  Future<Map<String, dynamic>?> get(String path) async {
    if (useMock) return null;

    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  /// GET isteği — liste döner.
  Future<List<dynamic>?> getList(String path) async {
    if (useMock) return null;

    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    return null;
  }

  /// PATCH isteği gönderir.
  Future<Map<String, dynamic>?> patch(String path, [Map<String, dynamic>? body]) async {
    if (useMock) return {'status': 'mock_ok'};

    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: body != null ? jsonEncode(body) : null,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.body.isNotEmpty ? jsonDecode(response.body) : null;
    }
    return null;
  }
}
