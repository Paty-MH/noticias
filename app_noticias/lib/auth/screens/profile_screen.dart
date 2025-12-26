import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController imageCtrl;

  @override
  void initState() {
    super.initState();

    final state = context.read<AuthBloc>().state;

    if (state is AuthAuthenticated) {
      nameCtrl = TextEditingController(text: state.user.name);
      phoneCtrl = TextEditingController(text: state.user.phone);
      imageCtrl = TextEditingController(text: state.user.imageUrl);
    } else {
      nameCtrl = TextEditingController();
      phoneCtrl = TextEditingController();
      imageCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    phoneCtrl.dispose();
    imageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(LogoutRequested());
            },
          ),
        ],
      ),

      body: BlocConsumer<AuthBloc, AuthState>(
        /// 🔥 SOLO ESCUCHA ERRORES, LOGOUT Y CAMBIO DE USUARIO
        listenWhen: (previous, current) {
          if (current is AuthError || current is AuthUnauthenticated) {
            return true;
          }

          if (previous is AuthAuthenticated &&
              current is AuthAuthenticated &&
              previous.user != current.user) {
            return true;
          }

          return false;
        },

        listener: (context, state) {
          /// ❌ ERROR
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }

          /// ✅ PERFIL ACTUALIZADO
          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Perfil actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          }

          /// 🚪 LOGOUT
          if (state is AuthUnauthenticated) {
            Navigator.of(
              context,
            ).pushNamedAndRemoveUntil('/login', (_) => false);
          }
        },

        builder: (context, state) {
          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Usuario no autenticado'));
          }

          final user = state.user;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                /// 👤 FOTO PERFIL (ROBUSTA)
                Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade300,
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: user.imageUrl.isNotEmpty
                        ? Image.network(
                            user.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) {
                              return const Icon(
                                Icons.person,
                                size: 70,
                                color: Colors.grey,
                              );
                            },
                          )
                        : const Icon(
                            Icons.person,
                            size: 70,
                            color: Colors.grey,
                          ),
                  ),
                ),

                const SizedBox(height: 24),

                /// 👤 NOMBRE
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                /// 📞 TELÉFONO
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Teléfono',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 12),

                /// 🖼 URL IMAGEN
                TextField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL imagen de perfil',
                    border: OutlineInputBorder(),
                  ),
                ),

                const SizedBox(height: 24),

                /// 💾 GUARDAR
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar cambios'),
                    onPressed: () {
                      if (nameCtrl.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('El nombre es obligatorio'),
                          ),
                        );
                        return;
                      }

                      context.read<AuthBloc>().add(
                        UpdateProfileRequested(
                          name: nameCtrl.text.trim(),
                          phone: phoneCtrl.text.trim(),
                          imageUrl: imageCtrl.text.trim(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
