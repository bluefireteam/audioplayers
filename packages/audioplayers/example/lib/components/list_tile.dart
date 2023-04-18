import 'package:flutter/material.dart';

class WrappedListTile extends StatelessWidget {
  final List<Widget> children;
  final Widget? leading;
  final Widget? trailing;

  const WrappedListTile({
    required this.children,
    this.leading,
    this.trailing,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Wrap(
        alignment: WrapAlignment.end,
        children: children,
      ),
      leading: leading,
      trailing: trailing,
    );
  }
}
