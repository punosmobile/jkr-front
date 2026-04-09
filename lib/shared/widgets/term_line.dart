import 'package:flutter/material.dart';

class TermLine extends StatelessWidget {
  final Color color;
  final String text;
  const TermLine({super.key, required this.color, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'DM Mono',
          color: color,
          height: 1.6,
        ),
      ),
    );
  }
}
