import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/utils.dart';
import 'package:flutter/material.dart';

class PropertiesWidget extends StatefulWidget {
  final AudioPlayer player;

  const PropertiesWidget({super.key, required this.player});

  @override
  State<PropertiesWidget> createState() => _PropertiesWidgetState();
}

class _PropertiesWidgetState extends State<PropertiesWidget> {
  Future<void> refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          title: const Text('Properties'),
          trailing: ElevatedButton.icon(
            icon: const Icon(Icons.refresh),
            key: const Key('refreshButton'),
            label: const Text('Refresh'),
            onPressed: refresh,
          ),
        ),
        ListTile(
          title: FutureBuilder<Duration?>(
            future: widget.player.getDuration(),
            builder: (context, snap) {
              return Text(
                snap.data?.toString() ?? '-',
                key: const Key('durationText'),
              );
            },
          ),
          subtitle: const Text('Duration'),
          leading: const Icon(Icons.timelapse),
        ),
        ListTile(
          title: FutureBuilder<Duration?>(
            future: widget.player.getPosition(),
            builder: (context, snap) {
              return Text(
                snap.data?.toString() ?? '-',
                key: const Key('positionText'),
              );
            },
          ),
          subtitle: const Text('Position'),
          leading: const Icon(Icons.timer),
        ),
        ListTile(
          title: Text(
            widget.player.state.toString(),
            key: const Key('playerStateText'),
          ),
          subtitle: const Text('State'),
          leading: Icon(widget.player.state.getIcon()),
        ),
        ListTile(
          title: Text(
            widget.player.source?.toString() ?? '-',
            key: const Key('sourceText'),
          ),
          subtitle: const Text('Source'),
          leading: const Icon(Icons.audio_file),
        ),
      ],
    );
  }
}
