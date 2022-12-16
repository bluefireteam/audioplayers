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

  final cascade = Cascade().add(_staticHandler);

  final server = await shelf_io.serve(
    logRequests().addHandler(cascade.handler),
    InternetAddress.loopbackIPv4,
    port,
  );

  print('Serving at http://${server.address.host}:${server.port}');
}

// Serve files from the file system.
final _staticHandler = shelf_static.createStaticHandler(
  'public',
  defaultDocument: 'index.html',
  serveFilesOutsidePath: true,
);
