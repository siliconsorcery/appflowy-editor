import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

mixin BlockComponentPaperColorMixin {
  Node get node;

  Color get paperColor {
    final colorString = node.attributes[blockComponentPaperColor] as String?;
    if (colorString == null) {
      return Colors.transparent;
    }
    return colorString.tryToColor() ?? Colors.transparent;
  }
}
