import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'notes_manager.dart';

class NoteEditorScreen extends StatefulWidget {
  final Note? note;

  const NoteEditorScreen({super.key, this.note});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _labelsController = TextEditingController();

  // List of existing labels (fetched from notes manager)
  Set<String> _existingLabels = {};

  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
      _titleController.text = widget.note!.title;
      _contentController.text = widget.note!.content;
      _labelsController.text = widget.note!.labels.join(', ');
    }
    _loadExistingLabels();
  }

  // Load existing labels from saved notes
  void _loadExistingLabels() async {
    final notes = await NotesManager.loadNotes();
    setState(() {
      _existingLabels = notes.expand((note) => note.labels).toSet();
    });
  }

  void _saveNote() async {
    final id = widget.note?.id ?? const Uuid().v4();
    final newNote = Note(
      id: id,
      title: _titleController.text,
      content: _contentController.text,
      labels: _labelsController.text.split(',').map((s) => s.trim()).toList(),
    );

    // Load the current notes
    final notes = await NotesManager.loadNotes();

    // Check if it's an update or a new note
    final index = notes.indexWhere((note) => note.id == id);
    if (index != -1) {
      // Update the existing note
      notes[index] = newNote;
    } else {
      // Add the new note
      notes.add(newNote);
    }

    // Save the updated notes list
    await NotesManager.saveNotes(notes);

    // Return the note to the previous screen
    Navigator.pop(context, newNote);
  }

  // Add label to the text field when clicked
  void _addLabelToField(String label) {
    final currentText = _labelsController.text;
    if (currentText.isEmpty) {
      _labelsController.text = label;
    } else if (!currentText.contains(label)) {
      _labelsController.text = '$currentText, $label';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveNote,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                labelStyle: TextStyle(color: Colors.white70),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                labelStyle: TextStyle(color: Colors.white70),
              ),
              maxLines: 5,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _labelsController,
              decoration: const InputDecoration(
                labelText: 'Labels (comma-separated)',
                labelStyle: TextStyle(color: Colors.white70),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.teal),
                ),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 8),
            // Display existing labels as clickable Chips
            Wrap(
              spacing: 8,
              children: _existingLabels.map((label) {
                return ActionChip(
                  label: Text(
                    label,
                    style: const TextStyle(color: Colors.white),
                  ),
                  onPressed: () => _addLabelToField(label),
                  backgroundColor: Colors.teal,
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveNote,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Save Note',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
