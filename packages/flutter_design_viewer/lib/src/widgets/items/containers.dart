import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_design_viewer/src/measures.dart';

class KeyContainer extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final double size;
  const KeyContainer({
    required this.size,
    this.label,
    this.icon,
    Key? key,
  })  : assert(label != null || icon != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.dialogBackgroundColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 3),
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 4,
            spreadRadius: 0.5,
          )
        ],
      ),
      width: size,
      height: size,
      child: Center(
        child: Paddings.bottom1(
          child: label != null
              ? Text(
                  label!,
                  style: theme.textTheme.button!.copyWith(
                    fontFeatures: [const FontFeature.tabularFigures()],
                    textBaseline: TextBaseline.alphabetic,
                  ),
                )
              : Icon(
                  icon,
                  size: 12,
                ),
        ),
      ),
    );
  }
}
