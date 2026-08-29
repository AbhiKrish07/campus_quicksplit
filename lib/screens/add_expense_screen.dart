import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../models/expense_category.dart';
import '../models/split_mode.dart';
import '../providers/expense_provider.dart';
import '../theme/app_colors.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();

  CategoryType _selectedCategory = CategoryType.coffee;
  late String _selectedPaidById;
  final Set<String> _selectedParticipantIds = {};
  SplitMode _splitMode = SplitMode.equal;

  // Granular allocation controllers: personId -> TextEditingController
  final Map<String, TextEditingController> _customShareControllers = {};

  // Form Validation State
  String? _descriptionError;
  String? _amountError;
  String? _participantsError;
  String? _splitAllocationError;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    _selectedPaidById = provider.currentUser.id;
    _selectedParticipantIds.add(provider.currentUser.id);
    if (provider.friends.isNotEmpty) {
      _selectedParticipantIds.add(provider.friends.first.id);
    }

    _descriptionController.addListener(_validateForm);
    _amountController.addListener(_validateForm);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _validateForm();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    for (var c in _customShareControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _validateForm() {
    setState(() {
      // 1. Description Validation
      final desc = _descriptionController.text.trim();
      _descriptionError = desc.isEmpty ? 'Description is required' : null;

      // 2. Amount Validation
      final amountText = _amountController.text.trim();
      double parsedAmount = 0.0;
      if (amountText.isEmpty) {
        _amountError = 'Amount is required';
      } else {
        final val = double.tryParse(amountText);
        if (val == null) {
          _amountError = 'Must be a valid number';
        } else if (val <= 0) {
          _amountError = 'Amount must be greater than \$0.00';
        } else {
          parsedAmount = val;
          _amountError = null;
        }
      }

      // 3. Participants Validation
      if (!_selectedParticipantIds.contains(_selectedPaidById)) {
        _selectedParticipantIds.add(_selectedPaidById);
      }
      _participantsError = _selectedParticipantIds.length < 2
          ? 'Select at least 2 participants (including payer)'
          : null;

      // 4. Granular Split Allocation Validation
      _splitAllocationError = null;
      if (_splitMode == SplitMode.exactAmount && parsedAmount > 0) {
        double sumExact = 0.0;
        for (var pId in _selectedParticipantIds) {
          final text = _customShareControllers[pId]?.text ?? '0';
          sumExact += double.tryParse(text) ?? 0.0;
        }
        final diff = (parsedAmount - sumExact).abs();
        if (diff > 0.01) {
          _splitAllocationError =
              'Sum of exact amounts (\$${sumExact.toStringAsFixed(2)}) must equal total (\$${parsedAmount.toStringAsFixed(2)})';
        }
      } else if (_splitMode == SplitMode.percentage) {
        double sumPct = 0.0;
        for (var pId in _selectedParticipantIds) {
          final text = _customShareControllers[pId]?.text ?? '0';
          sumPct += double.tryParse(text) ?? 0.0;
        }
        if ((100.0 - sumPct).abs() > 0.01) {
          _splitAllocationError =
              'Total percentage (${sumPct.toStringAsFixed(1)}%) must equal exactly 100%';
        }
      }

      // Form validity
      _isFormValid = _descriptionError == null &&
          _amountError == null &&
          _participantsError == null &&
          _splitAllocationError == null;
    });
  }

  double get _currentParsedAmount {
    final text = _amountController.text.trim();
    return double.tryParse(text) ?? 0.0;
  }

  void _submitExpense() {
    _validateForm();
    if (!_isFormValid) return;

    final provider = Provider.of<ExpenseProvider>(context, listen: false);
    final Map<String, double> customSharesMap = {};

    if (_splitMode != SplitMode.equal) {
      for (var pId in _selectedParticipantIds) {
        final text = _customShareControllers[pId]?.text ?? '0';
        customSharesMap[pId] = double.tryParse(text) ?? 0.0;
      }
    }

    final newExpense = Expense(
      id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
      description: _descriptionController.text.trim(),
      amount: _currentParsedAmount,
      category: _selectedCategory,
      paidById: _selectedPaidById,
      participantIds: _selectedParticipantIds.toList(),
      splitMode: _splitMode,
      customShares: customSharesMap,
      timestamp: DateTime.now(),
    );

    provider.addExpense(newExpense);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Added "${newExpense.description}" (\$${newExpense.amount.toStringAsFixed(2)})',
        ),
        backgroundColor: AppColors.positive,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<ExpenseProvider>(context);
    final allPeople = provider.allPeople;
    final currencyFormat = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add New Expense',
          style: TextStyle(
            color: AppColors.textPrimary,
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
              // Live Split Share Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: AppColors.cardAccentGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _splitMode.displayName.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _splitMode == SplitMode.equal
                              ? '${currencyFormat.format(_selectedParticipantIds.isNotEmpty ? _currentParsedAmount / _selectedParticipantIds.length : 0)} / person'
                              : currencyFormat.format(_currentParsedAmount),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${_selectedParticipantIds.length} People',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Description Input
              const Text(
                'DESCRIPTION',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _descriptionController,
                style: const TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: 'e.g., Chipotle Dinner, Wi-Fi bill',
                  prefixIcon: const Icon(Icons.edit_note_rounded,
                      color: AppColors.primaryLight),
                  errorText: _descriptionError,
                ),
              ),

              const SizedBox(height: 20),

              // Amount Input
              const Text(
                'AMOUNT (\$)',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
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
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                decoration: InputDecoration(
                  hintText: '0.00',
                  prefixText: '\$ ',
                  prefixStyle: const TextStyle(
                    color: AppColors.primaryLight,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  errorText: _amountError,
                ),
              ),

              const SizedBox(height: 24),

              // Granular Allocation Mode Selector (Phase 2)
              const Text(
                'SPLIT DISTRIBUTION MODE',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  for (final mode in SplitMode.values)
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _splitMode = mode;
                          });
                          _validateForm();
                        },
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: _splitMode == mode
                                ? AppColors.primary
                                : AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: _splitMode == mode
                                  ? AppColors.primary
                                  : AppColors.surfaceBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                mode.icon,
                                size: 20,
                                color: _splitMode == mode
                                    ? Colors.white
                                    : AppColors.textSecondary,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                mode.name.toUpperCase(),
                                style: TextStyle(
                                  color: _splitMode == mode
                                      ? Colors.white
                                      : AppColors.textPrimary,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 24),

              // Category Selector
              const Text(
                'CATEGORY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 48,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: ExpenseCategory.categories.length,
                  itemBuilder: (context, index) {
                    final cat = ExpenseCategory.categories[index];
                    final isSelected = _selectedCategory == cat.type;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedCategory = cat.type;
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? cat.color
                              : AppColors.cardBackground,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isSelected
                                ? cat.color
                                : AppColors.surfaceBorder,
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              cat.icon,
                              size: 18,
                              color: isSelected ? Colors.white : cat.color,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              cat.name,
                              style: TextStyle(
                                color: isSelected
                                    ? Colors.white
                                    : AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Paid By Selector
              const Text(
                'PAID BY',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.cardBackground,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceBorder, width: 1),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedPaidById,
                    isExpanded: true,
                    dropdownColor: AppColors.cardElevated,
                    items: allPeople.map((person) {
                      return DropdownMenuItem<String>(
                        value: person.id,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: person.color,
                              child: Text(
                                person.initials,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              person.id == provider.currentUser.id
                                  ? '${person.name} (You)'
                                  : person.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (newPayerId) {
                      if (newPayerId != null) {
                        setState(() {
                          _selectedPaidById = newPayerId;
                        });
                        _validateForm();
                      }
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Participants Selection & Custom Share Inputs (Phase 2)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'PARTICIPANTS & ALLOCATION',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        if (_selectedParticipantIds.length == allPeople.length) {
                          _selectedParticipantIds.clear();
                          _selectedParticipantIds.add(_selectedPaidById);
                        } else {
                          _selectedParticipantIds
                              .addAll(allPeople.map((p) => p.id));
                        }
                      });
                      _validateForm();
                    },
                    child: Text(
                      _selectedParticipantIds.length == allPeople.length
                          ? 'Deselect All'
                          : 'Select All',
                      style: const TextStyle(
                          color: AppColors.primaryLight, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allPeople.map((person) {
                  final isSelected =
                      _selectedParticipantIds.contains(person.id);
                  final isPayer = person.id == _selectedPaidById;

                  return FilterChip(
                    selected: isSelected,
                    showCheckmark: true,
                    checkmarkColor: Colors.white,
                    avatar: CircleAvatar(
                      backgroundColor: person.color,
                      child: Text(
                        person.initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    label: Text(
                      person.id == provider.currentUser.id
                          ? '${person.name} (You)'
                          : person.name,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    backgroundColor: AppColors.cardBackground,
                    selectedColor: AppColors.primary,
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedParticipantIds.add(person.id);
                        } else {
                          if (!isPayer) {
                            _selectedParticipantIds.remove(person.id);
                          }
                        }
                      });
                      _validateForm();
                    },
                  );
                }).toList(),
              ),

              if (_splitMode != SplitMode.equal) ...[
                const SizedBox(height: 16),
                for (final pId in _selectedParticipantIds) ...[
                  Builder(builder: (context) {
                    final person = provider.getPersonById(pId);
                    _customShareControllers.putIfAbsent(
                        pId, () => TextEditingController());
                    final controller = _customShareControllers[pId]!;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 14,
                            backgroundColor: person.color,
                            child: Text(
                              person.initials,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              person.name,
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: 120,
                            child: TextFormField(
                              controller: controller,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              onChanged: (_) => _validateForm(),
                              style: const TextStyle(
                                  color: AppColors.textPrimary,
                                  fontWeight: FontWeight.bold),
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                hintText: _splitMode == SplitMode.exactAmount
                                    ? '0.00'
                                    : '0%',
                                prefixText: _splitMode == SplitMode.exactAmount
                                    ? '\$ '
                                    : null,
                                suffixText: _splitMode == SplitMode.percentage
                                    ? '%'
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ],

              if (_splitAllocationError != null) ...[
                const SizedBox(height: 10),
                Text(
                  _splitAllocationError!,
                  style: const TextStyle(
                    color: AppColors.negative,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              if (_participantsError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _participantsError!,
                  style: const TextStyle(
                    color: AppColors.negative,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isFormValid ? _submitExpense : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isFormValid ? AppColors.primary : AppColors.cardElevated,
                    foregroundColor:
                        _isFormValid ? Colors.white : AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text(
                    'ADD EXPENSE NOW',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
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
}
