import 'package:action_slider/action_slider.dart';
import 'package:bombastic_banking/app_constants.dart';
import 'package:bombastic_banking/domain/user.dart';
import 'package:bombastic_banking/services/transfer_service.dart';
import 'package:bombastic_banking/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:bombastic_banking/ui/transfer/transfer_success_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  final User recipient;
  final double amount;
  final String? note;

  const ConfirmationScreen({
    super.key,
    required this.recipient,
    required this.amount,
    this.note,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final _transferService = TransferService(baseUrl: apiBaseUrl);

  final _storage = DefaultSecureStorage();

  // ignore: unused_field
  bool _isTransferring = false;

  Future<void> _handleTransfer(ActionSliderController controller) async {
    try {
      setState(() => _isTransferring = true);

      final token = await _storage.getSessionToken();
      if (token == null) throw Exception("Not logged in");

      await _transferService.transferMoney(
        token,
        widget.recipient.phoneNumber!,
        widget.amount,
      );

      controller.success();

      await Future.delayed(
        const Duration(milliseconds: 500),
      ); // Short delay for visual effect

      if (mounted) {
        // Generate a fake ID for demo: "260130..."
        final fakeId = DateTime.now().millisecondsSinceEpoch.toString();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TransferSuccessScreen(
              recipient: widget.recipient,
              amount: widget.amount,
              transactionId: fakeId,
            ),
          ),
        );
      }
    } catch (e) {
      controller.failure();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Error: ${e.toString().replaceAll('Exception: ', '')}",
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

      await Future.delayed(const Duration(seconds: 1));
      controller.reset();
    } finally {
      if (mounted) {
        setState(() => _isTransferring = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Review Transfer",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Review payment of",
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    widget.amount.toStringAsFixed(2),
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    "SGD",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(width: 4, color: Colors.red[700]),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Pay to",
                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.recipient.fullName,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${widget.recipient.phoneNumber} • ${widget.recipient.fullName.toUpperCase()}",
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                          if (widget.note != null &&
                              widget.note!.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              "Message",
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${widget.note}",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              const Center(
                child: Text(
                  "Please check that all details are correct before proceeding.",
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),

              ActionSlider.standard(
                sliderBehavior: SliderBehavior.stretch,
                width: double.infinity,
                backgroundColor: const Color(0xFF263238),
                toggleColor: Colors.white,
                icon: const Icon(
                  Icons.keyboard_double_arrow_right,
                  color: Colors.black,
                ),
                loadingIcon: const CircularProgressIndicator(
                  color: Colors.white,
                ),
                successIcon: const Icon(Icons.check, color: Colors.white),
                failureIcon: const Icon(Icons.close, color: Colors.white),
                action: (controller) async {
                  await _handleTransfer(controller);
                },
                child: const Text(
                  "Slide to pay",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
