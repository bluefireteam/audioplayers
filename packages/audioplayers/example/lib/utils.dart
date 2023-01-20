import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers_example/components/dlg.dart';
import 'package:flutter/material.dart';

extension StateExt<T extends StatefulWidget> on State<T> {
  void toast(String message, {Key? textKey}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, key: textKey),
        duration: const Duration(milliseconds: 250),
      ),
    );
  }

  void simpleDialog(String message, [String action = 'Ok']) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return SimpleDlg(message: message, action: action);
      },
    );
  }

  void dialog(Widget child) {
    showDialog<void>(
      context: context,
      builder: (_) {
        return Dlg(child: child);
      },
    );
  }
}

extension PlayerStateIcon on PlayerState {
  IconData getIcon() {
    return this == PlayerState.playing
        ? Icons.play_arrow
        : (this == PlayerState.paused
            ? Icons.pause
            : (this == PlayerState.stopped ? Icons.stop : Icons.stop_circle));
  }
}
