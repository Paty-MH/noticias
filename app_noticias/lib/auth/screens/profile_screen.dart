import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  File? _imageFile;

  @override
  void initState() {
    super.initState();
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated && !state.isGuest) {
      _nameCtrl.text = state.user.name;
      _phoneCtrl.text = state.user.phone;
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated && state.isGuest) {
      NotificationService.info(
          context, 'Modo invitado: no se puede cambiar la imagen');
      return;
    }

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  void _updateProfile() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated && state.isGuest) {
      NotificationService.info(
          context, 'Modo invitado: no se puede editar el perfil');
      return;
    }

    FocusScope.of(context).unfocus();

    if (_nameCtrl.text.trim().isEmpty) {
      NotificationService.error(context, 'El nombre es obligatorio');
      return;
    }

    context.read<AuthBloc>().add(
          UpdateProfileRequested(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            imageFile: _imageFile,
            imageUrl: '', // se ignorará si imageFile existe
          ),
        );
  }

  void _deleteAccount() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthAuthenticated && state.isGuest) {
      NotificationService.info(
          context, 'Modo invitado: no se puede eliminar la cuenta');
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1C1C1C),
        title: const Text(
          'Eliminar cuenta',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            child: const Text('Cancelar'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.redAccent),
            ),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthBloc>().add(DeleteAccountRequested());
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B0B0B),
              Color(0xFF2A004F),
              Color(0xFF000000),
            ],
          ),
        ),
        child: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (!mounted) return;

              if (state is AuthError) {
                NotificationService.error(context, state.message);
              }

              if (state is AuthAuthenticated && !state.isGuest) {
                NotificationService.success(
                    context, 'Perfil cargado correctamente');
              }

              if (state is AuthUnauthenticated) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            builder: (context, state) {
              final isLoading = state is AuthLoading;

              if (state is! AuthAuthenticated) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.purpleAccent),
                );
              }

              final isGuest = state.isGuest;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    /// HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mi Perfil',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout,
                              color: Colors.purpleAccent),
                          onPressed: () => context
                              .read<AuthBloc>()
                              .add(const LogoutRequested()),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    /// CARD
                    Container(
                      constraints: const BoxConstraints(maxWidth: 460),
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(26),
                        color: Colors.white.withOpacity(0.06),
                        border:
                            Border.all(color: Colors.white.withOpacity(0.15)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.purpleAccent.withOpacity(0.35),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// AVATAR
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 64,
                              backgroundColor: Colors.black,
                              backgroundImage: _imageFile != null
                                  ? FileImage(_imageFile!)
                                  : (state.user.imageUrl.isNotEmpty
                                      ? NetworkImage(state.user.imageUrl)
                                      : null) as ImageProvider?,
                              child: state.user.imageUrl.isEmpty &&
                                      _imageFile == null
                                  ? const Icon(Icons.person,
                                      size: 64, color: Colors.white70)
                                  : null,
                            ),
                          ),

                          const SizedBox(height: 10),
                          const Text(
                            'Toca la imagen para cambiarla',
                            style:
                                TextStyle(color: Colors.white54, fontSize: 13),
                          ),
                          const SizedBox(height: 28),

                          _inputField(
                            controller: _nameCtrl,
                            label: 'Nombre',
                            icon: Icons.person,
                            enabled: !isGuest,
                          ),

                          const SizedBox(height: 16),

                          _inputField(
                            controller: _phoneCtrl,
                            label: 'Teléfono',
                            icon: Icons.phone,
                            keyboardType: TextInputType.phone,
                            enabled: !isGuest,
                          ),

                          const SizedBox(height: 32),

                          /// BOTÓN GUARDAR
                          if (!isGuest)
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.purpleAccent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: isLoading
                                    ? const CircularProgressIndicator(
                                        color: Colors.white)
                                    : const Text(
                                        'Guardar cambios',
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            ),

                          const SizedBox(height: 16),

                          /// ELIMINAR CUENTA
                          if (!isGuest)
                            TextButton.icon(
                              onPressed: _deleteAccount,
                              icon: const Icon(Icons.delete_forever,
                                  color: Colors.redAccent),
                              label: const Text(
                                'Eliminar cuenta',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  /// INPUT REUTILIZABLE
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: enabled,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.08),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.purpleAccent),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
