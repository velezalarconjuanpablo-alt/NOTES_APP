import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/database/database.dart';
class NoteCard extends StatelessWidget {
  const NoteCard({super.key, required this.note, required this.onTap});
  final Note note;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final title = note.title.trim().isEmpty ? 'Sin titulo' : note.title;
    final preview = _previewOf(note.plainText);
    final accent = note.colorValue != null ? Color(note.colorValue!) : null;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (accent != null) ...[
                    Container(width: 10, height: 10, decoration: BoxDecoration(color: accent, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                  ],
                  Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16))),
                  if (note.isPinned) Icon(Icons.push_pin_rounded, size: 16, color: scheme.primary),
                  if (note.isFavorite) Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.star_rounded, size: 16, color: scheme.primary)),
                  if (note.isLocked) Padding(padding: const EdgeInsets.only(left: 4), child: Icon(Icons.lock_rounded, size: 14, color: scheme.outline)),
                ],
              ),
              const SizedBox(height: 6),
              if (note.isLocked)
                Text('Contenido bloqueado', style: TextStyle(color: scheme.outline, fontStyle: FontStyle.italic))
              else
                Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: scheme.onSurfaceVariant, height: 1.3)),
              const SizedBox(height: 8),
              Text(_formatDate(note.updatedAt), style: TextStyle(fontSize: 12, color: scheme.outline)),
            ],
          ),
        ),
      ),
    );
  }
  String _previewOf(String text) {
    final trimmed = text.trim();
    return trimmed.isEmpty ? 'Nota vacia' : trimmed;
  }
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;
    if (isToday) return DateFormat.jm().format(date);
    return DateFormat('d MMM, y').format(date);
  }
}
