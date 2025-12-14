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
      create: (_) => NewsBloc(ApiService())..add(FetchInitialPosts()),
      child: const MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NewsApp',
        home: MainNavigation(), // 👈 AQUÍ
      ),
    );
  }
}
