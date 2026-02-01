import 'package:elevenlabs_agents/elevenlabs_agents.dart';
import 'package:flutter/foundation.dart';
import '../services/nfc_service.dart';
import '../services/nfc_service_agent_ext.dart';
import '../services/atm_service.dart';
import '../storage/secure_storage.dart';

class NFCTool implements ClientTool {
  final NFCService _nfcService;
  final Future<int?> Function()? showNfcPrompt;
  final Function(String)? onDebug;
  final Function(String)? onResult;

  NFCTool(this._nfcService, {this.showNfcPrompt, this.onDebug, this.onResult});

  @override
  Future<ClientToolResult?> execute(Map<String, dynamic> parameters) async {
    try {
      _debug('Tool execution started.');

      int? atmId;

      if (showNfcPrompt != null) {
        _debug('Showing NFC prompt to user...');
        atmId = await showNfcPrompt!();
        _debug('Prompt returned atmId: $atmId');
      } else {
        _debug('Reading NFC directly from service...');
        final raw = await _nfcService.readNFCForAgent();
        _debug('Raw NFC result: $raw');
        atmId = int.tryParse(raw);
        _debug('Parsed atmId: $atmId');
      }

      if (atmId == null) {
        _debug('No ATM ID found. Returning failure.');
        return ClientToolResult.failure('User cancelled or invalid NFC.');
      }

      _debug('Returning success with atmId: $atmId');
      _debug(ClientToolResult.success({'atmId': atmId}).toString());
      onResult?.call(atmId.toString());
      return null;
    } catch (e) {
      _debug('Exception caught: ${e.toString()}');
      return ClientToolResult.failure(e.toString());
    }
  }

  void _debug(String message) {
    if (onDebug != null) {
      onDebug!(message);
    }
  }
}

class WithdrawTool extends ClientTool {
  final ATMService _atmService;
  final SecureStorage _secureStorage;
  final Function(String)? onDebug;
  final Function(String) onResult;

  WithdrawTool(
    this._atmService,
    this._secureStorage, {
    this.onDebug,
    required this.onResult,
  });

  @override
  Future<ClientToolResult?> execute(Map<String, dynamic> parameters) async {
    final String? sessionToken = await _secureStorage.getSessionToken();
    final int atmId = parameters['atmId'];
    final double amount = parameters['amount'].toDouble();

    _debug('WithdrawTool execution started for amount: $amount');

    try {
      await _atmService.withdrawCash(
        sessionToken: sessionToken!,
        atmId: atmId,
        amount: amount,
      );

      onResult.call(amount.toString());
      return ClientToolResult.success("Withdrawal of \$$amount initiated.");
    } catch (e) {
      _debug('Exception caught during withdrawal: ${e.toString()}');
      return ClientToolResult.failure(e.toString());
    }
  }

  void _debug(String message) {
    if (onDebug != null) {
      onDebug!(message);
    }
  }
}

class DepositStart extends ClientTool {
  final ATMService _atmService;
  final SecureStorage _secureStorage;
  final Function(String)? onDebug;
  final Function(dynamic) onResult;

  DepositStart(
    this._atmService,
    this._secureStorage, {
    this.onDebug,
    required this.onResult,
  });

  @override
  Future<ClientToolResult?> execute(Map<String, dynamic> parameters) async {
    final String? sessionToken = await _secureStorage.getSessionToken();
    final int atmId = parameters['atmId'];

    _debug('DepositStart execution started.');

    try {
      await _atmService.startCashDeposit(
        sessionToken: sessionToken!,
        atmId: atmId,
      );

      onResult.call(atmId);
      return ClientToolResult.success({});
    } catch (e) {
      _debug('Exception caught during deposit start: ${e.toString()}');
      return ClientToolResult.failure(e.toString());
    }
  }

  void _debug(String message) {
    if (onDebug != null) {
      onDebug!(message);
    }
  }
}

class DepositCount extends ClientTool {
  final ATMService _atmService;
  final SecureStorage _secureStorage;
  final Function(String)? onDebug;
  final Function(double) onResult;

  DepositCount(
    this._atmService,
    this._secureStorage, {
    this.onDebug,
    required this.onResult,
  });

  @override
  Future<ClientToolResult?> execute(Map<String, dynamic> parameters) async {
    final String? sessionToken = await _secureStorage.getSessionToken();
    final int atmId = parameters['atmId'];

    _debug('DepositCount execution started.');

    try {
      final amount = await _atmService.countCashDeposit(
        sessionToken: sessionToken!,
        atmId: atmId,
      );

      onResult.call(amount);
      return ClientToolResult.success({});
    } catch (e) {
      _debug('Exception caught during deposit count: ${e.toString()}');
      return ClientToolResult.failure(e.toString());
    }
  }

  void _debug(String message) {
    if (onDebug != null) {
      onDebug!(message);
    }
  }
}

class DepositConfirm extends ClientTool {
  final ATMService _atmService;
  final SecureStorage _secureStorage;
  final Function(String)? onDebug;
  final Function(String) onResult;

  DepositConfirm(
    this._atmService,
    this._secureStorage, {
    this.onDebug,
    required this.onResult,
  });

  @override
  Future<ClientToolResult?> execute(Map<String, dynamic> parameters) async {
    final String? sessionToken = await _secureStorage.getSessionToken();
    final int atmId = parameters['atmId'];

    _debug('DepositConfirm execution started.');

    try {
      await _atmService.confirmCashDeposit(
        sessionToken: sessionToken!,
        atmId: atmId,
      );

      onResult.call("succeeded");
      return null;
    } catch (e) {
      _debug('Exception caught during deposit confirm: ${e.toString()}');
      onResult.call("failed");
      return ClientToolResult.failure(e.toString());
    }
  }

  void _debug(String message) {
    if (onDebug != null) {
      onDebug!(message);
    }
  }
}
