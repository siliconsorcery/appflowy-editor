import 'package:appflowy_editor/appflowy_editor.dart';

final ToolbarItem quoteItem = ToolbarItem(
  id: 'editor.quote',
  group: 3,
  isActive: onlyShowInSingleSelectionAndTextType,
  builder: (context, editorState, paperColor, inkColor) {
    final selection = editorState.selection!;
    final node = editorState.getNodeAtPath(selection.start.path)!;
    final isHighlight = node.type == 'quote';
    return SVGIconItemWidget(
      iconName: 'toolbar/quote',
      isHighlight: isHighlight,
      paperColor: paperColor,
      keyColor: inkColor,
      tooltip: AppFlowyEditorLocalizations.current.quote,
      onPressed: () => editorState.formatNode(
        selection,
        (node) => node.copyWith(
          type: isHighlight ? 'paragraph' : 'quote',
        ),
      ),
    );
  },
);
