import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/btn.dart';
import 'package:flutter/material.dart';

class LoggerTab extends StatefulWidget {
  final AudioPlayer player;

  const LoggerTab({super.key, required this.player});

  @override
  _LoggerTabState createState() => _LoggerTabState();
}

class _LoggerTabState extends State<LoggerTab>
    with AutomaticKeepAliveClientMixin<LoggerTab> {
  static Logger get _logger => AudioPlayer.logger;

  LogLevel currentLogLevel = _logger.logLevel;

  List<String> logs = [];
  List<String> globalLogs = [];

  @override
  void initState() {
    super.initState();
    AudioPlayer.setGlobalLogHandler((log) {
      _logger.log(log.level, log.message);
      setState(() {
        globalLogs.add('${log.level.toString()}: ${log.message}');
      });
    });
    widget.player.setLogHandler((log) {
      final msg = '${log.message}\nSource: ${widget.player.source}';
      _logger.log(log.level, msg);
      setState(() {
        logs.add('${log.level.toString()}: $msg');
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Log Level: $currentLogLevel'),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: LogLevel.values
              .map(
                (level) => Btn(
                  txt: level.toString().replaceAll('LogLevel.', ''),
                  onPressed: () {
                    _logger.logLevel = level;
                    setState(() => currentLogLevel = _logger.logLevel);
                  },
                ),
              )
              .toList(),
        ),
        const Text('Global Logs:'),
        Expanded(
          child: ListView(
            children: globalLogs.map(Text.new).toList(),
          ),
        ),
        const Text('Player Logs:'),
        Expanded(
          child: ListView(
            children: logs.map(Text.new).toList(),
          ),
        ),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
