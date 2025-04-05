import 'package:flutter/material.dart';

class TextLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;
  final TextStyle? linkStyle;
  final String? semanticLabel;

  const TextLink({
    required this.text,
    required this.linkText,
    required this.onTap,
    this.linkStyle,
    this.semanticLabel,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          text,
          style: const TextStyle(color: Colors.black87, fontSize: 15),
        ),
        GestureDetector(
          onTap: onTap,
          child: Text(
            linkText,
            style: linkStyle ?? const TextStyle(
              color: Colors.blueAccent,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
            semanticsLabel: semanticLabel,
          ),
        ),
      ],
    );
  }
}