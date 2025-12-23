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
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }

          if (state is AuthAuthenticated) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Perfil actualizado')));
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is! AuthAuthenticated) {
            return const Center(child: Text('Usuario no autenticado'));
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: ListView(
              children: [
                CircleAvatar(
                  radius: 70,
                  backgroundImage: state.user.imageUrl.isNotEmpty
                      ? NetworkImage(state.user.imageUrl)
                      : null,
                  child: state.user.imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
                const SizedBox(height: 20),

                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nombre'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Teléfono'),
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: imageCtrl,
                  decoration: const InputDecoration(
                    labelText: 'URL imagen de perfil',
                  ),
                ),
                const SizedBox(height: 24),

                ElevatedButton(
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
                  child: const Text('Guardar cambios'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
