import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';

class RequestCashScreen extends StatefulWidget {
  final String? initialFriendId;
  final double? initialAmount;
  final String? initialNote;

  const RequestCashScreen({
    super.key,
    this.initialFriendId,
    this.initialAmount,
    this.initialNote,
  });

  @override
  State<RequestCashScreen> createState() => _RequestCashScreenState();
}

class _RequestCashScreenState extends State<RequestCashScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _amountController;
  late TextEditingController _noteController;

  late String _selectedFriendId;
  String _sendChannel = 'In-App Notification';
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ExpenseProvider>(context, listen: false);

    _selectedFriendId = widget.initialFriendId ??
        (provider.friends.isNotEmpty ? provider.friends.first.id : '');

    _amountController = TextEditingController(
      text: widget.initialAmount != null
          ? widget.initialAmount!.toStringAsFixed(2)
          : '',
    );
    _noteController = TextEditingController(
      text: widget.initialNote ?? '',
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _sendPaymentRequest() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final targetFriend = provider.getPersonById(_selectedFriendId);
    final double amount = double.tryParse(_amountController.text.trim()) ?? 0.0;

    setState(() {
      _isSending = true;
    });

    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isSending = false;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.send_rounded, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Sent \$${amount.toStringAsFixed(2)} cash request to ${targetFriend.name} via $_sendChannel!',
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primary,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final friends = provider.friends;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Request Money',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.cardAccentGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.handshake_rounded,
                              color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PEER PAYMENT REQUEST',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            Text(
                              'Remind Peer to Pay Debt',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

              const SizedBox(height: 24),

              // Select Peer Dropdown
              const Text(
                'REQUEST FROM',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedFriendId.isNotEmpty ? _selectedFriendId : null,
                    isExpanded: true,
                    dropdownColor: AppColors.cardElevated,
                    hint: const Text('Select a campus peer'),
                    items: friends.map((friend) {
                      final balance = provider.getPairwiseBalance(friend.id);
                      return DropdownMenuItem<String>(
                        value: friend.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: friend.color,
                              child: Text(
                                friend.initials,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                friend.name,
                                style: TextStyle(
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            if (balance < 0)
                              Text(
                                'Owes ${currencyFormat.format(balance.abs())}',
                                style: const TextStyle(
                                  color: AppColors.negative,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newFriendId) {
                      if (newFriendId != null) {
                        setState(() {
                          _selectedFriendId = newFriendId;
                          // Pre-fill amount owed if user owes
                          final bal = provider.getPairwiseBalance(newFriendId);
                          if (bal.abs() > 0 && _amountController.text.isEmpty) {
                            _amountController.text =
                                bal.abs().toStringAsFixed(2);
                          }
                        });
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Request Amount Field
              const Text(
                'REQUEST AMOUNT (\$)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Please enter a valid amount';
                  }
                  final num = double.tryParse(val.trim());
                  if (num == null || num <= 0) {
                    return 'Amount must be greater than \$0.00';
                  }
                  return null;
                },
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                decoration: const InputDecoration(
                  hintText: '0.00',
                  prefixText: '\$ ',
                  prefixStyle: TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Reason / Note Input
              const Text(
                'NOTE / REASON (OPTIONAL)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),

              TextFormField(
                controller: _noteController,
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color),
                decoration: const InputDecoration(
                  hintText: 'e.g., Chipotle dinner share, Campus Wi-Fi',
                  prefixIcon: Icon(Icons.edit_note_rounded,
                      color: AppColors.primaryLight),
                ),
              ),

              const SizedBox(height: 24),

              // Notification Channel Selector
              const Text(
                'SEND REMINDER VIA',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 10),

              Column(
                children: [
                  _buildChannelTile(
                    'In-App Notification & Push Alert',
                    'Instant alert within Campus QuickSplit',
                    Icons.notifications_active_rounded,
                    AppColors.primary,
                  ),
                  const SizedBox(height: 10),
                  _buildChannelTile(
                    'SMS & WhatsApp Payment Link',
                    'Sends deep-link with UPI payment details',
                    Icons.chat_bubble_outline_rounded,
                    AppColors.positive,
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Submit Action Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSending ? null : _sendPaymentRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  icon: _isSending
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send_rounded, size: 18),
                  label: Text(
                    _isSending ? 'SENDING REQUEST...' : 'SEND MONEY REQUEST NOW',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChannelTile(
      String title, String subtitle, IconData icon, Color iconColor) {
    final isSelected = _sendChannel == title;

    return GestureDetector(
      onTap: () {
        setState(() {
          _sendChannel = title;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.surfaceBorder,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.primary, size: 18),
          ],
        ),
      ),
    );
  }
}
