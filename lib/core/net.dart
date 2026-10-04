import 'dart:async';
import 'dart:convert';
import 'dart:io';

/// Thin HTTP layer built on dart:io so the app needs no third party
/// networking package and can talk to the public endpoints that the
/// akshare library wraps (Eastmoney / Sina / fund.eastmoney ...).
class Net {
  Net._();

  static const String userAgent =
      'Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 '
      '(KHTML, like Gecko) Chrome/124.0.0.0 Mobile Safari/537.36';

  static final HttpClient _client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 12);

  static Future<String?> text(
    String url, {
    String? referer,
    Duration timeout = const Duration(seconds: 12),
    String? encoding,
  }) async {
    try {
      final Uri uri = Uri.parse(url);
      final HttpClientRequest request =
          await _client.getUrl(uri).timeout(timeout);
      request.headers.set(HttpHeaders.userAgentHeader, userAgent);
      request.headers.set(HttpHeaders.acceptHeader, 'application/json, text/plain, */*');
      request.headers.set(HttpHeaders.acceptLanguageHeader, 'zh-CN,zh;q=0.9');
      if (referer != null) {
        request.headers.set(HttpHeaders.refererHeader, referer);
      }
      final HttpClientResponse response =
          await request.close().timeout(timeout);
      if (response.statusCode != 200) {
        return null;
      }
      final List<int> bytes = <int>[];
      await for (final List<int> chunk in response) {
        bytes.addAll(chunk);
      }
      if (encoding == 'gbk') {
        return _decodeGbk(bytes);
      }
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return null;
    }
  }

  static Future<Map<String, dynamic>?> json(
    String url, {
    String? referer,
    Duration timeout = const Duration(seconds: 12),
  }) async {
    final String? body = await text(url, referer: referer, timeout: timeout);
    if (body == null) return null;
    return parseJsonObject(body);
  }

  static Map<String, dynamic>? parseJsonObject(String body) {
    final int start = body.indexOf('{');
    final int end = body.lastIndexOf('}');
    if (start < 0 || end <= start) return null;
    final String slice = body.substring(start, end + 1);
    try {
      final Object? decoded = jsonDecode(slice);
      if (decoded is Map<String, dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }

  static List<dynamic>? parseJsonArray(String body) {
    final int start = body.indexOf('[');
    final int end = body.lastIndexOf(']');
    if (start < 0 || end <= start) return null;
    final String slice = body.substring(start, end + 1);
    try {
      final Object? decoded = jsonDecode(slice);
      if (decoded is List<dynamic>) return decoded;
    } catch (_) {
      return null;
    }
    return null;
  }

  /// Minimal GBK decoder good enough for Sina quote payloads.
  static String _decodeGbk(List<int> bytes) {
    try {
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return '';
    }
  }
}
