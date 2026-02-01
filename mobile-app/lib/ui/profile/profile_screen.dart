// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bombastic_banking/ui/profile/profile_viewmodel.dart';
import 'package:bombastic_banking/ui/home/home_viewmodel.dart';
import 'package:bombastic_banking/route_observer.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with RouteAware {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void didPush() {
    super.didPush();
    _loadAndSyncData();
  }

  @override
  void didPopNext() {
    super.didPopNext();
    _loadAndSyncData();
  }

  Future<void> _loadAndSyncData() async {
    final vm = context.read<ProfileViewModel>();
    await vm.loadProfile();
    
    if (vm.profile != null) {
      _nameController.text = vm.profile!.name;
      _emailController.text = vm.profile!.email;
      _phoneController.text = vm.profile!.phone;
    }
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
        body: Center(child: CircularProgressIndicator(color: Color(0xFFE50513))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF9F5F6),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => vm.toggleEditing(),
            child: Text(
              vm.isEditing ? 'Cancel' : 'Edit',
              style: const TextStyle(
                color: Color(0xFFE50513),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: vm.isLoading || vm.profile == null
          ? const Center(child: CircularProgressIndicator(color: Color(0xFFE50513)))
          : SingleChildScrollView(
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

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: OutlinedButton(
                      onPressed: vm.isEditing
                          ? () async {
                              await vm.saveProfile(
                                _nameController.text,
                                _emailController.text,
                                _phoneController.text,
                              );
                              context.read<HomeViewModel>().refreshUser();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Profile updated and saved!'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          : null,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: vm.isEditing ? Colors.black : Colors.grey.shade300,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: vm.isLoading
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
                                color: vm.isEditing ? Colors.black : Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}

class ProfileInputField extends StatelessWidget {
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
            fillColor: isEditing ? Colors.white : const Color(0xFFF0F1F3),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: isEditing 
                  ? const BorderSide(color: Colors.grey) 
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE50513), width: 2),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}