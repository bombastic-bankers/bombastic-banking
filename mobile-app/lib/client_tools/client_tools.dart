import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import '../services/nfc_service.dart';
import '../services/nfc_service_agent_ext.dart';
import 'package:flutter/material.dart';
import '../../ui/atm_services/nfc_prompt/nfc_prompt_widget.dart';

class NFCTool implements ClientTool {
  final NFCService _nfcService;
  final Future<int?> Function(BuildContext context)? showNfcPrompt;

  NFCTool(this._nfcService, {this.showNfcPrompt});

  @override
  Future<ClientToolResult?> execute(Map<String, dynamic> parameters) async {
    try {
      int? atmId;

      // If we have a context callback, show the NFC widget
      if (showNfcPrompt != null && parameters.containsKey('context')) {
        final context = parameters['context'] as BuildContext;
        atmId = await showNfcPrompt!(context);
      } else {
        // Fallback: directly read from service
        final result = await _nfcService.readNFCForAgent();
        atmId = int.tryParse(result);
      }

      if (atmId == null) {
        return ClientToolResult.failure(
          'User cancelled NFC scan or invalid result',
        );
      }

      return ClientToolResult.success({'atmId': atmId});
    } catch (e) {
      return ClientToolResult.failure(e.toString());
    }
  }
}
