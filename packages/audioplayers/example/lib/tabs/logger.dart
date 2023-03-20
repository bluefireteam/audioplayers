import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/btn.dart';
import 'package:audioplayers_example/components/tab_content.dart';
import 'package:flutter/material.dart';

class LoggerTab extends StatefulWidget {
  const LoggerTab({super.key});

  @override
  _LoggerTabState createState() => _LoggerTabState();
}

class _LoggerTabState extends State<LoggerTab> {
  static GlobalAudioScope get _logger => AudioPlayer.global;

  LogLevel currentLogLevel = _logger.logLevel;

  @override
  Widget build(BuildContext context) {
    return TabContent(
      children: [
        ListTile(
          title: Text(currentLogLevel.toString()),
          subtitle: const Text('Log Level'),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: LogLevel.values
              .map(
                (e) => Btn(
                  txt: e.toString().replaceAll('LogLevel.', ''),
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
