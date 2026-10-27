import 'package:flutter/material.dart';

import 'grammar_screen.dart';
import 'home_screen.dart';
import 'progress_screen.dart';
import 'quiz_screen.dart';
import 'words_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  static void goToTab(BuildContext context, int index) =>
      context.findAncestorStateOfType<_ShellState>()?._select(index);

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int _index = 0;

  void _select(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [HomeScreen(), WordsScreen(), QuizHubScreen(), GrammarScreen(), ProgressScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.style_outlined), selectedIcon: Icon(Icons.style_rounded), label: 'Words'),
          NavigationDestination(icon: Icon(Icons.quiz_outlined), selectedIcon: Icon(Icons.quiz_rounded), label: 'Quiz'),
          NavigationDestination(icon: Icon(Icons.menu_book_outlined), selectedIcon: Icon(Icons.menu_book_rounded), label: 'Grammar'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), selectedIcon: Icon(Icons.insights_rounded), label: 'Progress'),
        ],
      ),
    );
  }
}
