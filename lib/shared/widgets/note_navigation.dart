import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/database/database.dart';
import '../../features/notes/presentation/screens/editor_screen.dart';
import '../../features/security/presentation/screens/unlock_screen.dart';
Future<void> openNote(BuildContext context, WidgetRef ref, Note note) async {
  if (note.isLocked) {
    final unlocked = await Navigator.of(context).push<bool>(MaterialPageRoute(builder: (_) => const UnlockScreen()));
    if (unlocked != true) return;
  }
  if (!context.mounted) return;
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => EditorScreen(noteId: note.id)));
}
