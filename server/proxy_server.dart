import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final server = await HttpServer.bind('localhost', 8080);
  print('Proxy server running on http://localhost:8080');

  await for (HttpRequest request in server) {
    // Enable CORS
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS');
    request.response.headers.add('Access-Control-Allow-Headers', 'Content-Type');

    if (request.method == 'OPTIONS') {
      await request.response.close();
      continue;
    }

    try {
      // Get the target URL from query parameter
      final targetUrl = request.uri.queryParameters['url'];

      if (targetUrl == null) {
        request.response.statusCode = 400;
        request.response.write('Missing url parameter');
        await request.response.close();
        continue;
      }

      print('Proxying request to: $targetUrl');

      // Make the request to MangaDex API
      final response = await http.get(
        Uri.parse(targetUrl),
        headers: {'User-Agent': 'komikap/1.0'},
      ).timeout(const Duration(seconds: 10));

      // Forward the response
      request.response.statusCode = response.statusCode;
      request.response.headers.contentType = ContentType.json;
      request.response.write(response.body);
    } catch (e) {
      print('Error: $e');
      request.response.statusCode = 500;
      request.response.write(jsonEncode({'error': e.toString()}));
    }

    await request.response.close();
  }
}
