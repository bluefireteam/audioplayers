import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../components/btn.dart';
import '../components/tab_wrapper.dart';

class GlobalTab extends StatefulWidget {
  const GlobalTab({Key? key}) : super(key: key);

  @override
  _GlobalTabState createState() => _GlobalTabState();
}

class _GlobalTabState extends State<GlobalTab> {
  static LoggerPlatformInterface get _logger =>
      LoggerPlatformInterface.instance;

  LogLevel currentLogLevel = _logger.logLevel;

  @override
  Widget build(BuildContext context) {
    return TabWrapper(
      children: [
        Text('Log Level: $currentLogLevel'),
        Row(
          children: LogLevel.values
              .map(
                (e) => Btn(
                  txt: e.toString(),
                  onPressed: () async {
                    await _logger.changeLogLevel(e);
                    setState(() => currentLogLevel = _logger.logLevel);
                  },
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
