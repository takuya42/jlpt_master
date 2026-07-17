import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/app_background.dart';
import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../providers/notes_providers.dart';

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteProvider);
    return Scaffold(
      appBar: AppBar(actions: const [PremiumButton()]),
      body: AppBackground(
        worldMapOpacityFactor: 0.42,
        globeOpacityFactor: 0.46,
        child: SafeArea(
          child: note.when(
            loading: () => const AppLoadingView(message: 'Loading Notes\nメモを読み込み中'),
            error: (error, stackTrace) => AppErrorView(
              title: 'Notes\nメモ',
              message: error.toString(),
              onRetry: () => ref.invalidate(noteProvider),
            ),
            data: (data) => _NotesContent(initialMemo: data.memo),
          ),
        ),
      ),
    );
  }
}

class _NotesContent extends StatefulWidget {
  const _NotesContent({required this.initialMemo});

  final String initialMemo;

  @override
  State<_NotesContent> createState() => _NotesContentState();
}

class _NotesContentState extends State<_NotesContent> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final _editorKey = GlobalKey<_MemoEditorState>();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FadeSlideTransition(
                animation: _controller,
                index: 0,
                child: _NotesHeader(editorKey: _editorKey),
              ),
              const SizedBox(height: 16),
              Expanded(child: MemoEditor(key: _editorKey, initialMemo: widget.initialMemo, entryAnimation: _controller)),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> showMemoBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (context) => const _MemoBottomSheet(),
  );
}

class _MemoBottomSheet extends ConsumerWidget {
  const _MemoBottomSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final note = ref.watch(noteProvider);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(24, 24, 24, bottomInset + 24),
      child: note.when(
        loading: () => const SizedBox(height: 240, child: Center(child: CircularProgressIndicator())),
        error: (error, stackTrace) => AppErrorView(
          title: 'Memo',
          message: error.toString(),
          onRetry: () => ref.invalidate(noteProvider),
        ),
        data: (data) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Memo', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            MemoEditor(initialMemo: data.memo),
          ],
        ),
      ),
    );
  }
}

class MemoEditor extends ConsumerStatefulWidget {
  const MemoEditor({super.key, required this.initialMemo, this.entryAnimation});

  final String initialMemo;
  final Animation<double>? entryAnimation;

  @override
  ConsumerState<MemoEditor> createState() => _MemoEditorState();
}

class _MemoEditorState extends ConsumerState<MemoEditor> with TickerProviderStateMixin {
  late final TextEditingController _memoController;
  late final FocusNode _focusNode;
  OverlayEntry? _toastEntry;
  AnimationController? _toastController;
  var _saving = false;
  var _lastSavedMemo = '';

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.initialMemo);
    _focusNode = FocusNode();
    _lastSavedMemo = widget.initialMemo;
  }

  @override
  void didUpdateWidget(covariant MemoEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialMemo != oldWidget.initialMemo && widget.initialMemo != _memoController.text) {
      _memoController.text = widget.initialMemo;
      _lastSavedMemo = widget.initialMemo;
    }
  }

  @override
  void dispose() {
    _toastEntry?.remove();
    _toastController?.dispose();
    _focusNode.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final editor = _FadeSlideTransition(
      animation: widget.entryAnimation,
      index: 1,
      child: _MemoInputArea(
        controller: _memoController,
        focusNode: _focusNode,
        onChanged: (_) {},
        expand: widget.entryAnimation != null,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.hasBoundedHeight) {
          return editor;
        }
        return SizedBox(height: 360, child: editor);
      },
    );
  }

  Future<void> saveFromHeader() => _save(showToast: true);

  Future<void> _save({bool showToast = false}) async {
    final memo = _memoController.text;
    if (_saving || memo == _lastSavedMemo) {
      if (showToast && mounted) _showSavedToast();
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(notesRepositoryProvider).saveMemo(memo);
      ref.invalidate(noteProvider);
      _lastSavedMemo = memo;
      if (showToast && mounted) _showSavedToast();
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  void _showSavedToast() {
    _toastEntry?.remove();
    _toastController?.dispose();
    _toastController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _toastEntry = OverlayEntry(
      builder: (context) => _SavedToast(animation: CurvedAnimation(parent: _toastController!, curve: Curves.easeOutCubic)),
    );
    Overlay.of(context).insert(_toastEntry!);
    _toastController!.forward();
    Future<void>.delayed(const Duration(milliseconds: 1100), () async {
      if (!mounted || _toastController == null) return;
      await _toastController!.reverse();
      _toastEntry?.remove();
      _toastEntry = null;
    });
  }
}

class _NotesHeader extends StatelessWidget {
  const _NotesHeader({required this.editorKey});

  final GlobalKey<_MemoEditorState> editorKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            'Notes\nメモ',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        TextButton(
          onPressed: () => editorKey.currentState?.saveFromHeader(),
          child: const Text('保存'),
        ),
      ],
    );
  }
}

class _MemoInputArea extends StatelessWidget {
  const _MemoInputArea({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.expand,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: controller,
      focusNode: focusNode,
      expands: expand,
      maxLines: expand ? null : 12,
      minLines: expand ? null : 8,
      textAlignVertical: TextAlignVertical.top,
      keyboardType: TextInputType.multiline,
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        hintText: 'Write your notes...',
        hintStyle: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.45), fontWeight: FontWeight.w500),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        filled: false,
        contentPadding: EdgeInsets.zero,
      ),
      onChanged: onChanged,
    );
  }
}

class _SavedToast extends StatelessWidget {
  const _SavedToast({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Positioned(
      left: 0,
      right: 0,
      bottom: MediaQuery.paddingOf(context).bottom + 92,
      child: IgnorePointer(
        child: FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(animation),
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  decoration: BoxDecoration(color: colorScheme.inverseSurface.withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.20), blurRadius: 16, offset: const Offset(0, 8))]),
                  child: Text('Saved', style: theme.textTheme.labelLarge?.copyWith(color: colorScheme.onInverseSurface, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FadeSlideTransition extends StatelessWidget {
  const _FadeSlideTransition({required this.child, this.animation, required this.index});

  final Widget child;
  final Animation<double>? animation;
  final int index;

  @override
  Widget build(BuildContext context) {
    final parent = animation;
    if (parent == null) return child;

    final start = index * 0.18;
    final end = (start + 0.25).clamp(0.0, 1.0);
    final curved = CurvedAnimation(parent: parent, curve: Interval(start, end, curve: Curves.easeOutCubic));

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}
