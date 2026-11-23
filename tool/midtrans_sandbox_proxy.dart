// ignore_for_file: avoid_print
import 'dart:convert';
import 'dart:io';

/// Proxy CORS ringan untuk menghubungkan FinPay (Flutter Web / Chrome)
/// ke Midtrans Sandbox API (`app.sandbox.midtrans.com` & `api.sandbox.midtrans.com`).
///
/// Cara menjalankan:
/// ```bash
/// dart run tool/midtrans_sandbox_proxy.dart
/// ```
Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? (int.tryParse(args.first) ?? 8787) : 8787;
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print(
    '[FinPay Midtrans Proxy] Aktif di http://localhost:$port -> Midtrans Sandbox API',
  );

  final httpClient = HttpClient()
    ..connectionTimeout = const Duration(seconds: 10);

  await for (final request in server) {
    _applyCorsHeaders(request.response);

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.noContent;
      await request.response.close();
      continue;
    }

    try {
      final path = request.uri.path;
      late final Uri targetUri;
      if (path.startsWith('/snap/')) {
        targetUri = Uri.parse('https://app.sandbox.midtrans.com$path');
      } else if (path.startsWith('/v2/')) {
        targetUri = Uri.parse('https://api.sandbox.midtrans.com$path');
      } else {
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.json;
        request.response.write(
          jsonEncode({
            'status': 'ok',
            'service': 'FinPay Midtrans Sandbox CORS Proxy',
          }),
        );
        await request.response.close();
        continue;
      }

      final outbound = await httpClient.openUrl(request.method, targetUri);
      final authHeader = request.headers.value(HttpHeaders.authorizationHeader);
      if (authHeader != null && authHeader.isNotEmpty) {
        outbound.headers.set(HttpHeaders.authorizationHeader, authHeader);
      }
      outbound.headers.set(HttpHeaders.acceptHeader, 'application/json');
      outbound.headers.set(HttpHeaders.contentTypeHeader, 'application/json');

      if (request.method == 'POST' || request.method == 'PUT') {
        final bodyBytes = await request.fold<List<int>>(
          <int>[],
          (prev, chunk) => prev..addAll(chunk),
        );
        outbound.add(bodyBytes);
      }

      final upstream = await outbound.close();
      final responseBody = await utf8.decoder.bind(upstream).join();

      request.response.statusCode = upstream.statusCode;
      request.response.headers.contentType = ContentType.json;
      request.response.write(responseBody);
      await request.response.close();

      print(
        '[FinPay Midtrans Proxy] ${request.method} $path -> ${upstream.statusCode}',
      );
    } catch (e) {
      request.response.statusCode = HttpStatus.badGateway;
      request.response.headers.contentType = ContentType.json;
      request.response.write(jsonEncode({'error': e.toString()}));
      await request.response.close();
    }
  }
}

void _applyCorsHeaders(HttpResponse response) {
  response.headers.set('Access-Control-Allow-Origin', '*');
  response.headers.set(
    'Access-Control-Allow-Methods',
    'GET, POST, PUT, OPTIONS',
  );
  response.headers.set(
    'Access-Control-Allow-Headers',
    'Origin, Content-Type, Accept, Authorization',
  );
}
