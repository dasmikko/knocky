import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/emotes.dart';
import '../bbcode_renderer/bbcode_renderer.dart';
import 'bbcode_text_controller.dart';
import 'bbcode_toolbar.dart';
import 'bbcode_toolbar_config.dart';
import 'emote_autocomplete_overlay.dart';
import 'smart_paste.dart';

export 'bbcode_text_controller.dart';
export 'bbcode_toolbar_config.dart';

/// View modes for the BBCode editor
enum BbcodeEditorViewMode {
  raw,
  preview,
  split,
}

/// Controller for accessing and manipulating BBCode editor content.
///
/// Buffers content so it survives the editor widget being disposed
/// (e.g. when a bottom sheet is closed and reopened).
class BbcodeEditorController extends ChangeNotifier {
  BbcodeTextController? _textController;
  String _bufferedContent = '';

  /// Mention user data for preview rendering
  final List<Map<String, dynamic>> _mentionUsers = [];
  List<Map<String, dynamic>> get mentionUsers =>
      List.unmodifiable(_mentionUsers);

  /// Whether there is any draft content buffered
  bool get hasDraft => bbcode.trim().isNotEmpty;

  /// Get the current BBCode content
  String get bbcode => _textController?.text ?? _bufferedContent;

  /// Set the BBCode content
  set bbcode(String value) {
    _bufferedContent = value;
    _textController?.text = value;
  }

  /// Add a mention user for preview rendering
  void addMentionUser({
    required int userId,
    required String username,
    String? roleCode,
  }) {
    // Avoid duplicates
    if (_mentionUsers.any((u) => u['id'] == userId)) return;
    _mentionUsers.add({
      'id': userId,
      'username': username,
      if (roleCode != null) 'role': {'code': roleCode},
    });
    notifyListeners();
  }

  /// Clear all content
  void clear() {
    _bufferedContent = '';
    _textController?.clearContent();
    _mentionUsers.clear();
  }

  /// Internal: attach the text controller
  void _attach(BbcodeTextController controller) {
    _textController = controller;
    if (_bufferedContent.isNotEmpty) {
      controller.text = _bufferedContent;
    }
  }

  /// Internal: detach the text controller
  void _detach() {
    _bufferedContent = _textController?.text ?? _bufferedContent;
    _textController = null;
  }
}

/// Vertical space between the caret and the emote suggestion list.
const double _caretGap = 4;

/// A WYSIWYG BBCode editor with toolbar, preview, and raw editing modes
class BbcodeEditor extends StatefulWidget {
  /// Controller for external access to BBCode content
  final BbcodeEditorController? controller;

  /// Initial BBCode content
  final String? initialContent;

  /// Hint text for the editor
  final String hintText;

  /// Callback when content changes
  final ValueChanged<String>? onChanged;

  /// Custom toolbar configuration
  final BbcodeToolbarConfig toolbarConfig;

  /// Minimum height for the editor
  final double minHeight;

  /// Maximum height for the editor (null for unlimited)
  final double? maxHeight;

  /// Whether to show the view mode toggle
  final bool showViewModeToggle;

  /// Initial view mode
  final BbcodeEditorViewMode initialViewMode;

  const BbcodeEditor({
    super.key,
    this.controller,
    this.initialContent,
    this.hintText = 'Write your post...',
    this.onChanged,
    this.toolbarConfig = const BbcodeToolbarConfig(),
    this.minHeight = 150,
    this.maxHeight,
    this.showViewModeToggle = true,
    this.initialViewMode = BbcodeEditorViewMode.raw,
  });

  @override
  State<BbcodeEditor> createState() => _BbcodeEditorState();
}

class _BbcodeEditorState extends State<BbcodeEditor> {
  late final BbcodeTextController _textController;
  late BbcodeEditorViewMode _viewMode;
  final FocusNode _focusNode = FocusNode();

  /// Emote autocomplete state
  final LayerLink _autocompleteLink = LayerLink();
  final GlobalKey _textFieldKey = GlobalKey();
  final OverlayPortalController _autocompleteOverlay = OverlayPortalController();
  List<Emote> _emoteSuggestions = const [];
  int _selectedSuggestion = 0;

  /// Where the suggestion list sits relative to the text field, measured from
  /// the caret. Null until the first measurement lands.
  ({Offset offset, double width, double maxHeight})? _caretAnchor;

  /// Which side of the caret the list opened on. Sticky while it is showing
  /// so it doesn't hop around as the match count changes.
  bool? _anchorAbove;

  /// Query the user dismissed with escape - suppressed until they type
  /// something else.
  String? _dismissedQuery;

