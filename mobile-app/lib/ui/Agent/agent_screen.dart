import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'agent_viewmodel.dart';

class AgentScreen extends StatelessWidget {
  const AgentScreen({super.key});

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
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              isConnecting
                  ? const CircularProgressIndicator(color: brandRed)
                  : const Text("Agent is active and listening..."),
              AppButton(text: 'End Session', onPressed: vm.endSession),
              isConnected
                  ? const Text("Agent is connected.")
                  : const Text("Agent is not connected."),
            ],
          ),
        ),
      ),
    );
  }
}
