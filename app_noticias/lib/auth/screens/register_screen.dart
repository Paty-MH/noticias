import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../services/notification_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final confirmCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthBloc>().add(
      RegisterRequested(
        nameCtrl.text.trim(),
        emailCtrl.text.trim(),
        passCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          // ❌ ERROR
          if (state is AuthError) {
            NotificationService.error(context, state.message);
          }

          // ✅ REGISTRO EXITOSO
          if (state is AuthAuthenticated) {
            NotificationService.success(
              context,
              'Registro exitoso 🎉 Ahora inicia sesión',
            );

            Future.delayed(const Duration(seconds: 1), () {
              context.read<AuthBloc>().add(LogoutRequested());
              Navigator.pop(context); // vuelve al login
            });
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // 👤 NOMBRE
                TextFormField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa tu nombre' : null,
                ),
                const SizedBox(height: 16),

                // 📧 EMAIL
                TextFormField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu email';
                    if (!v.contains('@')) return 'Email inválido';
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
                      return 'Ingresa una contraseña';
                    }
                    if (v.length < 6) {
                      return 'Mínimo 6 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 🔐 CONFIRM PASSWORD
                TextFormField(
                  controller: confirmCtrl,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Confirmar contraseña',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) {
                    if (v != passCtrl.text) {
                      return 'Las contraseñas no coinciden';
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
                        onPressed: _submit,
                        child: const Text('Registrarse'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
