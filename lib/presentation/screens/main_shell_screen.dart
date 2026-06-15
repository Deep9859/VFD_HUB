import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'account_hub_screen.dart';
import 'home_screen.dart';
import 'saved_projects_screen.dart';
import 'tools_hub_screen.dart';

/// Primary app shell — bottom navigation aligned with feature areas.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  static const _tabs = [
    _ShellTab(
      label: 'Configure',
      icon: Icons.tune_rounded,
      selectedIcon: Icons.tune,
    ),
    _ShellTab(
      label: 'Tools',
      icon: Icons.apps_outlined,
      selectedIcon: Icons.apps,
    ),
    _ShellTab(
      label: 'Projects',
      icon: Icons.folder_outlined,
      selectedIcon: Icons.folder,
    ),
    _ShellTab(
      label: 'Account',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: const [
          HomeScreen(embedInShell: true),
          ToolsHubScreen(),
          SavedProjectsScreen(embedInShell: true),
          AccountHubScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: AppTheme.primary.withOpacity(0.15),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _ShellTab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _ShellTab({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}
