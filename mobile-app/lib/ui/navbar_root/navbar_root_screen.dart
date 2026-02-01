import 'package:bombastic_banking/ui/atm_services/atm_services_screen.dart';
import 'package:bombastic_banking/ui/home/home_screen.dart';
import 'package:bombastic_banking/ui/navbar_root/navbar_root_viewmodel.dart';
import 'package:bombastic_banking/ui/profile/profile_screen.dart';
import 'package:bombastic_banking/ui/transfer/transfer_contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NavbarRootScreen extends StatefulWidget {
  final int startingIndex;

  const NavbarRootScreen({super.key, this.startingIndex = 0});

  @override
  State<NavbarRootScreen> createState() => _NavbarRootScreenState();
}

class _NavbarRootScreenState extends State<NavbarRootScreen> {
  final List<Widget> _screens = [
    const HomeScreen(),
    const ATMServicesScreen(),
    const TransferScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<NavbarRootViewModel>();
      vm.index = widget.startingIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NavbarRootViewModel>();

    return PopScope(
      canPop: vm.index == 0,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && vm.index != 0) {
          vm.index = 0;
        }
      },
      child: Scaffold(
        body: IndexedStack(index: vm.index, children: _screens),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: vm.index,
          onTap: (i) => vm.index = i,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          selectedFontSize: 12,
          unselectedItemColor: Theme.of(context).colorScheme.onSurfaceVariant,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.local_atm_outlined),
              label: 'ATM Services',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payment_outlined),
              label: 'Pay & Transfer',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outlined),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
