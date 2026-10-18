import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Error shown to the user when an API call fails. [isOffline] lets the UI
/// show a "check your connection" message instead of a generic one.
class ApiException implements Exception {
  final String message;
  final bool isOffline;

  const ApiException(this.message, {this.isOffline = false});

  @override
  String toString() => message;
}

/// Thin wrapper around [http.Client] that every service uses, so timeouts,
/// status codes and offline errors are handled the same way everywhere.
class ApiClient {
  final http.Client _client;
  final Duration timeout;

  ApiClient(this._client, {this.timeout = const Duration(seconds: 12)});

  Future<Map<String, dynamic>> getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(timeout);
    } on TimeoutException {
      throw const ApiException(
        'The server took too long to answer. Please try again.',
        isOffline: true,
      );
    } on http.ClientException {
      // http wraps SocketException (no network, DNS failure) in ClientException.
      throw const ApiException(
        'No internet connection. Check your data or Wi-Fi and try again.',
        isOffline: true,
      );
    }

    if (response.statusCode != 200) {
      throw ApiException('Server error (${response.statusCode}).');
    }
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } on FormatException {
      throw const ApiException('The server sent data we could not read.');
    }
  }

  void close() => _client.close();
}
