import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

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

import 'notifications/services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /// 🔔 Inicializar NOTIFICACIONES (solo Android / iOS)
  if (!kIsWeb) {
    await NotificationService.initialize();
  }

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

        /// 📰 NEWS
        BlocProvider(
          create: (_) => NewsBloc(ApiService())..add(const FetchInitialPosts()),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Newsnap',

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
