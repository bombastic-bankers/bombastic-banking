import 'package:bombastic_banking/main.dart';
import 'package:bombastic_banking/services/nfc_service.dart';
import 'package:flutter/material.dart';
import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import 'package:provider/provider.dart';
import '../../services/permission_service.dart';
import '../../repositories/agent_repository.dart';
import '../../client_tools/client_tools.dart';
import '../atm_services/nfc_prompt/nfc_prompt_widget.dart';

class AgentViewmodel extends ChangeNotifier {
  final TokenRepository _repository;
  final PermissionService _permissionService;

  late final ConversationClient _agentClient;

  bool _isConnecting = false;
  bool _isConnected = false;

  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;

  @override
  void dispose() {
    debugPrint('AgentViewmodel disposed');
    super.dispose();
  }

  AgentViewmodel({
    required TokenRepository tokenRepository,
    required PermissionService permissionService,
  }) : _repository = tokenRepository,
       _permissionService = permissionService {
    _agentClient = ConversationClient(
      callbacks: ConversationCallbacks(
        onConnect: ({required conversationId}) {
          debugPrint('Agent Connected: $conversationId');
        },

        onStatusChange: ({required status}) {
          _isConnecting = status == ConversationStatus.connecting;
          _isConnected = status == ConversationStatus.connected;

          if (status == ConversationStatus.disconnected) {
            debugPrint('Agent Status: Disconnected');
          }

          notifyListeners();
        },

        onMessage: ({required message, required source}) {
          debugPrint('Agent Message: $message from $source');
        },

        onError: (error, [dynamic _]) {
          debugPrint('Agent Error: $error');
        },
      ),
      clientTools: {
        'nfc_reader': NFCTool(
          locator<NFCService>(),
          showNfcPrompt: (context) async {
            return showModalBottomSheet<int>(
              context: context,
              isDismissible: false,
              enableDrag: false,
              builder: (_) => const NFCPromptWidget(),
            );
          },
        ),
      },
    );
  }

  Future<void> initAssistant() async {
    if (_isConnected || _isConnecting) {
      debugPrint("Assistant is already connected or connecting.");
      return;
    }
    final granted = await _permissionService.requestMicrophone();
    if (!granted) {
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
      debugPrint("mic perms: $granted");
      await _agentClient.startSession(conversationToken: token);
    } catch (e) {
      debugPrint("Assistant Error: $e");
    }
  }

  Future<void> endSession() async {
    await _agentClient.endSession();
  }
}
