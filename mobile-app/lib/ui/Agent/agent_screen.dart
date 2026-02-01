import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'agent_viewmodel.dart';

class AgentScreen extends StatefulWidget {
  const AgentScreen({super.key});

  @override
  State<AgentScreen> createState() => _AgentScreenState();
}

class _AgentScreenState extends State<AgentScreen> {
  final List<String> debugMessages = [];

  void addDebugMessage(String msg) {
    setState(() {
      debugMessages.add(msg);
    });
  }

  @override
  void initState() {
    super.initState();

    // Wait for widget tree to be ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<AgentViewmodel>();

      // Set the appContext for NFCTool modal
      vm.appContext = context;

      // Wire up debug messages to screen
      vm.onDebugMessage = addDebugMessage;

      // Optionally, start assistant after wiring debug
      // vm.initAssistant();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AgentViewmodel>();
    final isConnecting = context.select<AgentViewmodel, bool>(
      (v) => v.isConnecting,
    );
    final isConnected = context.select<AgentViewmodel, bool>(
      (v) => v.isConnected,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('AI Agent')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Agent status
            isConnecting
                ? const CircularProgressIndicator(color: brandRed)
                : const Text("Agent is active and listening..."),
            const SizedBox(height: 8),
            isConnected
                ? const Text("Agent is connected.")
                : const Text("Agent is not connected."),
            const SizedBox(height: 16),

            // End session button
            AppButton(text: 'End Session', onPressed: vm.endSession),
            const SizedBox(height: 24),

            // Debug console header
            const Text(
              'NFCTool Debug Messages:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            // Debug message list
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ListView.builder(
                  itemCount: debugMessages.length,
                  itemBuilder: (_, index) {
                    return Text(
                      debugMessages[index],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
