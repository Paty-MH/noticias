import 'package:flutter/material.dart';

import 'home_screen.dart';
import 'search_screen.dart';
import 'categories_screen.dart';
import 'bookmarks_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final _screens = const [
    HomeScreen(),
    SearchScreen(),
    CategoriesScreen(),
    BookmarksScreen(),
  ];

  void _onTabChanged(int i) {
    if (i == _index) return; // 🔥 evita rebuild innecesario
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _index, children: _screens),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: _onTabChanged,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'Categorías',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Guardados',
          ),
        ],
      ),
    );
  }
}
