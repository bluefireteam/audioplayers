import 'package:flutter/material.dart';

class Cbx extends StatelessWidget {
  final String label;
  final bool value;
  final void Function({required bool? value}) update;

  const Cbx(
    this.label,
    this.update, {
    required this.value,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: (v) => update(value: v),
    );
  }
}
