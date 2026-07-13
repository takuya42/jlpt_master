import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      body: SafeArea(
        child: note.when(
          loading: () => const AppLoadingView(message: 'Loading Notes\nメモを読み込み中'),
          error: (error, stackTrace) => AppErrorView(
            title: 'Notes\nメモ',
            message: error.toString(),
            onRetry: () => ref.invalidate(noteProvider),
          ),
          data: (data) => Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Text(
                    'Notes\nメモ',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 24),
                  MemoEditor(initialMemo: data.memo),
                ],
              ),
            ),
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
            Text('📝 Memo', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            MemoEditor(initialMemo: data.memo),
          ],
        ),
      ),
    );
  }
}

class MemoEditor extends ConsumerStatefulWidget {
  const MemoEditor({super.key, required this.initialMemo});

  final String initialMemo;

  @override
  ConsumerState<MemoEditor> createState() => _MemoEditorState();
}

class _MemoEditorState extends ConsumerState<MemoEditor> {
  late final TextEditingController _memoController;
  Timer? _debounce;
  var _saving = false;
  var _lastSavedMemo = '';

  @override
  void initState() {
    super.initState();
    _memoController = TextEditingController(text: widget.initialMemo);
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
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 360,
          child: TextField(
            controller: _memoController,
            expands: true,
            maxLines: null,
            minLines: null,
            textAlignVertical: TextAlignVertical.top,
            decoration: InputDecoration(
              hintText: 'Write your notes...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
              contentPadding: const EdgeInsets.all(24),
            ),
            onChanged: _scheduleAutoSave,
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _saving ? null : () => _save(showSnackBar: true),
          child: const Text('保存'),
        ),
      ],
    );
  }

  void _scheduleAutoSave(String _) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), () => _save());
  }

  Future<void> _save({bool showSnackBar = false}) async {
    final memo = _memoController.text;
    if (_saving || memo == _lastSavedMemo) {
      if (showSnackBar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      }
      return;
    }

    setState(() => _saving = true);
    try {
      await ref.read(notesRepositoryProvider).saveMemo(memo);
      _lastSavedMemo = memo;
      if (showSnackBar && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
