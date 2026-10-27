import 'package:flutter/material.dart';

import '../widgets/app_icons.dart';
import 'home_screen.dart';
import 'jlpt/jlpt_hub_screen.dart';
import 'practice_screen.dart';
import 'progress_screen.dart';
import 'words_screen.dart';

class Shell extends StatefulWidget {
  const Shell({super.key});

  static const jlptTab = 3;

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
        children: const [HomeScreen(), WordsScreen(), PracticeScreen(), JlptHubScreen(), ProgressScreen()],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: const [
          NavigationDestination(icon: Icon(AppIcons.home), selectedIcon: Icon(AppIcons.homeOn), label: 'Home'),
          NavigationDestination(icon: Icon(AppIcons.words), selectedIcon: Icon(AppIcons.wordsOn), label: 'Words'),
          NavigationDestination(
            icon: Icon(AppIcons.practice),
            selectedIcon: Icon(AppIcons.practiceOn),
            label: 'Practice',
          ),
          NavigationDestination(icon: Icon(AppIcons.exam), selectedIcon: Icon(AppIcons.examOn), label: 'JLPT'),
          NavigationDestination(
            icon: Icon(AppIcons.progress),
            selectedIcon: Icon(AppIcons.progressOn),
            label: 'Progress',
          ),
        ],
      ),
    );
  }
}
