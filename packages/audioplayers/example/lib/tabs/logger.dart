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
      if (log.level.toInt() <= currentLogLevel.toInt()) {
        _logger.log(log.level, log.message);
        setState(() {
          globalLogs.add('${log.level.toString()}: ${log.message}');
        });
      }
    });
    widget.player.setLogHandler((log) {
      if (log.level.toInt() <= currentLogLevel.toInt()) {
        final msg = '${log.message}\nSource: ${widget.player.source}';
        _logger.log(log.level, msg);
        setState(() {
          logs.add('${log.level.toString()}: $msg');
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
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
          const Divider(color: Colors.black),
          Expanded(
            child: LogView(
              title: 'Player Logs:',
              logs: logs,
              onDelete: () => setState(() {
                logs.clear();
              }),
            ),
          ),
          const Divider(color: Colors.black),
          Expanded(
            child: LogView(
              title: 'Global Logs:',
              logs: globalLogs,
              onDelete: () => setState(() {
                globalLogs.clear();
              }),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class LogView extends StatelessWidget {
  final String title;
  final List<String> logs;
  final VoidCallback onDelete;

  const LogView({
    super.key,
    required this.logs,
    required this.title,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete))
          ],
        ),
        Expanded(
          child: ListView(
            children: logs
                .map(
                  (s) => Column(
                    children: [
                      SelectableText(
                        s,
                      ),
                      Divider(color: Colors.grey.shade400)
                    ],
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }
}
