import 'dart:async';
import 'nfc_service.dart';

extension NFCAgentExtension on NFCService {
  Future<String> readNFCForAgent() async {
    await startReading();

    try {
      // We wrap this in a timeout so it doesn't wait forever.
      final String tagData = await ndefTextRecords.first.timeout(
        const Duration(seconds: 20),
        onTimeout: () => throw TimeoutException("NFC detection timed out."),
      );

      return tagData;
    } catch (e) {
      // Any error (timeout or hardware) is rethrown after stopping the antenna
      rethrow;
    } finally {
      await stopReading();
    }
  }
}
