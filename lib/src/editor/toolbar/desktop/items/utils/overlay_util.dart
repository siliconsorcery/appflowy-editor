import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

ButtonStyle buildOverlayButtonStyle(BuildContext context) {
  final theme = Theme.of(context);
  final color = theme.hoverColor;
  const transparentColor = Colors.transparent;

  return ButtonStyle(
    backgroundColor: MaterialStateProperty.resolveWith<Color>(
      (Set<MaterialState> states) {
        if (states.contains(MaterialState.hovered)) {
          return color;
        }
        return transparentColor;
      },
    ),
  );
}

BoxDecoration buildOverlayDecoration(BuildContext context) {
  final theme = Theme.of(context);
  final color = theme.cardColor;
  final shadowColor = Colors.black.withOpacity(0.2);

  final boxShadow = BoxShadow(
    color: shadowColor,
    blurRadius: 8,
    offset: const Offset(0, 0),
  );

  return BoxDecoration(
    color: color,
    borderRadius: BorderRadius.circular(6),
    boxShadow: [
      boxShadow,
    ],
  );
}

class EditorOverlayTitle extends StatelessWidget {
  const EditorOverlayTitle({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

(double?, double?, double?) positionFromRect(
  Rect rect,
  EditorState editorState,
) {
  final left = rect.left + 10;
  double? top;
  double? bottom;
  final offset = rect.center;
  final editorOffset = editorState.renderBox!.localToGlobal(Offset.zero);
  final editorHeight = editorState.renderBox!.size.height;
  final threshold = editorOffset.dy + editorHeight - 200;
  if (offset.dy > threshold) {
    bottom = editorOffset.dy + editorHeight - rect.top - 5;
  } else {
    top = rect.bottom + 5;
  }

  return (top, bottom, left);
}

Widget basicOverlay(
  BuildContext context, {
  double? width,
  double? height,
  required List<Widget> children,
}) {
  return Container(
    width: width,
    height: height,
    decoration: buildOverlayDecoration(context),
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: children,
        ),
      ),
    ),
  );
}
