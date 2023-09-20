import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:flutter/material.dart';

class SVGIconItemWidget extends StatelessWidget {
  const SVGIconItemWidget({
    super.key,
    this.size = const Size.square(28.0),
    this.iconSize = const Size.square(20.0),
    this.iconName,
    this.iconBuilder,
    required bool isHighlight,
    required Color keyColor,
    required Color paperColor,
    this.tooltip,
    this.onPressed,
  })  : _isHighlight = isHighlight,
        _keyColor = keyColor,
        _paperColor = paperColor;

  final Size size;
  final Size iconSize;
  final String? iconName;
  final WidgetBuilder? iconBuilder;

  final bool _isHighlight;
  final Color _keyColor;
  final Color _paperColor;

  final String? tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final inkColor = _isHighlight ? _paperColor : _keyColor;
    final paperColor = _isHighlight ? _keyColor : Colors.transparent;
    final hoverColor = _keyColor.withAlpha(32);
    final highlightColor = _keyColor.withAlpha(64);

    Widget child = iconBuilder != null
        ? iconBuilder!(context)
        : EditorSvg(
            name: iconName,
            color: inkColor,
            width: iconSize.width,
            height: iconSize.height,
          );

    if (onPressed != null) {
      child = MouseRegion(
        cursor: SystemMouseCursors.click,
        child: IconButton.filled(
          icon: child,
          isSelected: _isHighlight,
          onPressed: onPressed,
          iconSize: size.width,
          padding: EdgeInsets.zero,
          hoverColor: hoverColor,
          highlightColor: highlightColor,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (Set<MaterialState> states) {
                if (states.contains(MaterialState.hovered)) {
                  return hoverColor;
                }
                return paperColor;
              },
            ),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          splashRadius: 2,
        ),
        // child: IconButton(
        //   iconSize: size.width,
        //   icon: child,
        //   isSelected: true,
        //   onPressed: onPressed,
        //   padding: EdgeInsets.zero,
        //   hoverColor: hoverColor,
        //   highlightColor: highlightColor,
        // ),
      );
    }

    if (tooltip != null) {
      child = Tooltip(
        textAlign: TextAlign.center,
        preferBelow: false,
        message: tooltip,
        waitDuration: const Duration(milliseconds: 600),
        child: child,
      );
    }

    return SizedBox(
      width: size.width,
      height: size.height,
      child: child,
    );
  }
}
