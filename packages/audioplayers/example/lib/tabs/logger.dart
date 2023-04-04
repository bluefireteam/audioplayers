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
  LogLevel get currentLogLevel => Logger.logLevel;

  set currentLogLevel(LogLevel level) {
    Logger.logLevel = level;
  }

  List<Log> logs = [];
  List<Log> globalLogs = [];

  @override
  void initState() {
    super.initState();
    AudioPlayer.global.onLog.listen(
      (message) {
        if (LogLevel.info.level <= currentLogLevel.level) {
          setState(() {
            globalLogs.add(Log(message, level: LogLevel.info));
          });
        }
      },
      onError: (Object o, [StackTrace? stackTrace]) {
        if (LogLevel.error.level <= currentLogLevel.level) {
          setState(() {
            globalLogs.add(
              Log(Logger.errorToString(o, stackTrace), level: LogLevel.error),
            );
          });
        }
      },
    );
    widget.player.onLog.listen(
      (message) {
        if (LogLevel.info.level <= currentLogLevel.level) {
          final msg = '$message\nSource: ${widget.player.source}';
          setState(() {
            logs.add(Log(msg, level: LogLevel.info));
          });
        }
      },
      onError: (Object o, [StackTrace? stackTrace]) {
        if (LogLevel.error.level <= currentLogLevel.level) {
          setState(() {
            logs.add(
              Log(
                Logger.errorToString(
                  AudioPlayerException(widget.player, cause: o),
                  stackTrace,
                ),
                level: LogLevel.error,
              ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SelectableText(
                        '${log.level}: ${log.message}',
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

class Log {
  Log(this.message, {required this.level});

  final LogLevel level;
  final String message;
}
