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

  LogLevel currentLogLevel = LogLevel.info;

  List<Log> logs = [];
  List<Log> globalLogs = [];

  @override
  void initState() {
    super.initState();
    AudioPlayer.setGlobalLogHandler(
      (log) {
        _logger.log(log);
        if (LogLevel.info.toInt() <= currentLogLevel.toInt()) {
          setState(() {
            globalLogs.add(Log(log, level: LogLevel.info));
          });
        }
      },
      onError: (Object o) {
        _logger.error(o);
        if (LogLevel.error.toInt() <= currentLogLevel.toInt()) {
          setState(() {
            globalLogs.add(Log(Logger.errorToString(o), level: LogLevel.error));
          });
        }
      },
    );
    widget.player.setLogHandler(
      (log) {
        _logger.log(log);
        if (LogLevel.info.toInt() <= currentLogLevel.toInt()) {
          final msg = '$log\nSource: ${widget.player.source}';
          setState(() {
            logs.add(Log(msg, level: LogLevel.info));
          });
        }
      },
      onError: (Object o) {
        _logger.error(o);
        if (LogLevel.error.toInt() <= currentLogLevel.toInt()) {
          setState(() {
            globalLogs.add(
              Log(
                  Logger.errorToString(
                    AudioPlayerException(widget.player, cause: o),
                  ),
                  level: LogLevel.error),
            );
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ListTile(
            title: Text(currentLogLevel.toString()),
            subtitle: const Text('Log Level'),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: LogLevel.values
                .map(
                  (level) => Btn(
                    txt: level.toString().replaceAll('LogLevel.', ''),
                    onPressed: () {
                      setState(() => currentLogLevel = level);
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
  final List<Log> logs;
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
                  (log) => Column(
                    children: [
                      SelectableText(
                        '${log.level.toString()}: ${log.message}',
                        style: log.level == LogLevel.error
                            ? const TextStyle(color: Colors.red)
                            : null,
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

enum LogLevel { info, error, none }

class Log {
  Log(this.message, {required this.level});

  final LogLevel level;
  final String message;
}

extension LogLevelExtension on LogLevel {
  int toInt() {
    switch (this) {
      case LogLevel.info:
        return 2;
      case LogLevel.error:
        return 1;
      case LogLevel.none:
        return 0;
    }
  }

  static LogLevel fromInt(int level) {
    switch (level) {
      case 2:
        return LogLevel.info;
      case 1:
        return LogLevel.error;
      default:
        return LogLevel.none;
    }
  }
}
