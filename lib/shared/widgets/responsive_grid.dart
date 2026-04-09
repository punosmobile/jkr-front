import 'package:flutter/material.dart';

class ResponsiveGrid extends StatelessWidget {
  final double minChildWidth;
  final double spacing;
  final List<Widget> children;

  const ResponsiveGrid({
    super.key,
    required this.minChildWidth,
    this.spacing = 10,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = (width / minChildWidth).floor().clamp(1, children.length);

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children.map((child) {
            final childWidth = (width - spacing * (columns - 1)) / columns;
            return SizedBox(width: childWidth, child: child);
          }).toList(),
        );
      },
    );
  }
}
