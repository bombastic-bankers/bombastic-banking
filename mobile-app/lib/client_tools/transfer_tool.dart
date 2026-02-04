import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import '../services/transfer_service.dart';

class TransferTool implements ClientTool {
  final TransferService _transferService;
  final Function(String)? onDebug;
  final Function(String) onResult;

  TransferTool(
    this._transferService, {
    this.onDebug,
    required this.onResult,
  });

  @override
  Future<ClientToolResult?> execute(Map<String, dynamic> parameters) async {
    _debug('TransferTool execution started.');

    // Extract parameters from Agent
    final recipientPhone = parameters['recipient_phone'];
    final amount = parameters['amount'];

    // Check if parameters are null
    if (recipientPhone == null) {
      _debug('Recipient phone is null.');
      onResult('SYSTEM: Transfer failed. Recipient phone number is required.');
      return ClientToolResult.success({});
    }

    if (amount == null) {
      _debug('Amount is null.');
      onResult('SYSTEM: Transfer failed. Amount is required.');
      return ClientToolResult.success({});
    }

    // Convert amount to num
    final num transferAmount;
    if (amount is num) {
      transferAmount = amount;
    } else if (amount is String) {
      final parsed = num.tryParse(amount);
      if (parsed == null) {
        _debug('Failed to parse amount: $amount');
        onResult('SYSTEM: Transfer failed. Invalid amount format.');
        return ClientToolResult.success({});
      }
      transferAmount = parsed;
    } else {
      _debug('Invalid amount type: ${amount.runtimeType}');
      onResult('SYSTEM: Transfer failed. Invalid amount type.');
      return ClientToolResult.success({});
    }

    // Format phone number: if 8 digits, prepend "+65"
    String formattedPhone = recipientPhone.toString().trim();
    if (RegExp(r'^\d{8}$').hasMatch(formattedPhone)) {
      formattedPhone = '+65$formattedPhone';
    }
    _debug('Formatted phone: $formattedPhone, Amount: $transferAmount');

    // Send processing status to Agent
    onResult('SYSTEM: Processing transfer of \$$transferAmount to $formattedPhone...');

    try {
      // Call the transfer service
      final transactionId = await _transferService.transferMoney(
        recipient: formattedPhone,
        amount: transferAmount,
      );

      _debug('Transfer successful. Transaction ID: $transactionId');
      // Success: notify the Agent
      onResult('SYSTEM: Transfer successful. Sent \$$transferAmount to $formattedPhone. Transaction ID: $transactionId.');
    } catch (e) {
      _debug('Transfer failed: ${e.toString()}');
      // Error: notify the Agent with error details
      onResult('SYSTEM: Transfer failed due to ${e.toString().replaceFirst('Exception: ', '')}. Please try again or contact support.');
    }

    // CRITICAL: Always return success with empty map to avoid crashing the voice session
    return ClientToolResult.success({});
  }

  void _debug(String message) {
    if (onDebug != null) {
      onDebug!(message);
    }
  }
}
