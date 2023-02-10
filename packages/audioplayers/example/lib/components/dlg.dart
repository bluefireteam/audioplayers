import 'package:audioplayers_example/components/btn.dart';
import 'package:flutter/material.dart';

class SimpleDlg extends StatelessWidget {
  final String message, action;

  const SimpleDlg({
    super.key,
    required this.message,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Dlg(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message),
          Btn(
            txt: action,
            onPressed: Navigator.of(context).pop,
          ),
        ],
      ),
    );
  }
}

class Dlg extends StatelessWidget {
  final Widget child;

  const Dlg({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      elevation: 0,
      backgroundColor: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(16.0),
        child: contentBox(context),
      ),
    );
  }

  Widget contentBox(BuildContext context) {
    return child;
  }
}
