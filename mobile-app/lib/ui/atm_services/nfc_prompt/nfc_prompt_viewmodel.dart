import 'package:bombastic_banking/repositories/nfc_repository.dart';
import 'package:flutter/material.dart';

class NFCPromptViewModel extends ChangeNotifier {
  final NFCRepository _nfcRepository;
  late final atmTags = _nfcRepository.atmTags;
  var reading = false;

  NFCPromptViewModel({required NFCRepository nfcRepository})
    : _nfcRepository = nfcRepository;

  Future<void> startReading() async {
    await _nfcRepository.startReading();
    reading = true;
    notifyListeners();
  }

  Future<void> stopReading() async {
    await _nfcRepository.stopReading();
    reading = false;
    notifyListeners();
  }
}
