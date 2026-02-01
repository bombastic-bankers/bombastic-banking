import 'package:bombastic_banking/main.dart';
import 'package:bombastic_banking/services/atm_service.dart';
import 'package:bombastic_banking/services/nfc_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import '../../services/permission_service.dart';
import '../../repositories/agent_repository.dart';
import '../../client_tools/client_tools.dart';
import '../atm_services/nfc_prompt/nfc_prompt_widget.dart';

class AgentViewmodel extends ChangeNotifier {
  final TokenRepository _repository;
  final PermissionService _permissionService;
  final SecureStorage _secureStorage;

  late final ConversationClient _agentClient;

  bool _isConnecting = false;
  bool _isConnected = false;

  bool get isConnecting => _isConnecting;
  bool get isConnected => _isConnected;

  /// The app context is needed for showing the NFC modal
  late BuildContext appContext;

  /// Callback for sending debug messages to the screen
  void Function(String message)? onDebugMessage;

  @override
  void dispose() {
    debugPrint('AgentViewmodel disposed');
    super.dispose();
  }

  AgentViewmodel({
    required TokenRepository tokenRepository,
    required PermissionService permissionService,
    required SecureStorage secureStorage,
  }) : _repository = tokenRepository,
       _permissionService = permissionService,
       _secureStorage = secureStorage {
    _agentClient = ConversationClient(
      callbacks: ConversationCallbacks(
        onConnect: ({required conversationId}) {
          _sendDebug('Agent Connected: $conversationId');
        },

        onStatusChange: ({required status}) {
          _isConnecting = status == ConversationStatus.connecting;
          _isConnected = status == ConversationStatus.connected;

          _sendDebug('Agent status changed: $status');

          notifyListeners();
        },

        onMessage: ({required message, required source}) {
          _sendDebug('Agent Message: $message from $source');
        },

        onError: (error, [dynamic _]) {
          debugPrint('Agent Error: $error');
        },
        onAgentToolResponse: (response) {
          debugPrint('Tool ${response.toolName} executed');
        },
      ),
      clientTools: {
        'nfc_reader': NFCTool(
          locator<NFCService>(),
          showNfcPrompt: () async {
            _sendDebug('Opening NFC prompt...');
            final atmId = await showModalBottomSheet<int>(
              context: appContext,
              isDismissible: false,
              enableDrag: false,
              builder: (_) => const NFCPromptWidget(),
            );
            _sendDebug('NFC prompt closed, atmId: $atmId');
            return atmId;
          },
          onDebug: (msg) => _sendDebug(msg),
          onResult: (atmId) async {
            final token = await _secureStorage.getSessionToken();
            if (token == null) {
              _agentClient.sendContextualUpdate(
                'No session token found in secure storage. Token retrieval failed.',
              );
              return;
            }
            _agentClient.sendContextualUpdate(
              'IMPORTANT: The user has authenticated. '
              'Set the dynamic variable secret__session_token to "$token" ' // Explicit mention of secret__ as variable
              'and set the dynamic variable atmId to "$atmId".',
            );
          },
        ),
        'withdraw_cash': WithdrawTool(
          locator<ATMService>(),
          _secureStorage,
          onDebug: (msg) => _sendDebug(msg),
          onResult: (amount) {
            _agentClient.sendContextualUpdate('Amount withdrawn: $amount');
          },
        ),
        "deposit_start": DepositStart(
          locator<ATMService>(),
          _secureStorage,
          onDebug: (msg) => _sendDebug(msg),
          onResult: (atmId) {
            _agentClient.sendContextualUpdate(
              'Deposit started at ATM ID: $atmId',
            );
          },
        ),
        "deposit_count": DepositCount(
          locator<ATMService>(),
          _secureStorage,
          onDebug: (msg) => _sendDebug(msg),
          onResult: (amount) {
            _agentClient.sendContextualUpdate('Deposit counted: $amount');
          },
        ),
        "deposit_confirm": DepositConfirm(
          locator<ATMService>(),
          _secureStorage,
          onDebug: (msg) => _sendDebug(msg),
          onResult: (msg) {
            _agentClient.sendContextualUpdate('Deposit $msg');
          },
        ),
      },
    );
  }

  /// forward debug messages to the UI
  void _sendDebug(String msg) {
    if (onDebugMessage != null) {
      onDebugMessage!(msg);
    } else {
      debugPrint(msg);
    }
  }

  Future<void> initAssistant() async {
    if (_isConnected || _isConnecting) {
      _sendDebug("Assistant is already connected or connecting.");
      return;
    }

    final granted = await _permissionService.requestMicrophone();
    if (!granted) {
      if (await _permissionService.isPermanentlyDenied()) {
        _sendDebug(
          "Microphone permission permanently denied. Please enable it in settings.",
        );
      } else {
        _sendDebug("Microphone permission denied.");
      }
      return;
    }

    try {
      final token = await _repository.getConversationToken();
      _sendDebug("Microphone permissions granted: $granted");
      await _agentClient.startSession(conversationToken: token);
    } catch (e) {
      _sendDebug("Assistant Error: $e");
    }
  }

  Future<void> endSession() async {
    await _agentClient.endSession();
    _sendDebug("Assistant session ended.");
  }
}
