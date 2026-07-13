import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/presentation/widgets/app_state_views.dart';
import '../../../../shared/presentation/widgets/premium_button.dart';
import '../../domain/note.dart';
import '../providers/notes_providers.dart';

const _jlptFilterOptions = ['All', 'N5', 'N4', 'N3', 'N2', 'N1'];
const _jlptLevels = ['N5', 'N4', 'N3', 'N2', 'N1'];

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final _searchController = TextEditingController();
  NoteType _type = NoteType.vocabulary;
  String _jlpt = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notes = ref.watch(notesProvider);
    return Scaffold(
      appBar: AppBar(actions: const [PremiumButton()]),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Note'),
        onPressed: () => _openEditor(Note.empty(type: _type)),
      ),
      body: SafeArea(
        child: notes.when(
          loading: () => const AppLoadingView(message: 'Loading Notes\nメモを読み込み中'),
          error: (error, stackTrace) => AppErrorView(
            title: 'Notes\nメモ',
            message: error.toString(),
            onRetry: () => ref.invalidate(notesProvider),
          ),
          data: (items) => _buildContent(items),
        ),
      ),
    );
  }

  Widget _buildContent(List<Note> notes) {
    final theme = Theme.of(context);
    final query = _searchController.text.trim().toLowerCase();
    final filtered = notes.where((note) {
      if (note.type != _type) return false;
      if (_jlpt != 'All' && note.jlptLevel != _jlpt) return false;
      if (query.isEmpty) return true;
      return note.title.toLowerCase().contains(query) || note.memo.toLowerCase().contains(query) || note.itemId.toLowerCase().contains(query);
    }).toList(growable: false);

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 980),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 28, 24, 96),
          children: [
            Text('Notes\nメモ', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
            const SizedBox(height: 18),
            SegmentedButton<NoteType>(
              segments: const [
                ButtonSegment(value: NoteType.vocabulary, icon: Icon(Icons.menu_book_outlined), label: Text('Vocabulary')),
                ButtonSegment(value: NoteType.grammar, icon: Icon(Icons.subject_outlined), label: Text('Grammar')),
              ],
              selected: {_type},
              onSelectionChanged: (selection) => setState(() => _type = selection.single),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                labelText: 'Search notes',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 14),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final level in _jlptFilterOptions)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(level),
                        selected: _jlpt == level,
                        onSelected: (_) => setState(() => _jlpt = level),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            if (filtered.isEmpty)
              const _EmptyNotesCard()
            else
              for (final note in filtered) _NoteCard(note: note, onTap: () => _openEditor(note)),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor(Note note) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => NoteEditorPage(initialNote: note)));
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap});

  final Note note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(18),
        leading: CircleAvatar(child: Icon(note.type == NoteType.vocabulary ? Icons.menu_book_outlined : Icons.subject_outlined)),
        title: Text(note.title.isEmpty ? 'Untitled Note' : note.title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(note.memo.isEmpty ? 'No memo yet.' : note.memo, maxLines: 3, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: [
              Chip(label: Text(note.jlptLevel)),
              Chip(label: Text(_formatDate(note.updatedAt))),
            ]),
          ]),
        ),
        onTap: onTap,
      ),
    );
  }

  String _formatDate(DateTime date) => '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _EmptyNotesCard extends StatelessWidget {
  const _EmptyNotesCard();

  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text('No notes found.\nメモがありません。'),
      ),
    );
  }
}

class NoteEditorPage extends ConsumerStatefulWidget {
  const NoteEditorPage({super.key, required this.initialNote});

  final Note initialNote;

  @override
  ConsumerState<NoteEditorPage> createState() => _NoteEditorPageState();
}

class _NoteEditorPageState extends ConsumerState<NoteEditorPage> {
  late final TextEditingController _itemIdController;
  late final TextEditingController _titleController;
  late final TextEditingController _memoController;
  late NoteType _type;
  late String _jlpt;
  var _saving = false;

  @override
  void initState() {
    super.initState();
    _type = widget.initialNote.type;
    _jlpt = _jlptLevels.contains(widget.initialNote.jlptLevel) ? widget.initialNote.jlptLevel : 'N5';
    _itemIdController = TextEditingController(text: widget.initialNote.itemId);
    _titleController = TextEditingController(text: widget.initialNote.title);
    _memoController = TextEditingController(text: widget.initialNote.memo);
  }

  @override
  void dispose() {
    _itemIdController.dispose();
    _titleController.dispose();
    _memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.initialNote.id.isEmpty;
    return Scaffold(
      appBar: AppBar(title: Text(isNew ? 'Add Note\nメモ追加' : 'Edit Note\nメモ編集')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(padding: const EdgeInsets.all(24), children: [
              SegmentedButton<NoteType>(
                segments: const [
                  ButtonSegment(value: NoteType.vocabulary, icon: Icon(Icons.menu_book_outlined), label: Text('Vocabulary')),
                  ButtonSegment(value: NoteType.grammar, icon: Icon(Icons.subject_outlined), label: Text('Grammar')),
                ],
                selected: {_type},
                onSelectionChanged: _saving ? null : (selection) => setState(() => _type = selection.single),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _jlpt,
                decoration: const InputDecoration(labelText: 'JLPT', border: OutlineInputBorder()),
                items: [for (final level in _jlptLevels) DropdownMenuItem(value: level, child: Text(level))],
                onChanged: _saving ? null : (value) => setState(() => _jlpt = value ?? 'N5'),
              ),
              const SizedBox(height: 16),
              TextField(controller: _itemIdController, decoration: const InputDecoration(labelText: 'Item ID', border: OutlineInputBorder()), enabled: !_saving),
              const SizedBox(height: 16),
              TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title', border: OutlineInputBorder()), enabled: !_saving),
              const SizedBox(height: 16),
              TextField(controller: _memoController, decoration: const InputDecoration(labelText: 'Memo', border: OutlineInputBorder()), minLines: 6, maxLines: 12, enabled: !_saving),
              const SizedBox(height: 24),
              FilledButton.icon(onPressed: _saving ? null : _save, icon: const Icon(Icons.save_rounded), label: const Text('Save')),
              const SizedBox(height: 12),
              OutlinedButton.icon(onPressed: _saving || isNew ? null : _delete, icon: const Icon(Icons.delete_outline_rounded), label: const Text('Delete')),
            ]),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final note = widget.initialNote.copyWith(
      type: _type,
      itemId: _itemIdController.text,
      title: _titleController.text,
      jlptLevel: _jlpt,
      memo: _memoController.text,
    );
    await ref.read(notesRepositoryProvider).saveNote(note);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _delete() async {
    setState(() => _saving = true);
    await ref.read(notesRepositoryProvider).deleteNote(widget.initialNote.id);
    if (mounted) Navigator.of(context).pop();
  }
}
