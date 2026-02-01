import 'dart:async';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager_ndef/nfc_manager_ndef.dart';
import 'package:ndef_record/ndef_record.dart' as ndef_record;
import 'package:flutter/foundation.dart';

class NFCService {
  final _controller = StreamController<String>.broadcast();

  /// Stream that emits NDEF text records as they are read.
  late final ndefTextRecords = _controller.stream;

  Future<void> startReading() async {
    debugPrint('service: Starting NFC reading');
    await NfcManager.instance.startSession(
      pollingOptions: {NfcPollingOption.iso14443},
      onDiscovered: (tag) async {
        final records = Ndef.from(tag)?.cachedMessage?.records.where(
          (r) =>
              r.typeNameFormat == ndef_record.TypeNameFormat.wellKnown &&
              r.type.firstOrNull == 0x54 /* 'T' for Text */,
        );
        if (records == null) return;

        for (final record in records) {
          // The payload starts with encoding/language info.
          // Skip first byte (status) and next two bytes (language code).
          // Language code is variable length, but this code assumes it's 2 bytes.
          // TODO: Handle variable-length language codes properly.
          final text = String.fromCharCodes(record.payload.sublist(3));
          _controller.add(text);
          debugPrint('service: Read NDEF text record: $text');
        }
      },
    );
    debugPrint('service: NFC reading finished');
  }

  Future<void> stopReading() async {
    await NfcManager.instance.stopSession();
  }
}
