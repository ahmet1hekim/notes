import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';

class Note {
  String id;
  String title;
  String content;
  List<String> labels;

  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.labels,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'content': content,
    'labels': labels,
  };

  factory Note.fromJson(Map<String, dynamic> json) => Note(
    id: json['id'],
    title: json['title'],
    content: json['content'],
    labels: List<String>.from(json['labels']),
  );
}

class NotesManager {
  static const _fileName = 'notes.json';

  static Future<File> _getFile() async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  static Future<List<Note>> loadNotes() async {
    final file = await _getFile();
    if (!file.existsSync()) {
      return [];
    }
    final jsonString = await file.readAsString();
    final List<dynamic> jsonList = json.decode(jsonString);
    return jsonList.map((json) => Note.fromJson(json)).toList();
  }

  static Future<void> saveNotes(List<Note> notes) async {
    final file = await _getFile();
    final jsonString = json.encode(notes.map((note) => note.toJson()).toList());
    await file.writeAsString(jsonString);
  }
}

// Function to generate a consistent color based on the label
Color getColorForLabel(String label) {
  final hash = label.hashCode;
  final r = (hash & 0xFF0000) >> 16;
  final g = (hash & 0x00FF00) >> 8;
  final b = hash & 0x0000FF;
  return Color.fromARGB(255, r, g, b);
}