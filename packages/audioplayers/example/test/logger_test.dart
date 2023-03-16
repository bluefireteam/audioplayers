import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final _print = OverridePrint();

  group('Logger', () {
    setUp(_print.clear);

    test(
      'when set to INFO everything is logged',
      _print.overridePrint(() {
        Logger.logLevel = LogLevel.info;

        Logger.log('info');
        Logger.error('error');

        expect(_print.logs, [
          'AudioPlayers Log: info',
          '\x1B[31mAudioPlayers throw: error\x1B[0m',
        ]);
      }),
    );

    test(
      'when set to ERROR only errors are logged',
      _print.overridePrint(() {
        Logger.logLevel = LogLevel.error;

        Logger.log('info');
        Logger.error('error');

        expect(_print.logs, [
          '\x1B[31mAudioPlayers throw: error\x1B[0m',
        ]);
      }),
    );

    test(
      'when set to NONE nothing is logged',
      _print.overridePrint(() {
        Logger.logLevel = LogLevel.none;

        Logger.log('info');
        Logger.error('error');

        expect(_print.logs, <String>[]);
      }),
    );
  });
}

class OverridePrint {
  final logs = <String>[];

  void clear() => logs.clear();

  void Function() overridePrint(void Function() testFn) {
    return () {
      final spec = ZoneSpecification(
        print: (_, __, ___, String msg) {
          // Add to log instead of printing to stdout
          logs.add(msg);
        },
      );
      return Zone.current.fork(specification: spec).run<void>(testFn);
    };
  }
}
