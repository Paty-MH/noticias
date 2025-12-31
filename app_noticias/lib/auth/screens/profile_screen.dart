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
    final user = context.read<AuthBloc>().state;
    if (user is AuthAuthenticated) {
      _nameCtrl.text = user.user.name;
      _phoneCtrl.text = user.user.phone;
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _imageFile = File(picked.path));
  }

  void _updateProfile() {
    context.read<AuthBloc>().add(
      UpdateProfileRequested(
        name: _nameCtrl.text,
        phone: _phoneCtrl.text,
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
      appBar: AppBar(
        title: const Text('Perfil'),
        backgroundColor: Colors.purpleAccent,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                context.read<AuthBloc>().add(const LogoutRequested()),
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError)
            NotificationService.error(context, state.message);
          if (state is AuthAuthenticated) {
            _nameCtrl.text = state.user.name;
            _phoneCtrl.text = state.user.phone;
          }
          if (state is AuthUnauthenticated)
            Navigator.pushReplacementNamed(context, '/login');
        },
        builder: (context, state) {
          if (state is AuthLoading)
            return const Center(child: CircularProgressIndicator());
          if (state is AuthAuthenticated) {
            return Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 60,
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : (state.user.imageUrl.isNotEmpty
                                    ? NetworkImage(state.user.imageUrl)
                                    : null)
                                as ImageProvider?,
                      child: state.user.imageUrl.isEmpty && _imageFile == null
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _nameCtrl,
                    decoration: const InputDecoration(labelText: 'Nombre'),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _phoneCtrl,
                    decoration: const InputDecoration(labelText: 'Teléfono'),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _updateProfile,
                    child: const Text('Guardar'),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _deleteAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Eliminar cuenta'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
