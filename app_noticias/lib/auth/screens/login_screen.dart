import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _login() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      LoginRequested(emailCtrl.text.trim(), passCtrl.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Iniciar sesión',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),

                  // 📧 EMAIL
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Ingresa tu email';
                      }
                      if (!v.contains('@')) {
                        return 'Email inválido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 🔐 PASSWORD
                  TextFormField(
                    controller: passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Ingresa tu contraseña';
                      }
                      if (v.length < 6) {
                        return 'Contraseña inválida';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // 🔘 BOTÓN
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (_, state) {
                      if (state is AuthLoading) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _login,
                          child: const Text('Entrar'),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // ➕ REGISTRO
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text('¿No tienes cuenta? Crear cuenta'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
