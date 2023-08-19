import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/btn.dart';
import 'package:flutter/material.dart';

class LoggerTab extends StatefulWidget {
  final AudioPlayer player;

  const LoggerTab({
    required this.player,
    super.key,
  });

  @override
  LoggerTabState createState() => LoggerTabState();
}

class LoggerTabState extends State<LoggerTab>
    with AutomaticKeepAliveClientMixin<LoggerTab> {
  AudioLogLevel get currentLogLevel => AudioLogger.logLevel;

  set currentLogLevel(AudioLogLevel level) {
    AudioLogger.logLevel = level;
  }

  List<Log> logs = [];
  List<Log> globalLogs = [];

  @override
  void initState() {
    super.initState();
    AudioPlayer.global.onLog.listen(
      (message) {
        if (AudioLogLevel.info.level <= currentLogLevel.level) {
          setState(() {
            globalLogs.add(Log(message, level: AudioLogLevel.info));
          });
        }
      },
      onError: (Object o, [StackTrace? stackTrace]) {
        if (AudioLogLevel.error.level <= currentLogLevel.level) {
          setState(() {
            globalLogs.add(
              Log(
                AudioLogger.errorToString(o, stackTrace),
                level: AudioLogLevel.error,
              ),
            );
          });
        }
      },
    );
    widget.player.onLog.listen(
      (message) {
        if (AudioLogLevel.info.level <= currentLogLevel.level) {
          final msg = '$message\nSource: ${widget.player.source}';
          setState(() {
            logs.add(Log(msg, level: AudioLogLevel.info));
          });
        }
      },
      onError: (Object o, [StackTrace? stackTrace]) {
        if (AudioLogLevel.error.level <= currentLogLevel.level) {
          setState(() {
            logs.add(
              Log(
                AudioLogger.errorToString(
                  AudioPlayerException(widget.player, cause: o),
                  stackTrace,
                ),
                level: AudioLogLevel.error,
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
            children: AudioLogLevel.values
                .map(
                  (level) => Btn(
                    txt: level.toString().replaceAll('AudioLogLevel.', ''),
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
    required this.logs,
    required this.title,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
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
                        style: log.level == AudioLogLevel.error
                            ? const TextStyle(color: Colors.red)
                            : null,
                      ),
                      Divider(color: Colors.grey.shade400),
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

  final AudioLogLevel level;
  final String message;
}
