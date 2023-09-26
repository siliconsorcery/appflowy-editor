import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/block_component/base_component/block_icon_builder.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuoteBlockKeys {
  const QuoteBlockKeys._();

  static const String type = 'quote';

  static const String delta = blockComponentDelta;

  static const String paperColor = blockComponentPaperColor;

  static const String textDirection = blockComponentTextDirection;
}

Node quoteNode({
  Delta? delta,
  String? textDirection,
  Attributes? attributes,
  Iterable<Node>? children,
}) {
  attributes ??= {'delta': (delta ?? Delta()).toJson()};
  return Node(
    type: QuoteBlockKeys.type,
    attributes: {
      ...attributes,
      if (textDirection != null) QuoteBlockKeys.textDirection: textDirection,
    },
    children: children ?? [],
  );
}

class QuoteBlockComponentBuilder extends BlockComponentBuilder {
  QuoteBlockComponentBuilder({
    super.configuration,
    this.iconBuilder,
  });

  final BlockIconBuilder? iconBuilder;

  @override
  BlockComponentWidget build(BlockComponentContext blockComponentContext) {
    final node = blockComponentContext.node;
    return QuoteBlockComponentWidget(
      key: node.key,
      node: node,
      configuration: configuration,
      iconBuilder: iconBuilder,
      showActions: showActions(node),
      actionBuilder: (context, state) => actionBuilder(
        blockComponentContext,
        state,
      ),
    );
  }

  @override
  bool validate(Node node) => node.delta != null;
}

class QuoteBlockComponentWidget extends BlockComponentStatefulWidget {
  const QuoteBlockComponentWidget({
    super.key,
    required super.node,
    super.showActions,
    super.actionBuilder,
    super.configuration = const BlockComponentConfiguration(),
    this.iconBuilder,
  });

  final BlockIconBuilder? iconBuilder;

  @override
  State<QuoteBlockComponentWidget> createState() => _QuoteBlockComponentWidgetState();
}

class _QuoteBlockComponentWidgetState extends State<QuoteBlockComponentWidget>
    with
        SelectableMixin,
        DefaultSelectableMixin,
        BlockComponentConfigurable,
        BlockComponentPaperColorMixin,
        BlockComponentTextDirectionMixin,
        BlockComponentAlignMixin {
  @override
  final forwardKey = GlobalKey(debugLabel: 'flowy_rich_text');

  @override
  GlobalKey<State<StatefulWidget>> get containerKey => widget.node.key;

  @override
  GlobalKey<State<StatefulWidget>> blockComponentKey = GlobalKey(
    debugLabel: QuoteBlockKeys.type,
  );

  @override
  BlockComponentConfiguration get configuration => widget.configuration;

  @override
  Node get node => widget.node;

  @override
  late final editorState = Provider.of<EditorState>(context, listen: false);

  @override
  Widget build(BuildContext context) {
    final textDirection = calculateTextDirection(
      layoutDirection: Directionality.maybeOf(context),
    );

    Widget child = Container(
      // color: paperColor,
      width: double.infinity,
      alignment: alignment,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            textDirection: textDirection,
            children: [
              widget.iconBuilder != null ? widget.iconBuilder!(context, node) : const _QuoteIcon(),
              Flexible(
                child: AppFlowyRichText(
                  key: forwardKey,
                  delegate: this,
                  node: widget.node,
                  editorState: editorState,
                  textAlign: alignment?.toTextAlign,
                  placeholderText: placeholderText,
                  textSpanDecorator: (textSpan) => textSpan.updateTextStyle(
                    textStyle,
                  ),
                  placeholderTextSpanDecorator: (textSpan) => textSpan.updateTextStyle(
                    placeholderTextStyle,
                  ),
                  textDirection: textDirection,
                  cursorColor: editorState.editorStyle.cursorColor,
                  selectionColor: editorState.editorStyle.selectionColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );

    child = Padding(
      key: blockComponentKey,
      padding: padding,
      child: child,
    );

    child = BlockSelectionContainer(
      node: node,
      delegate: this,
      listenable: editorState.selectionNotifier,
      blockColor: editorState.editorStyle.selectionColor,
      supportTypes: const [
        BlockSelectionType.block,
      ],
      child: child,
    );

    if (widget.showActions && widget.actionBuilder != null) {
      child = BlockComponentActionWrapper(
        node: node,
        actionBuilder: widget.actionBuilder!,
        child: child,
      );
    }

    return child;
  }
}

class _QuoteIcon extends StatelessWidget {
  const _QuoteIcon();

  @override
  Widget build(BuildContext context) {
    return const EditorSvg(
      width: 20,
      height: 20,
      padding: EdgeInsets.only(right: 5.0),
      name: 'quote',
    );
  }
}
