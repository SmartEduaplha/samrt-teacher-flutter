import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/providers/db_providers.dart';
import '../../../../core/extensions/l10n_extensions.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _subjectController;
  bool _isSaving = false;
  XFile? _imageFile;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider).value;
    _nameController = TextEditingController(text: user?.fullName);
    _phoneController = TextEditingController(text: user?.phone);
    _subjectController = TextEditingController(text: user?.subject);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final authService = ref.read(authServiceProvider);
      
      String? imageUrl;
      if (_imageFile != null) {
        // رفع الصورة والحصول على الرابط
        imageUrl = await authService.uploadProfileImage(_imageFile!);
      }
      
      final updateData = {
        'full_name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'subject': _subjectController.text.trim(),
      };
      
      if (imageUrl != null) {
        updateData['profile_picture'] = imageUrl;
      }
      
      await authService.updateProfile(updateData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.profileUpdateSuccess)),
        );
        ref.invalidate(currentUserProvider);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.updateError(e.toString()))),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.profile),
        actions: [
          if (_isSaving)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
              ),
            )
          else
            IconButton(
              onPressed: _saveProfile,
              icon: const Icon(Icons.check_rounded),
              tooltip: context.l10n.saveChanges,
            ),
        ],
      ),
      body: userAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (user) {
          if (user == null) return Center(child: Text(context.l10n.userNotConnected));

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // --- الصورة الشخصية ---
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 60,
                        backgroundColor: theme.colorScheme.primaryContainer,
                        backgroundImage: _imageFile != null
                            ? (kIsWeb ? NetworkImage(_imageFile!.path) : FileImage(File(_imageFile!.path)) as ImageProvider)
                            : (user.profilePicture != null ? NetworkImage(user.profilePicture!) : null),
                        child: (user.profilePicture == null && _imageFile == null)
                            ? Icon(Icons.person_rounded, size: 60, color: theme.colorScheme.primary)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Material(
                          color: theme.colorScheme.primary,
                          shape: const CircleBorder(),
                          elevation: 4,
                          child: IconButton(
                            onPressed: _pickImage,
                            icon: const Icon(Icons.camera_alt_rounded, size: 20, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // --- معلومات الحساب ---
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                            controller: _nameController,
                            label: context.l10n.teacherFullName,
                            icon: Icons.person_outline_rounded,
                            validator: (v) => v!.isEmpty ? context.l10n.invalidName : null,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _phoneController,
                            label: context.l10n.phone,
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            controller: _subjectController,
                            label: context.l10n.teacherSubject,
                            icon: Icons.menu_book_outlined,
                          ),
                          const SizedBox(height: 16),
                          // البريد الإلكتروني (للقراءة فقط)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.email_outlined),
                            title: Text(context.l10n.email, style: const TextStyle(fontSize: 12)),
                            subtitle: Text(user.email, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: FilledButton.icon(
                      onPressed: _isSaving ? null : _saveProfile,
                      icon: const Icon(Icons.save_rounded),
                      label: Text(context.l10n.saveChanges),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      validator: validator,
    );
  }
}
