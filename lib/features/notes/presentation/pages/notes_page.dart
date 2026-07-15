import 'dart:async';

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
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _FadeSlideTransition(
                animation: _controller,
                index: 0,
                child: Text(
                  'Notes\nメモ',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(child: MemoEditor(initialMemo: widget.initialMemo, entryAnimation: _controller)),
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
  Timer? _debounce;
  OverlayEntry? _toastEntry;
  AnimationController? _toastController;
  var _saving = false;
  var _lastSavedMemo = '';
  var _buttonPressed = false;

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.initialMemo);
    _focusNode = FocusNode()..addListener(() => setState(() {}));
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
    _debounce?.cancel();
    _toastEntry?.remove();
    _toastController?.dispose();
    _focusNode.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inputCard = _FadeSlideTransition(
      animation: widget.entryAnimation,
      index: 1,
      child: _MemoInputCard(
        controller: _memoController,
        focusNode: _focusNode,
        focused: _focusNode.hasFocus,
        onChanged: _scheduleAutoSave,
        expand: widget.entryAnimation != null,
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final canExpandInput = constraints.hasBoundedHeight;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (canExpandInput) Expanded(child: inputCard) else inputCard,
            const SizedBox(height: 20),
            _FadeSlideTransition(
              animation: widget.entryAnimation,
              index: 2,
              child: _GradientSaveButton(
                saving: _saving,
                pressed: _buttonPressed,
                onPressedChanged: (value) => setState(() => _buttonPressed = value),
                onPressed: _saving ? null : () => _save(showToast: true),
              ),
            ),
          ],
        );
      },
    );
  }

  void _scheduleAutoSave(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () => _save());
  }

  Future<void> _save({bool showToast = false}) async {
    final memo = _memoController.text;
    if (_saving || memo == _lastSavedMemo) {
      if (showToast && mounted) _showSavedToast();
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(notesRepositoryProvider).saveMemo(memo);
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

class _MemoInputCard extends StatelessWidget {
  const _MemoInputCard({
    required this.controller,
    required this.focusNode,
    required this.focused,
    required this.onChanged,
    required this.expand,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final bool focused;
  final ValueChanged<String> onChanged;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      height: expand ? null : 360,
      constraints: const BoxConstraints(minHeight: 360),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: focused ? const Color(0xFF6D6CFF) : const Color(0xFFE5E7EB), width: focused ? 1.6 : 1),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07), blurRadius: 18, offset: const Offset(0, 10)),
          if (focused) BoxShadow(color: const Color(0xFF7C6CFF).withValues(alpha: 0.22), blurRadius: 22, spreadRadius: 1),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        expands: true,
        maxLines: null,
        minLines: null,
        textAlignVertical: TextAlignVertical.top,
        decoration: InputDecoration(
          hintText: 'Write your notes...',
          hintStyle: const TextStyle(color: Color(0xFF9CA3AF), fontWeight: FontWeight.w500),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(24),
        ),
        onChanged: onChanged,
      ),
    );
  }
}

class _GradientSaveButton extends StatelessWidget {
  const _GradientSaveButton({required this.saving, required this.pressed, required this.onPressedChanged, required this.onPressed});

  final bool saving;
  final bool pressed;
  final ValueChanged<bool> onPressedChanged;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: onPressed == null ? null : (_) => onPressedChanged(true),
      onTapUp: onPressed == null ? null : (_) => onPressedChanged(false),
      onTapCancel: onPressed == null ? null : () => onPressedChanged(false),
      onTap: onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        height: 60,
        transform: Matrix4.translationValues(0, pressed ? 3 : 0, 0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(colors: [const Color(0xFF5B6CFF).withValues(alpha: saving ? 0.60 : 1), const Color(0xFF9C7CFF).withValues(alpha: saving ? 0.60 : 1)]),
          boxShadow: [BoxShadow(color: const Color(0xFF6D6CFF).withValues(alpha: pressed ? 0.18 : 0.34), blurRadius: pressed ? 12 : 20, offset: Offset(0, pressed ? 6 : 12))],
        ),
        child: Text(saving ? '保存中...' : '保存', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900, letterSpacing: 0.4)),
      ),
    );
  }
}

class _SavedToast extends StatelessWidget {
  const _SavedToast({required this.animation});

  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
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
                  decoration: BoxDecoration(color: const Color(0xFF111827).withValues(alpha: 0.92), borderRadius: BorderRadius.circular(999), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.20), blurRadius: 16, offset: const Offset(0, 8))]),
                  child: const Text('✓ Saved', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900)),
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
