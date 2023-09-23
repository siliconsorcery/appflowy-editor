import 'package:appflowy_editor/appflowy_editor.dart';
import 'package:appflowy_editor/src/editor/find_replace_menu/search_service.dart';
import 'package:flutter/material.dart';

const double _iconSize = 20;
const double _iconButtonSize = 40;

class FindMenuWidget extends StatefulWidget {
  const FindMenuWidget({
    super.key,
    required this.dismiss,
    required this.editorState,
    required this.replaceFlag,
    this.localizations,
    required this.style,
  });

  final VoidCallback dismiss;
  final EditorState editorState;
  final bool replaceFlag;
  final FindReplaceLocalizations? localizations;
  final FindReplaceStyle style;

  @override
  State<FindMenuWidget> createState() => _FindMenuWidgetState();
}

class _FindMenuWidgetState extends State<FindMenuWidget> {
  final focusNode = FocusNode();
  final replaceFocusNode = FocusNode();
  final findController = TextEditingController();
  final replaceController = TextEditingController();
  String queriedPattern = '';
  bool replaceFlag = false;
  late SearchService searchService;

  @override
  void initState() {
    super.initState();
    replaceFlag = widget.replaceFlag;
    searchService = SearchService(
      editorState: widget.editorState,
      style: SearchStyle(
        selectedHighlightColor: Colors.red, // widget.style.selectedHighlightColor,
        unselectedHighlightColor: Colors.amber, // widget.style.unselectedHighlightColor,
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      focusNode.requestFocus();
    });

    findController.addListener(_searchPattern);
  }

  @override
  void dispose() {
    findController.removeListener(_searchPattern);
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const keyColor = Colors.blue;

    const paperColor = Colors.white;
    final hoverColor = keyColor.withAlpha(32);

    final style = ButtonStyle(
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
    );

    return Column(
      children: [
        Row(
          children: [
            IconButton(
              color: keyColor,
              onPressed: () => setState(
                () => replaceFlag = !replaceFlag,
              ),
              icon: replaceFlag ? const Icon(Icons.expand_less) : const Icon(Icons.expand_more),
              style: style,
            ),
            SizedBox(
              width: 200,
              height: 30,
              child: TextField(
                key: const Key('findTextField'),
                focusNode: focusNode,
                controller: findController,
                onSubmitted: (_) {
                  searchService.navigateToMatch();

                  // Workaround for editor forcing focus
                  Future.delayed(const Duration(milliseconds: 50)).then(
                    (value) => FocusScope.of(context).requestFocus(focusNode),
                  );
                },
                decoration: _buildInputDecoration(
                  widget.localizations?.find ?? AppFlowyEditorLocalizations.current.find,
                ),
              ),
            ),
            FindMenuIconButton(
              buttonKey: const Key('previousMatchButton'),
              iconSize: _iconSize,
              onPressed: () => searchService.navigateToMatch(moveUp: true),
              icon: const Icon(
                Icons.arrow_upward,
                color: keyColor,
              ),
              style: style,
              tooltip: widget.localizations?.previousMatch ?? AppFlowyEditorLocalizations.current.previousMatch,
            ),
            FindMenuIconButton(
              buttonKey: const Key('nextMatchButton'),
              iconSize: _iconSize,
              onPressed: () => searchService.navigateToMatch(),
              icon: const Icon(
                Icons.arrow_downward,
                color: keyColor,
              ),
              style: style,
              tooltip: widget.localizations?.nextMatch ?? AppFlowyEditorLocalizations.current.nextMatch,
            ),
            FindMenuIconButton(
              buttonKey: const Key('closeButton'),
              iconSize: _iconSize,
              onPressed: () {
                widget.dismiss();
                searchService.findAndHighlight(
                  queriedPattern,
                  unhighlight: true,
                );
                queriedPattern = '';
              },
              style: style,
              icon: const Icon(
                Icons.close,
                color: keyColor,
              ),
              tooltip: widget.localizations?.close ?? AppFlowyEditorLocalizations.current.closeFind,
            ),
          ],
        ),
        replaceFlag
            ? Row(
                children: [
                  SizedBox(
                    width: 200,
                    height: 30,
                    child: TextField(
                      key: const Key('replaceTextField'),
                      focusNode: replaceFocusNode,
                      autofocus: false,
                      controller: replaceController,
                      onSubmitted: (_) {
                        _replaceSelectedWord();

                        Future.delayed(const Duration(milliseconds: 50)).then(
                          (value) => FocusScope.of(context).requestFocus(replaceFocusNode),
                        );
                      },
                      decoration: _buildInputDecoration(
                        widget.localizations?.replace ?? AppFlowyEditorLocalizations.current.replace,
                      ),
                    ),
                  ),
                  FindMenuIconButton(
                    buttonKey: const Key('replaceSelectedButton'),
                    onPressed: () => _replaceSelectedWord(),
                    icon: const Icon(
                      Icons.find_replace,
                      color: keyColor,
                    ),
                    iconSize: _iconSize,
                    style: style,
                    tooltip: widget.localizations?.replace ?? AppFlowyEditorLocalizations.current.replace,
                  ),
                  FindMenuIconButton(
                    buttonKey: const Key('replaceAllButton'),
                    onPressed: () => _replaceAllMatches(),
                    icon: const Icon(
                      Icons.change_circle_outlined,
                      color: keyColor,
                    ),
                    iconSize: _iconSize,
                    style: style,
                    tooltip: widget.localizations?.replaceAll ?? AppFlowyEditorLocalizations.current.replaceAll,
                  ),
                ],
              )
            : const SizedBox.shrink(),
      ],
    );
  }

  void _searchPattern() {
    searchService.findAndHighlight(findController.text);
    setState(() => queriedPattern = findController.text);
  }

  void _replaceSelectedWord() {
    if (findController.text != queriedPattern) {
      _searchPattern();
    }
    searchService.replaceSelectedWord(replaceController.text);
  }

  void _replaceAllMatches() {
    if (findController.text != queriedPattern) {
      _searchPattern();
    }
    searchService.replaceAllMatches(replaceController.text);
  }

  InputDecoration _buildInputDecoration(String hintText) {
    return InputDecoration(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color.fromARGB(255, 244, 244, 244),
      hintText: hintText,
    );
  }
}

class FindMenuIconButton extends StatelessWidget {
  const FindMenuIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.iconSize,
    this.tooltip,
    this.buttonKey,
    this.style,
  });

  final Widget icon;
  final Key? buttonKey;
  final VoidCallback? onPressed;
  final double? iconSize;
  final String? tooltip;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _iconButtonSize,
      height: _iconButtonSize,
      child: IconButton(
        key: buttonKey,
        onPressed: onPressed,
        icon: icon,
        iconSize: iconSize,
        tooltip: tooltip,
        style: style,
      ),
    );
  }
}
