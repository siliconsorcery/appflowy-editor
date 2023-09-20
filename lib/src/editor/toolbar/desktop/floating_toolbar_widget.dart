import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

const floatingToolbarHeight = 40.0;

class FloatingToolbarWidget extends StatefulWidget {
  const FloatingToolbarWidget({
    super.key,
    required this.paperColor,
    required this.inkColor,
    required this.items,
    required this.editorState,
  });

  final List<ToolbarItem> items;
  final Color paperColor;
  final Color inkColor;
  final EditorState editorState;

  @override
  State<FloatingToolbarWidget> createState() => _FloatingToolbarWidgetState();
}

class _FloatingToolbarWidgetState extends State<FloatingToolbarWidget> {
  @override
  Widget build(BuildContext context) {
    var activeItems = _computeActiveItems();
    if (activeItems.isEmpty) {
      return const SizedBox.shrink();
    }
    const horizontalPadding = EdgeInsets.symmetric(horizontal: 16.0);
    const insetPadding = EdgeInsets.symmetric(horizontal: 8.0, vertical: 0.0);
    final decoration = BoxDecoration(
      borderRadius: BorderRadius.circular(8.0),
      color: widget.paperColor,
      boxShadow: const [
        BoxShadow(
          color: Color.fromARGB(32, 0, 0, 0),
          offset: Offset(0, 0),
          blurRadius: 16,
        ),
      ],
    );

    return Material(
      child: Padding(
        padding: horizontalPadding,
        child: DecoratedBox(
          decoration: decoration,
          child: Padding(
            padding: insetPadding,
            child: SizedBox(
              height: floatingToolbarHeight,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: activeItems.map((item) {
                  final builder = item.builder;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Center(
                      child: builder!(
                        context,
                        widget.editorState,
                        widget.paperColor,
                        widget.inkColor,
                      ),
                    ),
                  );
                }).toList(growable: false),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Iterable<ToolbarItem> _computeActiveItems() {
    final activeItems = widget.items
        .where(
          (e) => e.isActive?.call(widget.editorState) ?? false,
        )
        .toList();
    if (activeItems.isEmpty) {
      return [];
    }
    // sort by group.
    activeItems.sort((a, b) => a.group.compareTo(b.group));

    // insert the divider.
    return activeItems
        .splitBetween((first, second) => first.group != second.group)
        .expand((element) => [...element, placeholderItem])
        .toList()
      ..removeLast();
  }
}
