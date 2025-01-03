import 'package:flutter/material.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: Colors.teal,
          secondary: Colors.tealAccent, // Replacing accentColor
        ),
        appBarTheme: const AppBarTheme(
          color: Color(0xFF1F1F1F),
        ),
        scaffoldBackgroundColor: const Color(0xFF121212),
        cardColor: const Color(0xFF1E1E1E),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white54),
          bodySmall: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}