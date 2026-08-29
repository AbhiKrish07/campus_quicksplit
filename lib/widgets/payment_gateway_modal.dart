import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../logic/payment_gateway_service.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';

class PaymentGatewayModal extends StatefulWidget {
  final String payeeName;
  final String payeeId;
  final String payerId;
  final double defaultAmount;

  const PaymentGatewayModal({
    super.key,
    required this.payeeName,
    required this.payeeId,
    required this.payerId,
    required this.defaultAmount,
  });

  @override
  State<PaymentGatewayModal> createState() => _PaymentGatewayModalState();
}

class _PaymentGatewayModalState extends State<PaymentGatewayModal> {
  late TextEditingController _amountController;
  PaymentMethod _selectedMethod = PaymentMethod.upi;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController(
      text: widget.defaultAmount.abs().toStringAsFixed(2),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _processPayment() async {
    final double? amount = double.tryParse(_amountController.text.trim());
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid payment amount > \$0.00'),
          backgroundColor: AppColors.negative,
        ),
      );
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    if (_selectedMethod == PaymentMethod.upi) {
      await PaymentGatewayService.launchUpiPayment(
        payeeName: widget.payeeName,
        upiId: '${widget.payeeName.toLowerCase().replaceAll(' ', '')}@upi',
        amount: amount,
        note: 'Campus QuickSplit Settlement',
      );
    } else if (_selectedMethod == PaymentMethod.stripeCard) {
      await PaymentGatewayService.launchStripeCheckout(
        amount: amount,
        description: 'Campus QuickSplit Settlement to ${widget.payeeName}',
      );
    }

    // Simulate gateway response verification
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    provider.settleUpBetween(widget.payerId, widget.payeeId, amount);

    setState(() {
      _isProcessing = false;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Successfully processed \$${amount.toStringAsFixed(2)} payment via ${_selectedMethod == PaymentMethod.upi ? "UPI Gateway" : "Stripe"}!',
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.positive,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surfaceBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_outline_rounded,
                    color: AppColors.primary, size: 22),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAYMENT GATEWAY CHECKOUT',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  Text(
                    'Pay ${widget.payeeName}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Amount TextField
          TextFormField(
            controller: _amountController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
            decoration: const InputDecoration(
              labelText: 'Settlement Amount (\$)',
              prefixText: '\$ ',
              prefixStyle: TextStyle(
                color: AppColors.primary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Select Gateway Method
          const Text(
            'SELECT PAYMENT GATEWAY',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),

          // Method 1: UPI Gateway (Google Pay / PhonePe / Paytm)
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedMethod = PaymentMethod.upi;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedMethod == PaymentMethod.upi
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedMethod == PaymentMethod.upi
                      ? AppColors.primary
                      : AppColors.surfaceBorder,
                  width: 1.5,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.flash_on_rounded,
                      color: Colors.amber, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UPI Instant Pay (GPay / PhonePe / Paytm)',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Zero fee direct bank settlement via UPI deep-link',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ),

          // Method 2: Stripe Credit / Debit Card Gateway
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedMethod = PaymentMethod.stripeCard;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedMethod == PaymentMethod.stripeCard
                    ? AppColors.primary.withValues(alpha: 0.15)
                    : Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedMethod == PaymentMethod.stripeCard
                      ? AppColors.primary
                      : AppColors.surfaceBorder,
                  width: 1.5,
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.credit_card_rounded,
                      color: AppColors.secondary, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stripe Secure Card Gateway',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Visa, Mastercard, AMEX tokenized checkout',
                          style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 14, color: AppColors.textMuted),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Process Action Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isProcessing ? null : _processPayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.positive,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isProcessing
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'CONNECTING TO GATEWAY...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'PROCEED TO PAY NOW (${currencyFormat.format(double.tryParse(_amountController.text) ?? widget.defaultAmount.abs())})',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
