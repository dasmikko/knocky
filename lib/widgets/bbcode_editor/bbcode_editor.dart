import 'package:flutter/material.dart';

import '../bbcode_renderer.dart';
import 'bbcode_text_controller.dart';
import 'bbcode_toolbar.dart';
import 'bbcode_toolbar_config.dart';

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
    widget.controller?._attach(_textController);
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    widget.onChanged?.call(_textController.text);
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

  Widget _buildRawEditor(BuildContext context) {
    return TextField(
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
      style: TextStyle(
        fontFamily: 'monospace',
        fontSize: 14,
        color: Theme.of(context).textTheme.bodyMedium?.color,
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
