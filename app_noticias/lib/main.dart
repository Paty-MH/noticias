import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/news_bloc.dart';
import 'bloc/news_event.dart';
import 'services/api_service.dart';
import 'screens/main_navigation.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NewsBloc(ApiService())..add(const FetchInitialPosts()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NewsApp',

        // 🌙 DARK MODE
        themeMode: ThemeMode.system,

        // ☀️ LIGHT THEME
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.deepPurple,
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        ),

        // 🌑 DARK THEME
        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.deepPurple,
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        ),

        home: const MainNavigation(),
      ),
    );
  }
}
