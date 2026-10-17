import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Small outlined label showing a place type in its map color.
class TypeChip extends StatelessWidget {
  final String type;

  const TypeChip({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final color = colorForType(type);
    return Chip(
      visualDensity: VisualDensity.compact,
      avatar: Icon(Icons.circle, size: 12, color: color),
      label: Text(type),
      side: BorderSide(color: color),
    );
  }
}
