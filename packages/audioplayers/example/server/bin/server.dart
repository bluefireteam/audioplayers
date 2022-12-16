// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart' as shelf_static;

Future<void> main() async {
  // If the "PORT" environment variable is set, listen to it. Otherwise, 8080.
  // https://cloud.google.com/run/docs/reference/container-contract#port
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final requestTimeoutMillis =
      int.parse(Platform.environment['REQUEST_TIMEOUT'] ?? '0');

  final cascade = Cascade().add(_staticHandler);

  final handler = const Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(
        (innerHandler) => ((req) async {
          await Future.delayed(Duration(milliseconds: requestTimeoutMillis));
          return await innerHandler(req);
        }),
      )
      .addHandler(cascade.handler);

  final server = await shelf_io.serve(
    handler,
    InternetAddress.loopbackIPv4,
    port,
  );

  // TODO(Gustl22): provide an audio streaming endpoint:
  // Inspiration: https://github.com/daspinola/video-stream-sample/blob/master/server.js

  print('Serving at http://${server.address.host}:${server.port}');
}

// Serve files from the file system.
final _staticHandler = shelf_static.createStaticHandler(
  'public',
  defaultDocument: 'index.html',
  serveFilesOutsidePath: true,
);
