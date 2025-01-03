import 'package:flutter/material.dart';
import 'notes_manager.dart';
import 'note_editor_screen.dart';
import 'note_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Note> _notes = [];
  List<String> _labels = []; // List of unique labels
  String? _selectedLabel;
  String _searchQuery = ''; // Current search query
  bool _isGridView = false; // Flag to track whether to display GridView or ListView

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await NotesManager.loadNotes();
    setState(() {
      _notes = notes;
      // Collect unique labels from all notes
      _labels = _notes.expand((note) => note.labels).toSet().toList();
    });
  }

  void _navigateToEditor({Note? note}) async {
    final updatedNote = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteEditorScreen(note: note),
      ),
    );
    if (updatedNote != null) {
      setState(() {
        final index = _notes.indexWhere((n) => n.id == updatedNote.id);
        if (index != -1) {
          _notes[index] = updatedNote;
        } else {
          _notes.add(updatedNote);
        }
        // Update the labels list after adding or editing the note
        _updateLabels();
      });
      await NotesManager.saveNotes(_notes);
    }
  }

  void _viewNoteDetails(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
  }

  // Filter notes by selected label and search query
  List<Note> _getFilteredNotes() {
    List<Note> filteredNotes = _notes;

    // Apply label filter
    if (_selectedLabel != null && _selectedLabel!.isNotEmpty) {
      filteredNotes = filteredNotes.where((note) => note.labels.contains(_selectedLabel)).toList();
    }

    // Apply search query filter
    if (_searchQuery.isNotEmpty) {
      filteredNotes = filteredNotes.where(
            (note) => note.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            note.content.toLowerCase().contains(_searchQuery.toLowerCase()),
      ).toList();
    }

    return filteredNotes;
  }

  // Function to update the labels list whenever notes are added or edited
  void _updateLabels() {
    setState(() {
      _labels = _notes.expand((note) => note.labels).toSet().toList();
    });
  }

  // Function to delete a note
  void _deleteNote(Note note) async {
    // Remove the note from the list
    setState(() {
      _notes.remove(note);
    });
    // Update the labels after deletion
    _updateLabels();
    await NotesManager.saveNotes(_notes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        actions: [
          // Label selection menu
          PopupMenuButton<String>(
            onSelected: (label) {
              setState(() {
                if (label == 'Show All') {
                  _selectedLabel = null; // Reset filter to show all notes
                } else {
                  _selectedLabel = label; // Apply label filter
                }
              });
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<String>(
                  value: 'Show All',
                  child: Text('Show All'), // Option to show all notes
                ),
                ..._labels.map((label) {
                  return PopupMenuItem<String>(
                    value: label,
                    child: Text(label),
                  );
                }).toList(),
              ];
            },
            icon: const Icon(Icons.label),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _navigateToEditor(),
          ),
          IconButton(
            icon: Icon(_isGridView ? Icons.view_list : Icons.grid_view),
            onPressed: () {
              setState(() {
                _isGridView = !_isGridView; // Toggle between grid and list view
              });
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value; // Update search query
                });
              },
              decoration: const InputDecoration(
                hintText: 'Search Notes...',
                hintStyle: TextStyle(color: Colors.black), // Change hint text color to black
                border: InputBorder.none,
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
              style: TextStyle(color: Colors.black), // Change written text color to black
            ),
          ),
        ),
      ),
      body: _isGridView
          ? GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
        ),
        itemCount: _getFilteredNotes().length,
        itemBuilder: (context, index) {
          final note = _getFilteredNotes()[index];
          final notePreview = note.content.length > 50
              ? note.content.substring(0, 50) + '...'
              : note.content;

          return Card(
            color: note.labels.isNotEmpty
                ? getColorForLabel(note.labels.first).withOpacity(0.3)
                : Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                InkWell(
                  onTap: () => _viewNoteDetails(note),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          note.labels.join(', '),
                          style: const TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 8),
                        Text(
                          notePreview, // Display content preview
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      // Show confirmation dialog before deleting
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Delete Note'),
                            content: const Text('Are you sure you want to delete this note?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          );
                        },
                      );

                      // If confirmed, delete the note and update labels
                      if (confirm == true) {
                        _deleteNote(note);
                      }
                    },
                  ),
                ),
              ],
            ),
          );
        },
      )
             : ListView.builder(
        itemCount: _getFilteredNotes().length,
        itemBuilder: (context, index) {
          final note = _getFilteredNotes()[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: note.labels.isNotEmpty
                ? getColorForLabel(note.labels.first).withOpacity(0.3)
                : Colors.grey[800],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
              title: Text(
                note.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                note.labels.join(', '),
                style: const TextStyle(color: Colors.white70),
              ),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  // Show confirmation dialog before deleting
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Delete Note'),
                        content: const Text(
                            'Are you sure you want to delete this note?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Delete'),
                          ),
                        ],
                      );
                    },
                  );

                  // If confirmed, delete the note and update labels
                  if (confirm == true) {
                    _deleteNote(note);
                  }
                },
              ),
              onTap: () => _viewNoteDetails(note), // View the note
            ),
          );
        },
      ),
    );
  }
}
