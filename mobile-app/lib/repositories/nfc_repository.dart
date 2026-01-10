import 'dart:async';
import 'package:bombastic_banking/domain/atm.dart';
import 'package:bombastic_banking/services/nfc_service.dart';

class NFCRepository {
  final NFCService _nfcService;
  final RegExp? tagMatcher;

  final _controller = StreamController<ATMTag>.broadcast();
  late final atmTags = _controller.stream;

  NFCRepository({required NFCService nfcService, this.tagMatcher})
    : _nfcService = nfcService {
    // Forward ATM tag records to atmTags
    _nfcService.ndefTextRecords.listen((tag) {
      if (tagMatcher == null || tagMatcher!.hasMatch(tag)) {
        _controller.add(ATMTag(id: int.parse(tag)));
      }
    });
  }

  Future<void> startReading() async {
    await _nfcService.startReading();
  }

  Future<void> stopReading() async {
    return _nfcService.stopReading();
  }
}