  @override
  void initState() {
    super.initState();
    // Prefer controller's buffered content (from a previous session),
    // then fall back to initialContent.
    final initial = (widget.controller?.bbcode.isNotEmpty == true)
        ? widget.controller!.bbcode
        : (widget.initialContent ?? '');
    _textController = BbcodeTextController(text: initial);
    _viewMode = widget.initialViewMode;

    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
    _focusNode.onKeyEvent = _onEditorKeyEvent;
    widget.controller?._attach(_textController);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(_textController.text);
    _updateEmoteSuggestions();
  }

  void _onFocusChanged() {
    if (!_focusNode.hasFocus) _hideEmoteSuggestions();
  }

  /// Recompute suggestions from the text before the cursor and show or hide
  /// the overlay accordingly.
  void _updateEmoteSuggestions() {
    if (!mounted ||
        !_focusNode.hasFocus ||
        _viewMode == BbcodeEditorViewMode.preview) {
      _hideEmoteSuggestions();
      return;
    }

    final selection = _textController.selection;
    if (!selection.isValid || !selection.isCollapsed) {
      _hideEmoteSuggestions();
      return;
    }

    final query = EmoteAutocompleteManager.getEmoteQuery(
      _textController.text,
      selection.baseOffset,
    );
    if (query == null) {
      _hideEmoteSuggestions();
      return;
    }
    if (query != _dismissedQuery) _dismissedQuery = null;
    if (_dismissedQuery != null) return;

    final matches = EmoteAutocompleteManager.getMatchingEmotes(query);
    if (matches.isEmpty) {
      _hideEmoteSuggestions();
      return;
    }

    setState(() {
      _emoteSuggestions = matches;
      _selectedSuggestion = 0;
    });

    // The caret can only be measured once the field has laid out the new text,
    // so the overlay is shown from the post-frame measurement instead of here.
    WidgetsBinding.instance.addPostFrameCallback((_) => _positionOverlay());
  }

  /// Measure the caret and place the suggestion list directly beneath it,
  /// flipping above when there isn't room below (keyboard, bottom of screen).
  void _positionOverlay() {
    if (!mounted || _emoteSuggestions.isEmpty) return;

    final anchor = _measureCaretAnchor();
    if (anchor == null) {
      _hideEmoteSuggestions();
      return;
    }

    if (anchor != _caretAnchor) {
      setState(() => _caretAnchor = anchor);
    }
    _autocompleteOverlay.show();
  }

  ({Offset offset, double width, double maxHeight})? _measureCaretAnchor() {
    final fieldBox = _textFieldKey.currentContext?.findRenderObject();
    if (fieldBox is! RenderBox || !fieldBox.hasSize) return null;

    final editable = _findRenderEditable(fieldBox);
    if (editable == null) return null;

    final selection = _textController.selection;
    if (!selection.isValid) return null;

    final endpoints = editable.getEndpointsForSelection(selection);
    if (endpoints.isEmpty) return null;

    // For a collapsed selection this point is the bottom of the caret.
    final rawCaret = fieldBox.globalToLocal(
      editable.localToGlobal(endpoints.first.point),
    );

    final media = MediaQuery.of(context);
    final fieldOrigin = fieldBox.localToGlobal(Offset.zero);
    if (!fieldOrigin.dy.isFinite || !fieldOrigin.dx.isFinite) return null;

    // The field scrolls to the caret a frame after this measurement, so the
    // raw offset can land outside the box. Clamp it to where the caret will
    // actually be, otherwise the list gets placed off screen.
    final size = fieldBox.size;
    final caretBottom = Offset(
      rawCaret.dx.clamp(0.0, size.width),
      rawCaret.dy.clamp(0.0, size.height),
    );
    final caretTop = (caretBottom.dy - editable.preferredLineHeight).clamp(
      0.0,
      size.height,
    );

    final listHeight = EmoteAutocompleteOverlay.heightFor(
      _emoteSuggestions.length,
    );
    final width = _autocompleteWidth.clamp(0.0, media.size.width - 16);

    // Space between the caret and the screen edges, keeping clear of the
    // on-screen keyboard.
    final bottomLimit = media.size.height - media.viewInsets.bottom - 8;
    final spaceBelow =
        bottomLimit - (fieldOrigin.dy + caretBottom.dy + _caretGap);
    final spaceAbove = fieldOrigin.dy + caretTop - _caretGap - 8;

    // Prefer below the caret, flip up when the list doesn't fit there and
    // above is roomier. The choice sticks until the list closes: the match
    // count shrinks with every keystroke, and re-deciding each time made the
    // list hop from above the caret to below it mid-word.
    var above =
        _anchorAbove ?? (spaceBelow < listHeight && spaceAbove > spaceBelow);
    var available = above ? spaceAbove : spaceBelow;

    // Not worth showing a sliver of a list.
    final needed = listHeight < EmoteAutocompleteOverlay.minHeight
        ? listHeight
        : EmoteAutocompleteOverlay.minHeight;
    if (available < needed) {
      // The remembered side has run out of room - try the other one.
      above = !above;
      available = above ? spaceAbove : spaceBelow;
      if (available < needed) return null;
    }
    _anchorAbove = above;

    final height = listHeight < available ? listHeight : available;

    // Keep the list on screen horizontally.
    final maxDx = media.size.width - 8 - width - fieldOrigin.dx;
    final minDx = 8 - fieldOrigin.dx;
    final dx = maxDx >= minDx ? caretBottom.dx.clamp(minDx, maxDx) : minDx;

    // Final safety net: whatever the maths above decided, the list has to end
    // up fully inside the visible area.
    final desiredTop = above
        ? fieldOrigin.dy + caretTop - _caretGap - height
        : fieldOrigin.dy + caretBottom.dy + _caretGap;
    final maxTop = bottomLimit - height;
    final top = maxTop > 8 ? desiredTop.clamp(8.0, maxTop) : 8.0;

    return (
      offset: Offset(dx, top - fieldOrigin.dy),
      width: width,
      maxHeight: height,
    );
  }

