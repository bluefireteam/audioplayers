// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:http/http.dart';
import 'package:test/test.dart';

void runTests(
  void Function(String name, Future<void> Function(String host)) testServer,
) {
  testServer('root', (host) async {
    final response = await get(Uri.parse(host));
    expect(response.statusCode, 200);
    expect(response.body, contains('pkg:shelf example'));
    expect(response.headers, contains('last-modified'));
    expect(response.headers, contains('date'));
    expect(response.headers, containsPair('content-type', 'text/html'));
  });

  testServer('404', (host) async {
    var response = await get(Uri.parse('$host/not_here'));
    expect(response.statusCode, 404);
    expect(response.body, 'Route not found');

    response = await post(Uri.parse(host));
    // https://github.com/dart-lang/shelf_static/issues/53 - should 405
    expect(response.statusCode, 200);
    expect(response.body, contains('pkg:shelf example'));
  });
}
