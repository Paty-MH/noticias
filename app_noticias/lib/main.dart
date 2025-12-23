import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'bloc/news_bloc.dart';
import 'bloc/news_event.dart';
import 'services/api_service.dart';

import 'auth/bloc/auth_bloc.dart';
import 'auth/bloc/auth_event.dart';
import 'auth/bloc/auth_state.dart';
import 'auth/services/auth_service.dart';

import 'screens/main_navigation.dart';
import 'auth/screens/login_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const NewsApp());
}

class NewsApp extends StatelessWidget {
  const NewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        /// 🔐 AUTH
        BlocProvider(create: (_) => AuthBloc(AuthService())..add(AppStarted())),

        /// 📰 NEWS (EL QUE YA TENÍAS)
        BlocProvider(
          create: (_) => NewsBloc(ApiService())..add(const FetchInitialPosts()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'NewsApp',

        // 🌙 DARK MODE
        themeMode: ThemeMode.system,

        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: Colors.deepPurple,
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        ),

        darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.deepPurple,
          appBarTheme: const AppBarTheme(centerTitle: false, elevation: 0),
        ),

        /// 🔁 DECISIÓN DE FLUJO
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const MainNavigation();
            }

            if (state is AuthUnauthenticated) {
              return const LoginScreen();
            }

            return const SplashScreen();
          },
        ),
      ),
    );
  }
}
