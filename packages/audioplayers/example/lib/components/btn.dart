import 'package:flutter/material.dart';

class Btn extends StatelessWidget {
  final String txt;
  final VoidCallback onPressed;

  const Btn({super.key, required this.txt, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ButtonTheme(
      minWidth: 48.0,
      child: ElevatedButton(
        onPressed: onPressed,
        child: Text(txt),
      ),
    );
  }
}
