import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final _print = OverridePrint();
  final _logger = AudioPlayer.global;

  group('Logger', () {
    setUp(_print.clear);

    test(
      'when set to INFO everything is logged',
      _print.overridePrint(() {
        _logger.changeLogLevel(LogLevel.info);

        _logger.log(LogLevel.info, 'info');
        _logger.log(LogLevel.error, 'error');

        expect(_print.logs, [
          'AudioPlayers Log: info',
          '\x1B[31mAudioPlayers throw: error\x1B[0m',
        ]);
      }),
    );

    test(
      'when set to ERROR only errors are logged',
      _print.overridePrint(() {
        _logger.changeLogLevel(LogLevel.error);

        _logger.log(LogLevel.info, 'info');
        _logger.log(LogLevel.error, 'error');

        expect(_print.logs, [
          '\x1B[31mAudioPlayers throw: error\x1B[0m',
        ]);
      }),
    );

    test(
      'when set to NONE nothing is logged',
      _print.overridePrint(() {
        _logger.changeLogLevel(LogLevel.none);

        _logger.log(LogLevel.info, 'info');
        _logger.log(LogLevel.error, 'error');

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
