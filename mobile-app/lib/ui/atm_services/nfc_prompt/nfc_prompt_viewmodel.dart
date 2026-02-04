import 'package:bombastic_banking/repositories/nfc_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

class NFCPromptViewModel extends ChangeNotifier {
  final NFCRepository _nfcRepository;
  late final atmTags = _nfcRepository.atmTags;

  NFCPromptViewModel({required NFCRepository nfcRepository})
    : _nfcRepository = nfcRepository;

  Future<void> startReading() async {
    await _nfcRepository.startReading();
    debugPrint('NFC reading started');
  }

  Future<void> stopReading() async {
    await _nfcRepository.stopReading();
    debugPrint('NFC reading stopped');
  }
}
