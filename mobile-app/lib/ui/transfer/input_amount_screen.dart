import 'package:bombastic_banking/domain/user.dart';
import 'package:bombastic_banking/ui/transfer/confirmation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputAmountScreen extends StatefulWidget {
  final User recipient;

  const InputAmountScreen({super.key, required this.recipient});

  @override
  State<InputAmountScreen> createState() => _InputAmountScreenState();
}

class _InputAmountScreenState extends State<InputAmountScreen> {
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  final double _dailyLimit = 1000.00;

  // 1. Track width and remaining characters
  double _inputWidth = 120.0;
  int _remainingChars = 27; // Starts at 27

  @override
  void initState() {
    super.initState();
    _updateWidthAndCounter("");
  }

  void _updateWidthAndCounter(String text) {
    final textToMeasure = text.isEmpty ? "Add a message" : text;

    final textSpan = TextSpan(
      text: textToMeasure,
      style: const TextStyle(fontSize: 12),
    );

    final tp = TextPainter(text: textSpan, textDirection: TextDirection.ltr);

    tp.layout();

    setState(() {
      _remainingChars = 27 - text.length;

      // Width = Text + Spacing + Counter Width + Padding
      _inputWidth = tp.width + 8 + 20 + 32;
    });
  }

  void _onNext() {
    final amountText = _amountController.text;
    if (amountText.isEmpty) return;

    final double? amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid amount")),
      );
      return;
    }

    if (amount > _dailyLimit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Amount exceeds daily limit")),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationScreen(
          recipient: widget.recipient,
          amount: amount,
          note: _noteController.text,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pay to",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 8),

            Text(
              widget.recipient.fullName,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              "${widget.recipient.phoneNumber}",
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: const InputDecoration(
                      hintText: "0.00",
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black26),
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                  ),
                ),
                const Text(
                  "SGD",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),
            Text(
              "Daily limit remaining ${_dailyLimit.toStringAsFixed(2)} SGD",
              style: TextStyle(
                color: Colors.blue[700],
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 30),

            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _inputWidth,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF3f545f),
                borderRadius: BorderRadius.circular(40),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(
                    child: TextField(
                      controller: _noteController,
                      maxLength: 27,
                      textAlign: TextAlign.left,
                      textInputAction: TextInputAction.done,
                      onChanged: (val) => _updateWidthAndCounter(val),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                      decoration: const InputDecoration(
                        isDense: true,
                        contentPadding: EdgeInsets.zero,
                        hintText: "Add a message",
                        hintStyle: TextStyle(color: Colors.white70),
                        border: InputBorder.none,
                        counterText: "", // Hide default counter
                      ),
                    ),
                  ),

                  const SizedBox(width: 3),

                  Text(
                    "$_remainingChars",
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),

            const Spacer(),

            SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3f545f),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    "Next",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
