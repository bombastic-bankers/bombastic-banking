import 'package:flutter/material.dart';
import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import '../../services/permission_service.dart';
import '../../repositories/agent_repository.dart';

class AgentViewmodel extends ChangeNotifier {
  final TokenRepository _repository;
  final PermissionService _permissionService;

  AgentViewmodel({
    required TokenRepository tokenRepository,
    required PermissionService permissionService,
  }) : _repository = tokenRepository,
       _permissionService = permissionService;

  final ConversationClient _agentClient = ConversationClient(
    callbacks: ConversationCallbacks(
      onConnect: ({required conversationId}) => debugPrint("Agent Connected:"),
      onMessage: ({required message, required source}) =>
          debugPrint("Agent Message: $message from $source"),
      onError: (string, [dynamic]) => debugPrint("Agent Error: $string"),
    ),
  );

  bool _isConnecting = false;
  bool get isConnecting => _isConnecting;

  Future<void> initAssistant() async {
    _isConnecting = true;
    notifyListeners();
    final granted = await _permissionService.requestMicrophone();
    if (!granted) {
      // Check if we need to tell the user to go to settings
      if (await _permissionService.isPermanentlyDenied()) {
        debugPrint(
          "Microphone permission permanently denied. Please enable it in settings.",
        );
      } else {
        debugPrint("Microphone permission denied.");
      }
      return;
    }
    try {
      final token = await _repository.getConversationToken();

      await _agentClient.startSession(conversationToken: token);
    } catch (e) {
      debugPrint("Assistant Error: $e");
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> endSession() async {
    await _agentClient.endSession();
  }
}
