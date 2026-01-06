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
    if (state is AuthAuthenticated) {
      _nameCtrl.text = state.user.name;
      _phoneCtrl.text = state.user.phone;
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  void _updateProfile() {
    context.read<AuthBloc>().add(
          UpdateProfileRequested(
            name: _nameCtrl.text.trim(),
            phone: _phoneCtrl.text.trim(),
            imageUrl: '',
          ),
        );
  }

  void _deleteAccount() {
    context.read<AuthBloc>().add(DeleteAccountRequested());
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
              if (state is AuthError) {
                NotificationService.error(context, state.message);
              }
              if (state is AuthUnauthenticated) {
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
            builder: (context, state) {
              if (state is AuthLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.purpleAccent,
                  ),
                );
              }

              if (state is AuthAuthenticated) {
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      /// 🔥 HEADER
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
                            icon: const Icon(
                              Icons.logout,
                              color: Colors.purpleAccent,
                            ),
                            onPressed: () => context
                                .read<AuthBloc>()
                                .add(const LogoutRequested()),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      /// 🔥 CARD PRINCIPAL
                      Container(
                        constraints: const BoxConstraints(maxWidth: 460),
                        padding: const EdgeInsets.all(28),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(26),
                          color: Colors.white.withOpacity(0.06),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.15),
                          ),
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
                            /// 🔥 AVATAR
                            GestureDetector(
                              onTap: _pickImage,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Color(0xFFB721FF),
                                      Color(0xFFFF8C00),
                                    ],
                                  ),
                                ),
                                child: CircleAvatar(
                                  radius: 62,
                                  backgroundColor: Colors.black,
                                  backgroundImage: _imageFile != null
                                      ? FileImage(_imageFile!)
                                      : (state.user.imageUrl.isNotEmpty
                                          ? NetworkImage(state.user.imageUrl)
                                          : null) as ImageProvider?,
                                  child: state.user.imageUrl.isEmpty &&
                                          _imageFile == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 64,
                                          color: Colors.white70,
                                        )
                                      : null,
                                ),
                              ),
                            ),

                            const SizedBox(height: 12),

                            const Text(
                              'Toca la imagen para cambiarla',
                              style: TextStyle(
                                color: Colors.white54,
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 32),

                            /// INPUTS
                            _inputField(
                              controller: _nameCtrl,
                              label: 'Nombre',
                              icon: Icons.person,
                            ),

                            const SizedBox(height: 16),

                            _inputField(
                              controller: _phoneCtrl,
                              label: 'Teléfono',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                            ),

                            const SizedBox(height: 32),

                            /// 🔥 BOTÓN GUARDAR
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(14),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFFB721FF),
                                    Color(0xFF8A2BE2),
                                    Color(0xFFFF8C00),
                                  ],
                                ),
                              ),
                              child: ElevatedButton(
                                onPressed: _updateProfile,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),
                                child: const Text(
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

                            /// ❌ ELIMINAR
                            TextButton.icon(
                              onPressed: _deleteAccount,
                              icon: const Icon(
                                Icons.delete_forever,
                                color: Colors.redAccent,
                              ),
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
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  /// 🎯 INPUT REUTILIZABLE
  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
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
