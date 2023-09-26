import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/flutter/scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageBlockKeys {
  static const String type = 'page';
}

Node pageNode({
  required Iterable<Node> children,
  Attributes attributes = const {},
}) {
  return Node(
    type: PageBlockKeys.type,
    children: children,
    attributes: attributes,
  );
}

class PageBlockComponentBuilder extends BlockComponentBuilder {
  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    return PageBlockComponent(
      key: blockComponentContext.node.key,
      node: blockComponentContext.node,
      header: blockComponentContext.header,
      footer: blockComponentContext.footer,
    );
  }
}

class PageBlockComponent extends BlockComponentStatelessWidget {
  const PageBlockComponent({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.header,
    this.footer,
  });

  final Widget? header;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final editorState = context.read<EditorState>();
    final scrollController = context.read<EditorScrollController>();
    final items = node.children;

    if (scrollController.shrinkWrap) {
      return Builder(
        builder: (context) {
          editorState.updateAutoScroller(Scrollable.of(context));
          return Column(
            children: [
              if (header != null) header!,
              ...items
                  .map(
                    (e) => ColoredBox(
                      color: Colors.lime,
                      child: Padding(
                        padding: EdgeInsets.zero, // editorState.editorStyle.padding,
                        child: editorState.renderer.build(context, e),
                      ),
                    ),
                  )
                  .toList(),
              if (footer != null) footer!,
            ],
          );
        },
      );
    } else {
      int extentCount = 0;
      if (header != null) extentCount++;
      if (footer != null) extentCount++;

      return ScrollablePositionedList.builder(
        shrinkWrap: scrollController.shrinkWrap,
        scrollDirection: Axis.vertical,
        itemCount: items.length + extentCount,
        itemBuilder: (context, index) {
          editorState.updateAutoScroller(Scrollable.of(context));
          if (header != null && index == 0) return header!;
          if (footer != null && index == items.length + 1) return footer!;
          final item = items[index - (header != null ? 1 : 0)];

          const isCard = true;
          const isPaper = true;
          const amount = 0.9;
          const spacing = (amount == 0) ? 0 : 2.0;

          final padding = configuration.padding(item);
          final colorString = item.attributes[blockComponentPaperColor] as String?;
          Color paperColor = () {
            if (isPaper) {
              return (colorString?.tryToColor() ?? Colors.white) ?? Colors.transparent;
            } else {
              return isCard ? Colors.white : Colors.transparent;
            }
          }();

          final pageOuterPadding = EdgeInsets.fromLTRB(
            editorState.editorStyle.padding.left * amount,
            editorState.editorStyle.padding.top * amount + spacing,
            editorState.editorStyle.padding.right * amount,
            editorState.editorStyle.padding.bottom * amount + spacing,
          );
          final innerPadding = EdgeInsets.fromLTRB(
            editorState.editorStyle.padding.left * (1 - amount) + padding.left,
            editorState.editorStyle.padding.top * (1 - amount) + padding.top,
            editorState.editorStyle.padding.right * (1 - amount) + padding.right,
            editorState.editorStyle.padding.bottom * (1 - amount) + padding.bottom,
          );
          final decoration = (amount > 0.1 && isCard)
              ? BoxDecoration(
                  color: paperColor,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color.fromARGB(117, 205, 205, 205),
                    width: 1,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Color.fromARGB(8, 0, 66, 132),
                      offset: Offset(0, 0),
                      blurRadius: 6.0,
                    ),
                  ],
                )
              : BoxDecoration(
                  color: paperColor,
                );

          return Padding(
            padding: pageOuterPadding,
            child: DecoratedBox(
              decoration: decoration,
              child: Padding(
                padding: innerPadding,
                child: editorState.renderer.build(
                  context,
                  item,
                ),
              ),
            ),
          );

          // return ColoredBox(
          //   color: Colors.lime,
          //   child: Padding(
          //     padding: EdgeInsets.zero, // editorState.editorStyle.padding,
          //     child: editorState.renderer.build(
          //       context,
          //       item,
          //     ),
          //   ),
          // );
        },
        itemScrollController: scrollController.itemScrollController,
        scrollOffsetController: scrollController.scrollOffsetController,
        itemPositionsListener: scrollController.itemPositionsListener,
        scrollOffsetListener: scrollController.scrollOffsetListener,
      );
    }
  }
}
