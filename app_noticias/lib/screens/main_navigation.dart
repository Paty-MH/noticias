import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'home_screen.dart';
import 'search_screen.dart';
import 'categories_screen.dart';
import 'bookmarks_screen.dart';
import '../auth/screens/profile_screen.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _index = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    SearchScreen(),
    CategoriesScreen(),
    BookmarksScreen(),
    ProfileScreen(), // 👤 PERFIL
  ];

  void _onTabChanged(int i) {
    if (i == _index) return;
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (prev, curr) => prev.runtimeType != curr.runtimeType,
      builder: (context, state) {
        // 🔐 SIN SESIÓN → NO MOSTRAR NAVEGACIÓN
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          body: IndexedStack(index: _index, children: _screens),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _index,
            onTap: _onTabChanged,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Colors.deepPurple,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.newspaper),
                label: 'Noticias',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search),
                label: 'Buscar',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.category),
                label: 'Categorías',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bookmark),
                label: 'Guardados',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }
}
