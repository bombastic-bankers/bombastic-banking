import 'package:bombastic_banking/ui/atm_services/nfc_prompt/nfc_prompt_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Creates a widget that prompts the user to tap their phone on an ATM's NFC tag.
/// Automatically dismisses when a tag is scanned, calling `Navigator.pop()` with the tag's `int` ID.
class NFCPromptWidget extends StatefulWidget {
  const NFCPromptWidget({super.key});

  @override
  State<NFCPromptWidget> createState() => _NFCPromptWidgetState();
}

class _NFCPromptWidgetState extends State<NFCPromptWidget> {
  // Cached for dispose()
  late final NFCPromptViewModel _vm;

  @override
  void initState() {
    super.initState();
    final vm = context.read<NFCPromptViewModel>();
    vm.startReading();

    vm.atmTags.first.then((tag) async {
      await vm.stopReading();
      if (!mounted) return;
      Navigator.of(context).pop(tag.id);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _vm = context.read<NFCPromptViewModel>();
  }

  @override
  void dispose() {
    _vm.stopReading();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<NFCPromptViewModel>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          vm.stopReading();
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 48.0, horizontal: 32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.nfc_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(height: 24),

            const Text(
              'NFC Tap Required',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 12),

            const Text(
              'Tap your phone on the ATM\'s NFC tag to proceed',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 32),

            TextButton(
              onPressed: () {
                vm.stopReading();
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}
