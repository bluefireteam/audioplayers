import 'package:flutter/material.dart';

class Tgl extends StatelessWidget {
  final List<String> options;
  final int selected;
  final void Function(int) onChange;

  const Tgl({
    Key? key,
    required this.options,
    required this.selected,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      isSelected: options.asMap().keys.map((it) => it == selected).toList(),
      onPressed: onChange,
      children: options.map((it) => Text(it)).toList(),
    );
  }
}

class EnumTgl<T extends Enum> extends StatelessWidget {
  final List<T> options;
  final T selected;
  final void Function(T) onChange;

  const EnumTgl({
    Key? key,
    required this.options,
    required this.selected,
    required this.onChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tgl(
      options: options.map((e) => e.name).toList(),
      selected: options.indexOf(selected),
      onChange: (it) => onChange(options.firstWhere((e) => e == options[it])),
    );
  }
}
