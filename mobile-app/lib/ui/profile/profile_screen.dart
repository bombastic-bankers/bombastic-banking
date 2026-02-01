import 'package:bombastic_banking/ui/home/home_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bombastic_banking/ui/profile/profile_viewmodel.dart';
import 'package:bombastic_banking/route_observer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  static const _brandColor = Color(0xFFE50513);
  static const _backgroundColor = Color(0xFFF9F5F6);

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    routeObserver.subscribe(this, route as PageRoute);
  }

  @override
  void didPush() {
    super.didPush();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndSyncData();
    });
  }

  @override
  void didPopNext() {
    super.didPopNext();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAndSyncData();
    });
  }

  Future<void> _loadAndSyncData() async {
    final vm = context.read<ProfileViewModel>();
    await vm.loadProfile();

    final profile = vm.profile;
    if (profile != null) {
      _nameController.text = profile.name;
      _emailController.text = profile.email;
      _phoneController.text = profile.phone;
    }
  }

  Future<void> _handleSave() async {
    await context.read<ProfileViewModel>().saveProfile(
      _nameController.text,
      _emailController.text,
      _phoneController.text,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Profile updated and saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );

    // TODO: Do this without using another viewmodel
    if (!mounted) return;
    await context.read<HomeViewModel>().refreshUser();
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<ProfileViewModel>();

    if (vm.isLoading || vm.profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _brandColor)),
      );
    }

    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: vm.toggleEditing,
            child: Text(
              vm.isEditing ? 'Cancel' : 'Edit',
              style: const TextStyle(
                color: _brandColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Profile',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'keep your details up to date so we can send you SMSes and emails about your banking activities',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ProfileInputField(
              label: "Full Name",
              controller: _nameController,
              isEditing: vm.isEditing,
            ),
            const SizedBox(height: 20),
            ProfileInputField(
              label: "Email address",
              controller: _emailController,
              isEditing: vm.isEditing,
            ),
            const SizedBox(height: 20),
            ProfileInputField(
              label: "Phone Number",
              controller: _phoneController,
              isEditing: vm.isEditing,
            ),
            const SizedBox(height: 48),
            _SaveButton(
              isEditing: vm.isEditing,
              isLoading: vm.isLoading,
              onSave: _handleSave,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  final bool isEditing;
  final bool isLoading;
  final VoidCallback onSave;

  const _SaveButton({
    required this.isEditing,
    required this.isLoading,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton(
        onPressed: isEditing ? onSave : null,
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: isEditing ? Colors.black : Colors.grey.shade300,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              )
            : Text(
                'Save',
                style: TextStyle(
                  color: isEditing ? Colors.black : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }
}

class ProfileInputField extends StatelessWidget {
  static const _brandColor = Color(0xFFE50513);
  static const _disabledColor = Color(0xFFF0F1F3);
  static const _borderRadius = 12.0;

  final String label;
  final TextEditingController controller;
  final bool isEditing;

  const ProfileInputField({
    super.key,
    required this.label,
    required this.controller,
    required this.isEditing,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: !isEditing,
          decoration: InputDecoration(
            filled: true,
            fillColor: isEditing ? Colors.white : _disabledColor,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: isEditing
                  ? const BorderSide(color: Colors.grey)
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
              borderSide: const BorderSide(color: _brandColor, width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(_borderRadius),
            ),
          ),
        ),
      ],
    );
  }
}
