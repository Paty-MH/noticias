import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/news_bloc.dart';
import '../bloc/news_event.dart';

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
    setState(() => _index = i);

    final bloc = context.read<NewsBloc>();

    // 🔥 Al salir de BUSCAR o CUALQUIER TAB → volver a noticias
    if (i != 1) {
      bloc.add(FetchInitialPosts());
    }

    // 🔥 Al entrar a CATEGORÍAS
    if (i == 2) {
      bloc.add(FetchCategories());
    }
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
