import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notes_providers.dart';
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key, required this.noteId});
  final String noteId;
  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}
class _EditorScreenState extends ConsumerState<EditorScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;
  Timer? _debounce;
  bool _loaded = false;
  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _bodyController = TextEditingController();
    _load();
  }
  Future<void> _load() async {
    final repo = ref.read(notesRepositoryProvider);
    final note = await repo.getById(widget.noteId);
    if (note != null && mounted) {
      _titleController.text = note.title;
      _bodyController.text = note.content;
      setState(() => _loaded = true);
    }
  }
  void _onChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), _save);
  }
  Future<void> _save() async {
    final repo = ref.read(notesRepositoryProvider);
    await repo.updateContent(id: widget.noteId, title: _titleController.text, content: _bodyController.text, plainText: _bodyController.text);
  }
  @override
  void dispose() {
    _debounce?.cancel();
    _save();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz_rounded), onPressed: () => _showNoteActions(context)),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
              children: [
                TextField(
                  controller: _titleController,
                  onChanged: (_) => _onChanged(),
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  decoration: const InputDecoration(hintText: 'Titulo', border: InputBorder.none, filled: false, contentPadding: EdgeInsets.zero),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _bodyController,
                  onChanged: (_) => _onChanged(),
                  maxLines: null,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                  decoration: const InputDecoration(hintText: 'Empieza a escribir...', border: InputBorder.none, filled: false, contentPadding: EdgeInsets.zero),
                ),
              ],
            ),
    );
  }
  void _showNoteActions(BuildContext context) {
    final repo = ref.read(notesRepositoryProvider);
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(leading: const Icon(Icons.push_pin_rounded), title: const Text('Fijar'), onTap: () async {
              Navigator.pop(sheetContext);
              final note = await repo.getById(widget.noteId);
              if (note != null) repo.setPinned(note.id, !note.isPinned);
            }),
            ListTile(leading: const Icon(Icons.star_rounded), title: const Text('Favorita'), onTap: () async {
              Navigator.pop(sheetContext);
              final note = await repo.getById(widget.noteId);
              if (note != null) repo.setFavorite(note.id, !note.isFavorite);
            }),
            ListTile(leading: const Icon(Icons.lock_rounded), title: const Text('Bloquear nota'), onTap: () {
              Navigator.pop(sheetContext);
            }),
            ListTile(leading: const Icon(Icons.delete_rounded), title: const Text('Eliminar'), onTap: () {
              Navigator.pop(sheetContext);
              repo.softDelete(widget.noteId);
              Navigator.of(context).pop();
            }),
          ],
        ),
      ),
    );
  }
}