  /// Width of the suggestion list, capped to the field so it never overhangs a
  /// narrow editor.
  double get _autocompleteWidth {
    const preferred = 260.0;
    final fieldBox = _textFieldKey.currentContext?.findRenderObject();
    final fieldWidth = fieldBox is RenderBox && fieldBox.hasSize
        ? fieldBox.size.width
        : preferred;
    return fieldWidth < preferred ? fieldWidth : preferred;
  }

  /// TextField keeps its RenderEditable private, so walk down to it.
  RenderEditable? _findRenderEditable(RenderObject node) {
    if (node is RenderEditable) return node;
    RenderEditable? found;
    node.visitChildren((child) {
      found ??= _findRenderEditable(child);
    });
    return found;
  }

  void _hideEmoteSuggestions() {
    if (!_autocompleteOverlay.isShowing) return;
    _autocompleteOverlay.hide();
    _anchorAbove = null;
    setState(() {
      _emoteSuggestions = const [];
      _selectedSuggestion = 0;
    });
  }

  /// Replace the partially typed `:code` with the full emote tag.
  void _insertEmote(Emote emote) {
    final selection = _textController.selection;
    final cursor = selection.isValid
        ? selection.baseOffset
        : _textController.text.length;
    final (start, end) = EmoteAutocompleteManager.getReplaceRange(
      _textController.text,
      cursor,
    );

    final tag = ':${emote.code}:';
    _hideEmoteSuggestions();
    _dismissedQuery = null;
    _textController.value = TextEditingValue(
      text: _textController.text.replaceRange(start, end, tag),
      selection: TextSelection.collapsed(offset: start + tag.length),
    );
    _focusNode.requestFocus();
  }

