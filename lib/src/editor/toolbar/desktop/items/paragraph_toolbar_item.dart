import 'package:appflowy_editor/appflowy_editor.dart';

final ToolbarItem paragraphItem = ToolbarItem(
  id: 'editor.paragraph',
  group: 1,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, paperColor, inkColor) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'paragraph';
    final delta = (node.delta ?? Delta()).toJson();
    return SVGIconItemWidget(
      iconName: 'toolbar/text',
      isHighlight: isHighlight,
      paperColor: paperColor,
      keyColor: inkColor,
      tooltip: AppFlowyEditorLocalizations.current.text,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: ParagraphBlockKeys.type,
          attributes: {
            blockComponentDelta: delta,
            blockComponentPaperColor: node.attributes[blockComponentPaperColor],
            blockComponentTextDirection: node.attributes[blockComponentTextDirection],
          },
        ),
      ),
    );
  },
);
