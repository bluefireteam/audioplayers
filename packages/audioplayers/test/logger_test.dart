import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final printZone = OverridePrint();

  group('Logger', () {
    setUp(printZone.clear);

    test(
      'when set to INFO everything is logged',
      printZone.overridePrint(() {
        AudioLogger.logLevel = AudioLogLevel.info;

        AudioLogger.log('info');
        AudioLogger.error('error');

        expect(printZone.logs, [
          'AudioPlayers Log: info',
          '\x1B[31mAudioPlayers throw: error\x1B[0m',
        ]);
      }),
    );

    test(
      'when set to ERROR only errors are logged',
      printZone.overridePrint(() {
        AudioLogger.logLevel = AudioLogLevel.error;

        AudioLogger.log('info');
        AudioLogger.error('error');

        expect(printZone.logs, [
          '\x1B[31mAudioPlayers throw: error\x1B[0m',
        ]);
      }),
    );

    test(
      'when set to NONE nothing is logged',
      printZone.overridePrint(() {
        AudioLogger.logLevel = AudioLogLevel.none;

        AudioLogger.log('info');
        AudioLogger.error('error');

        expect(printZone.logs, <String>[]);
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
