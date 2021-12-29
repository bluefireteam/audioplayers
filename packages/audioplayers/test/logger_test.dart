import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const _channel = MethodChannel('plugins.flutter.io/path_provider');
  _channel.setMockMethodCallHandler((c) async => '/tmp');

  const channel = MethodChannel('xyz.luan/audioplayers');
  channel.setMockMethodCallHandler((MethodCall call) async => 1);

  final _print = OverridePrint();

  group('Logger', () {
    setUp(_print.clear);
    test('when set to INFO everything is logged', _print.overridePrint(() {
      Logger.changeLogLevel(LogLevel.INFO);
      Logger.log(LogLevel.INFO, 'info');
      Logger.log(LogLevel.ERROR, 'error');

      expect(_print.log, ['info', 'error']);
    }));
    test('when set to ERROR only errors are logged', _print.overridePrint(() {
      Logger.changeLogLevel(LogLevel.ERROR);
      Logger.log(LogLevel.INFO, 'info');
      Logger.log(LogLevel.ERROR, 'error');

      expect(_print.log, ['error']);
    }));
    test('when set to NONE nothing is logged', _print.overridePrint(() {
      Logger.changeLogLevel(LogLevel.NONE);
      Logger.log(LogLevel.INFO, 'info');
      Logger.log(LogLevel.ERROR, 'error');

      expect(_print.log, <String>[]);
    }));
  });
}

class OverridePrint {
  final log = <String>[];

  void clear() => log.clear();

  void Function() overridePrint(void Function() testFn) {
    return () {
      final spec = ZoneSpecification(print: (_, __, ___, String msg) {
        // Add to log instead of printing to stdout
        log.add(msg);
      });
      return Zone.current.fork(specification: spec).run<void>(testFn);
    };
  }
}