  /// Hardware keyboard navigation for the suggestion list. Runs before the
  /// text field's own shortcuts, so arrows and enter only reach the text when
  /// the overlay is closed.
  KeyEventResult _onEditorKeyEvent(FocusNode node, KeyEvent event) {
    if (!_autocompleteOverlay.isShowing || _emoteSuggestions.isEmpty) {
      return KeyEventResult.ignored;
    }
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowDown) {
      setState(() {
        _selectedSuggestion =
            (_selectedSuggestion + 1) % _emoteSuggestions.length;
      });
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      setState(() {
        _selectedSuggestion = (_selectedSuggestion - 1 + _emoteSuggestions.length) %
            _emoteSuggestions.length;
      });
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter ||
        key == LogicalKeyboardKey.tab) {
      _insertEmote(_emoteSuggestions[_selectedSuggestion]);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      _dismissedQuery = EmoteAutocompleteManager.getEmoteQuery(
        _textController.text,
        _textController.selection.baseOffset,
      );
      _hideEmoteSuggestions();
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Toolbar
          BbcodeToolbar(
            controller: _textController,
            config: widget.toolbarConfig,
            editorController: widget.controller,
          ),

          // View mode toggle
          if (widget.showViewModeToggle) _buildViewModeToggle(context),

          // Editor content
          Flexible(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: widget.minHeight,
                maxHeight: widget.maxHeight ?? double.infinity,
              ),
              child: _buildContent(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewModeToggle(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<BbcodeEditorViewMode>(
              segments: const [
                ButtonSegment(
                  value: BbcodeEditorViewMode.raw,
                  label: Text('Raw'),
                  icon: Icon(Icons.code, size: 18),
                ),
                ButtonSegment(
                  value: BbcodeEditorViewMode.preview,
                  label: Text('Preview'),
                  icon: Icon(Icons.visibility, size: 18),
                ),
                ButtonSegment(
                  value: BbcodeEditorViewMode.split,
                  label: Text('Split'),
                  icon: Icon(Icons.vertical_split, size: 18),
                ),
              ],
              selected: {_viewMode},
              onSelectionChanged: (selection) {
                _hideEmoteSuggestions();
                setState(() => _viewMode = selection.first);
              },
              showSelectedIcon: false,
              style: ButtonStyle(
                visualDensity: VisualDensity.compact,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return switch (_viewMode) {
      BbcodeEditorViewMode.raw => _buildRawEditor(context),
      BbcodeEditorViewMode.preview => _buildPreview(context),
      BbcodeEditorViewMode.split => _buildSplitView(context),
    };
  }

  Future<void> _onSmartPaste() async {
    await handleSmartPaste(
      context,
      controller: _textController,
      focusNode: _focusNode,
    );
  }

  Widget _buildRawEditor(BuildContext context) {
    return Actions(
      actions: {
        PasteTextIntent: CallbackAction<PasteTextIntent>(
          onInvoke: (_) {
            _onSmartPaste();
            return null;
          },
        ),
      },
      child: CompositedTransformTarget(
        link: _autocompleteLink,
        child: OverlayPortal(
          controller: _autocompleteOverlay,
          overlayChildBuilder: (context) => _EmoteAutocompletePosition(
            link: _autocompleteLink,
            anchor: _caretAnchor,
            emotes: _emoteSuggestions,
            selectedIndex: _selectedSuggestion,
            onEmoteSelected: _insertEmote,
          ),
          child: TextField(
            key: _textFieldKey,
            controller: _textController,
            focusNode: _focusNode,
            decoration: InputDecoration(
              hintText: widget.hintText,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(12),
            ),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
            contextMenuBuilder: (context, editableTextState) {
              return AdaptiveTextSelectionToolbar.buttonItems(
                anchors: editableTextState.contextMenuAnchors,
                buttonItems: editableTextState.contextMenuButtonItems.map((
                  item,
                ) {
                  if (item.type == ContextMenuButtonType.paste) {
                    return ContextMenuButtonItem(
                      label: item.label,
                      type: ContextMenuButtonType.paste,
                      onPressed: () {
                        ContextMenuController.removeAny();
                        _onSmartPaste();
                      },
                    );
                  }
                  return item;
                }).toList(),
              );
            },
            style: GoogleFonts.sourceCodePro(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPreview(BuildContext context) {
    final listenables = <Listenable>[_textController];
    if (widget.controller != null) listenables.add(widget.controller!);

    return ListenableBuilder(
      listenable: Listenable.merge(listenables),
      builder: (context, _) {
        final content = _textController.text;
        if (content.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Nothing to preview',
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontStyle: FontStyle.italic,
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: const EdgeInsets.all(12),
          child: Align(
            alignment: Alignment.topLeft,
            child: BbcodeRenderer(
              content: content,
              mentionUsers: widget.controller?.mentionUsers ?? const [],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSplitView(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Raw editor (left)
        Expanded(child: _buildRawEditor(context)),

        // Divider
        VerticalDivider(width: 1, thickness: 1),

        // Preview (right)
        Expanded(child: _buildPreview(context)),
      ],
    );
  }
}

/// Places the emote suggestion list at the caret, using an offset measured
/// relative to the text field's top-left corner.
class _EmoteAutocompletePosition extends StatelessWidget {
  final LayerLink link;
  final ({Offset offset, double width, double maxHeight})? anchor;
  final List<Emote> emotes;
  final int selectedIndex;
  final void Function(Emote emote) onEmoteSelected;

  const _EmoteAutocompletePosition({
    required this.link,
    required this.anchor,
    required this.emotes,
    required this.selectedIndex,
    required this.onEmoteSelected,
  });

  @override
  Widget build(BuildContext context) {
    final anchor = this.anchor;
    if (anchor == null) return const SizedBox.shrink();

    // The overlay hands its child tight, full-screen constraints. Align
    // loosens them, so the follower can size itself to the list instead of
    // stretching to fill the screen (which also throws off its anchoring).
    return Align(
      alignment: Alignment.topLeft,
      child: CompositedTransformFollower(
        link: link,
        targetAnchor: Alignment.topLeft,
        followerAnchor: Alignment.topLeft,
        offset: anchor.offset,
        showWhenUnlinked: false,
        child: SizedBox(
          width: anchor.width,
          child: EmoteAutocompleteOverlay(
            emotes: emotes,
            selectedIndex: selectedIndex,
            onEmoteSelected: onEmoteSelected,
            maxHeight: anchor.maxHeight,
          ),
        ),
      ),
    );
  }
}
