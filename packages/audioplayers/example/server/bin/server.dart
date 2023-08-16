// ignore_for_file: avoid_print
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart' as shelf_router;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

import 'stream_route.dart';

Future<void> main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final requestTimeoutMillis =
      int.parse(Platform.environment['LATENCY'] ?? '0');
  final isLogRequests =
      (Platform.environment['LOG_REQUESTS'] ?? 'false') == 'true';

  final publicStaticHandler = shelf_static.createStaticHandler(
    'public',
    defaultDocument: 'index.html',
    serveFilesOutsidePath: true,
  );

  final recordMode = bool.parse(Platform.environment['RECORD_MODE'] ?? 'false');
  final liveMode =
      recordMode || bool.parse(Platform.environment['LIVE_MODE'] ?? 'false');
  final routeHandler = shelf_router.Router()
    ..mount(
      '/stream',
      StreamRoute(isLiveMode: liveMode, isRecordMode: recordMode).pipeline,
    );

  final cascade = Cascade().add(publicStaticHandler).add(routeHandler);

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

  print(
    'Serving at http://${server.address.host}:${server.port} with latency of $requestTimeoutMillis ms',
  );
}
