import 'package:flutter/material.dart';

class Btn extends StatelessWidget {
  final String txt;
  final VoidCallback onPressed;

  const Btn({super.key, required this.txt, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(minimumSize: const Size(48, 36)),
        onPressed: onPressed,
        child: Text(txt),
      ),
    );
  }
}
