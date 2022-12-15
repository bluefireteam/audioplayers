// Copyright (c) 2021, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

@Tags(['presubmit-only'])
import 'package:test/test.dart';

import 'test_definitions.dart';

void main() {
  void testServer(String name, Future<void> Function(String host) func) {
    test(
      name,
      () async {
        await func('http://localhost:8080');
      },
      timeout: _defaultTimeout,
    );
  }

  runTests(testServer);
}

const _defaultTimeout = Timeout(Duration(seconds: 3));
