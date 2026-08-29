import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';

enum GatewayState {
  pinEntry,
  processing,
  success,
  failure,
}

class QuickSplitPaymentGatewayScreen extends StatefulWidget {
  final String payeeName;
  final String payeeId;
  final String payerId;
  final double amount;

  const QuickSplitPaymentGatewayScreen({
    super.key,
    required this.payeeName,
    required this.payeeId,
    required this.payerId,
    required this.amount,
  });

  @override
  State<QuickSplitPaymentGatewayScreen> createState() =>
      _QuickSplitPaymentGatewayScreenState();
}

class _QuickSplitPaymentGatewayScreenState
    extends State<QuickSplitPaymentGatewayScreen> {
  GatewayState _currentState = GatewayState.pinEntry;
  String _enteredPin = '';
  String _selectedBank = 'State Bank of India •••• 4821';
  String _failureReason = 'Incorrect UPI PIN entered';
  late String _transactionRef;
  late DateTime _transactionTime;

  @override
  void initState() {
    super.initState();
    _transactionRef =
        'UPI/${DateTime.now().millisecondsSinceEpoch.toString().substring(3)}/QKS';
    _transactionTime = DateTime.now();
  }

  void _onKeypadTap(String value) {
    if (_currentState != GatewayState.pinEntry) return;

    HapticFeedback.lightImpact();
    setState(() {
      if (value == 'back') {
        if (_enteredPin.isNotEmpty) {
          _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
        }
      } else if (value == 'clear') {
        _enteredPin = '';
      } else {
        if (_enteredPin.length < 4) {
          _enteredPin += value;
        }
      }
    });

    if (_enteredPin.length == 4) {
      _startPaymentProcessing();
    }
  }

  void _startPaymentProcessing({bool forceFail = false}) async {
    setState(() {
      _currentState = GatewayState.processing;
    });

    // Simulate realistic bank API processing delay
    await Future.delayed(const Duration(milliseconds: 1800));

    if (!mounted) return;

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final validPin = provider.userPin;

    // Strict PIN Rule: Verify against user's configured PIN
    if (_enteredPin != validPin || forceFail) {
      HapticFeedback.heavyImpact();
      setState(() {
        _failureReason = forceFail
            ? 'Bank Server Timed Out. Transaction Declined.'
            : 'Incorrect UPI PIN "$_enteredPin". Valid PIN is $validPin.';
        _currentState = GatewayState.failure;
      });
    } else {
      // Payment Succeeded! Update ExpenseProvider state
      HapticFeedback.vibrate();
      provider.settleUpBetween(widget.payerId, widget.payeeId, widget.amount);

      setState(() {
        _currentState = GatewayState.success;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
        NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final dateFormat = DateFormat('d MMM yyyy, h:mm a');

    return Scaffold(
      backgroundColor: _currentState == GatewayState.success
          ? const Color(0xFF0D2818) // GPay / Paytm dark green theme on success
          : _currentState == GatewayState.failure
              ? const Color(0xFF2C0E11) // Dark red theme on failure
              : AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () {
            if (_currentState == GatewayState.success) {
              Navigator.pop(context, true);
            } else {
              Navigator.pop(context, false);
            }
          },
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary, width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security_rounded,
                      size: 14, color: AppColors.primaryLight),
                  SizedBox(width: 6),
                  Text(
                    'UPI SECURE GATEWAY',
                    style: TextStyle(
                      color: AppColors.primaryLight,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildStateView(currencyFormat, dateFormat),
        ),
      ),
    );
  }

  Widget _buildStateView(
      NumberFormat currencyFormat, DateFormat dateFormat) {
    switch (_currentState) {
      case GatewayState.pinEntry:
        return _buildPinEntryView(currencyFormat);

      case GatewayState.processing:
        return _buildProcessingView(currencyFormat);

      case GatewayState.success:
        return _buildSuccessView(currencyFormat, dateFormat);

      case GatewayState.failure:
        return _buildFailureView(currencyFormat);
    }
  }

  // STEP 1: PIN ENTRY VIEW
  Widget _buildPinEntryView(NumberFormat currencyFormat) {
    return Column(
      key: const ValueKey('pinEntryView'),
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Payee Avatar
                CircleAvatar(
                  radius: 36,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    widget.payeeName.isNotEmpty ? widget.payeeName[0] : 'P',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),

                const SizedBox(height: 12),

                Text(
                  'Paying ${widget.payeeName}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  '${widget.payeeName.toLowerCase().replaceAll(' ', '')}@quicksplit',
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 16),

                // Big Amount Text
                Text(
                  currencyFormat.format(widget.amount),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 20),

                // Bank Account Selector
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: AppColors.surfaceBorder, width: 1),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_rounded,
                          color: AppColors.secondary, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedBank,
                            dropdownColor: AppColors.cardElevated,
                            isExpanded: true,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            items: [
                              'State Bank of India •••• 4821',
                              'HDFC Bank •••• 9102',
                              'ICICI Bank •••• 3341',
                              'Axis Bank •••• 7712',
                            ].map((bank) {
                              return DropdownMenuItem<String>(
                                value: bank,
                                child: Text(bank),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() {
                                  _selectedBank = val;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                // MASKED UPI PIN DOTS
                Text(
                  'ENTER 4-DIGIT UPI PIN (DEMO PIN: ${Provider.of<ExpenseProvider>(context, listen: false).userPin})',
                  style: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),

                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _enteredPin.length;
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled
                            ? AppColors.primary
                            : Colors.transparent,
                        border: Border.all(
                          color: isFilled
                              ? AppColors.primary
                              : AppColors.surfaceBorder,
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () =>
                          _startPaymentProcessing(forceFail: true),
                      child: const Text(
                        'Simulate Bank Failure ⚠️',
                        style: TextStyle(
                          color: AppColors.negative,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // CUSTOM NUMERIC KEYPAD
        _buildNumericKeypad(),
      ],
    );
  }

  // STEP 2: PROCESSING VIEW
  Widget _buildProcessingView(NumberFormat currencyFormat) {
    return Center(
      key: const ValueKey('processingView'),
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary),
                    backgroundColor: AppColors.surfaceBorder.withValues(alpha: 0.3),
                  ),
                ),
                const Icon(Icons.lock_clock_rounded,
                    color: AppColors.primaryLight, size: 40),
              ],
            ),

            const SizedBox(height: 32),

            Text(
              'Processing ${currencyFormat.format(widget.amount)}',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'Connecting to bank server via QuickSplit Gateway...\nPlease do not press back or close the app.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3A: SUCCESS VIEW (GPay / Paytm Styled)
  Widget _buildSuccessView(
      NumberFormat currencyFormat, DateFormat dateFormat) {
    return Center(
      key: const ValueKey('successView'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big Animated Checkmark Circle
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.positive,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.positive,
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.black,
                size: 60,
              ),
            )
                .animate()
                .scale(
                  duration: 600.ms,
                  curve: Curves.elasticOut,
                )
                .then()
                .shimmer(duration: 800.ms),

            const SizedBox(height: 28),

            const Text(
              'Payment Successful!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -0.5,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 8),

            Text(
              'Paid ${currencyFormat.format(widget.amount)} to ${widget.payeeName}',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 32),

            // Authentic Receipt Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: AppColors.positive.withValues(alpha: 0.3), width: 1),
              ),
              child: Column(
                children: [
                  _buildReceiptRow('Transaction Ref', _transactionRef),
                  const Divider(color: AppColors.surfaceBorder),
                  _buildReceiptRow('Paid From', _selectedBank),
                  const Divider(color: AppColors.surfaceBorder),
                  _buildReceiptRow('Paid To', widget.payeeName),
                  const Divider(color: AppColors.surfaceBorder),
                  _buildReceiptRow('Timestamp', dateFormat.format(_transactionTime)),
                  const Divider(color: AppColors.surfaceBorder),
                  _buildReceiptRow('Status', 'COMPLETED / SETTLED',
                      statusColor: AppColors.positive),
                ],
              ),
            ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2, end: 0),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.positive,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                icon: const Icon(Icons.done_all_rounded, size: 20),
                label: const Text(
                  'DONE & RETURN TO APP',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // STEP 3B: FAILURE VIEW
  Widget _buildFailureView(NumberFormat currencyFormat) {
    return Center(
      key: const ValueKey('failureView'),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big Animated Error Cross Circle
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: AppColors.negative,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.negative,
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                Icons.priority_high_rounded,
                color: Colors.white,
                size: 58,
              ),
            )
                .animate()
                .scale(
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .shake(duration: 400.ms),

            const SizedBox(height: 28),

            const Text(
              'Payment Failed',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 8),

            Text(
              _failureReason,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 24),

            // Warning Notice Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.negativeBg.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppColors.negative.withValues(alpha: 0.4), width: 1),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.negative, size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'No money was debited from your bank account. Balances remain unchanged.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('CANCEL'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _enteredPin = '';
                        _currentState = GatewayState.pinEntry;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.negative,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text('TRY AGAIN'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: statusColor ?? Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // CUSTOM NUMERIC KEYPAD WIDGET
  Widget _buildNumericKeypad() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['1', '2', '3']
                .map((key) => _buildKeypadButton(key))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['4', '5', '6']
                .map((key) => _buildKeypadButton(key))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: ['7', '8', '9']
                .map((key) => _buildKeypadButton(key))
                .toList(),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildKeypadButton('clear', icon: Icons.clear_all_rounded),
              _buildKeypadButton('0'),
              _buildKeypadButton('back', icon: Icons.backspace_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeypadButton(String value, {IconData? icon}) {
    return InkWell(
      onTap: () => _onKeypadTap(value),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        width: 65,
        height: 50,
        alignment: Alignment.center,
        child: icon != null
            ? Icon(icon, color: AppColors.textSecondary, size: 22)
            : Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
