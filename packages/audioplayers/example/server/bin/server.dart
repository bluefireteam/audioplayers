// ignore_for_file: avoid_print
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

Future<void> main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final requestTimeoutMillis =
      int.parse(Platform.environment['LATENCY'] ?? '0');
  final isLogRequests =
      (Platform.environment['LOG_REQUESTS'] ?? 'false') == 'true';

  final cascade = Cascade().add(_staticHandler);

  var pipeline = const Pipeline();
  if (isLogRequests) {
    pipeline = pipeline.addMiddleware(logRequests());
  }

  final handler = pipeline
      .addMiddleware(
        (innerHandler) => (req) async {
          await Future<void>.delayed(
            Duration(milliseconds: requestTimeoutMillis),
          );
          return await innerHandler(req);
        },
      )
      .addHandler(cascade.handler);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.loopbackIPv4,
    port,
  );

  // TODO(Gustl22): provide an audio streaming endpoint:
  // Inspiration: https://github.com/daspinola/video-stream-sample/blob/master/server.js

  print(
    'Serving at http://${server.address.host}:${server.port} with latency of $requestTimeoutMillis ms',
  );
}

final _staticHandler = shelf_static.createStaticHandler(
  'public',
  defaultDocument: 'index.html',
  serveFilesOutsidePath: true,
);
