import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import '../services/transfer_service.dart';

class TransferTool implements ClientTool {
  final TransferService _transferService;
  final void Function(String) _sendUpdate;

  TransferTool(this._transferService, {required void Function(String) sendUpdate})
      : _sendUpdate = sendUpdate;

  @override
  Future<ClientToolResult?> execute(Map<String, dynamic> parameters) async {
    // Extract parameters from Agent
    final recipientPhone = parameters['recipient_phone'];
    final amount = parameters['amount'];

    // Check if parameters are null
    if (recipientPhone == null) {
      _sendUpdate('SYSTEM: Transfer failed. Recipient phone number is required.');
      return ClientToolResult.success({});
    }

    if (amount == null) {
      _sendUpdate('SYSTEM: Transfer failed. Amount is required.');
      return ClientToolResult.success({});
    }

    // Convert amount to num
    final num transferAmount;
    if (amount is num) {
      transferAmount = amount;
    } else if (amount is String) {
      final parsed = num.tryParse(amount);
      if (parsed == null) {
        _sendUpdate('SYSTEM: Transfer failed. Invalid amount format.');
        return ClientToolResult.success({});
      }
      transferAmount = parsed;
    } else {
      _sendUpdate('SYSTEM: Transfer failed. Invalid amount type.');
      return ClientToolResult.success({});
    }

    // Format phone number: if 8 digits, prepend "+65"
    String formattedPhone = recipientPhone.toString().trim();
    if (RegExp(r'^\d{8}$').hasMatch(formattedPhone)) {
      formattedPhone = '+65$formattedPhone';
    }

    // Send processing status to Agent
    _sendUpdate('SYSTEM: Processing transfer of \$$transferAmount to $formattedPhone...');

    try {
      // Call the transfer service
      await _transferService.transferMoney(
        recipient: formattedPhone,
        amount: transferAmount,
      );

      // Success: notify the Agent
      _sendUpdate('SYSTEM: Transfer successful. Sent \$$transferAmount to $formattedPhone.');
    } catch (e) {
      // Error: notify the Agent with error details
      _sendUpdate('SYSTEM: Transfer failed due to ${e.toString().replaceFirst('Exception: ', '')}. Please try again or contact support.');
    }

    // CRITICAL: Always return success with empty map to avoid crashing the voice session
    return ClientToolResult.success({});
  }
}
