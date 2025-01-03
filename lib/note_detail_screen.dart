import 'package:flutter/material.dart';
import 'notes_manager.dart';
import 'note_editor_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NoteEditorScreen(note: note),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              note.title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              note.content,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Labels: ${note.labels.join(', ')}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}