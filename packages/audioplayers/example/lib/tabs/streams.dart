import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

import '../components/btn.dart';
import '../components/tab_wrapper.dart';

class StreamsTab extends StatefulWidget {
  final AudioPlayer player;

  const StreamsTab({Key? key, required this.player}) : super(key: key);

  @override
  State<StreamsTab> createState() => _StreamsTabState();
}

class _StreamsTabState extends State<StreamsTab> {
  int? position, duration;

  void getPosition() async {
    final position = await widget.player.getCurrentPosition();
    setState(() => this.position = position);
  }

  void getDuration() async {
    final duration = await widget.player.getDuration();
    setState(() => this.duration = duration);
  }

  @override
  Widget build(BuildContext context) {
    return TabWrapper(
      children: [
        Row(
          children: [
            Btn(
              txt: 'getPosition',
              onPressed: getPosition,
            ),
            Text(position?.toString() ?? '-'),
          ],
        ),
        Row(
          children: [
            Btn(
              txt: 'getDuration',
              onPressed: getDuration,
            ),
            Text(duration?.toString() ?? '-'),
          ],
        ),
        // streams
      ],
    );
  }
}
