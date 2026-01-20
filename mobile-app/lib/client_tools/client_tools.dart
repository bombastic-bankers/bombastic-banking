import 'package:bombastic_banking/services/nfc_service.dart';
import 'package:elevenlabs_agents/elevenlabs_agents.dart';

class NFCTool implements ClientTool {
  final NFCService _nfcService;

  NFCTool(this._nfcService);

  @override
  Future<ClientToolResult?> execute(Map<String, dynamic> parameters) async {
    try {
      await _nfcService.startReading();

      return ClientToolResult.success({
        'status': 'NFC_SCANNER_STARTED',
        'instruction': 'Tell the user to hold their phone near the card now.',
      });
    } catch (e) {
      // 3. If something crashes, we tell the AI it failed so it can apologize.
      return ClientToolResult.failure('Could not start NFC: $e');
    }
  }
}
