import "dart:convert";
import "package:http/http.dart" as http;
import "package:flutter_secure_storage/flutter_secure_storage.dart";
import "../config.dart";

class Api {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: "access_token", value: token);
  }

  static Future<String?> getToken() async {
    return _storage.read(key: "access_token");
  }

  static Uri _url(String path) => Uri.parse("${AppConfig.baseUrl}$path");

  static Future<http.Response> post(String path, Map<String, dynamic> body,
      {bool auth = false}) async {
    final headers = <String, String>{
      "Content-Type": "application/json",
    };

    if (auth) {
      final token = await getToken();
      if (token != null) headers["Authorization"] = "Bearer $token";
    }

    return http.post(_url(path), headers: headers, body: jsonEncode(body));
  }

  static Future<http.Response> get(String path, {bool auth = false}) async {
    final headers = <String, String>{};

    if (auth) {
      final token = await getToken();
      if (token != null) headers["Authorization"] = "Bearer $token";
    }

    return http.get(_url(path), headers: headers);
  }

  static Future<void> clearToken() async {
  await _storage.delete(key: "access_token");
}

  static Future put(String path, Map body, {bool auth = false}) async {
    final headers = {
      "Content-Type": "application/json",
    };

    if (auth) {
      final token = await getToken();
      if (token != null) headers["Authorization"] = "Bearer $token";
    }

    return http.put(_url(path), headers: headers, body: jsonEncode(body));
}

  static Future delete(String path, {bool auth = false}) async {
    final headers = <String, String>{};

    if (auth) {
      final token = await getToken();
      if (token != null) headers['Authorization'] = 'Bearer $token';
    }

    return http.delete(_url(path), headers: headers);
  }

}
