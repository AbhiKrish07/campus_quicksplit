import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/person.dart';
import '../models/group.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showEditProfileDialog(BuildContext context, ExpenseProvider provider) {
    final nameController = TextEditingController(text: provider.currentUser.name);
    final emailController = TextEditingController(text: provider.userEmail);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit Your Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Campus Email',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                provider.updateUserProfile(
                  nameController.text.trim(),
                  emailController.text.trim(),
                );
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile updated successfully!'),
                    backgroundColor: AppColors.positive,
                  ),
                );
              }
            },
            child: const Text('SAVE PROFILE'),
          ),
        ],
      ),
    );
  }

  void _showEditFriendAliasDialog(
      BuildContext context, ExpenseProvider provider, Person friend) {
    final nameController = TextEditingController(text: friend.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Edit Alias for ${friend.name}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Change how this friend\'s name appears across your app (contact name alias style).',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Display Name / Alias',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                provider.updateFriendName(friend.id, nameController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Updated display name to "${nameController.text.trim()}"!'),
                    backgroundColor: AppColors.positive,
                  ),
                );
              }
            },
            child: const Text('SAVE ALIAS'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupNameDialog(
      BuildContext context, ExpenseProvider provider, Group group) {
    final nameController = TextEditingController(text: group.name);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Rename Group "${group.name}"'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'New Group Name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                provider.updateGroupName(group.id, nameController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content:
                        Text('Renamed group to "${nameController.text.trim()}"!'),
                    backgroundColor: AppColors.positive,
                  ),
                );
              }
            },
            child: const Text('RENAME GROUP'),
          ),
        ],
      ),
    );
  }

  void _showEditPinDialog(BuildContext context, ExpenseProvider provider) {
    final pinController = TextEditingController(text: provider.userPin);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Change Security PIN'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Set your custom 4-digit security PIN required for payment checkout authorization.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 8.0,
              ),
              decoration: const InputDecoration(
                labelText: '4-Digit PIN',
                hintText: '1234',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              if (pinController.text.length == 4) {
                provider.setUserPin(pinController.text);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Security PIN successfully updated to ${pinController.text}!'),
                    backgroundColor: AppColors.positive,
                  ),
                );
              }
            },
            child: const Text('SAVE PIN'),
          ),
        ],
      ),
    );
  }

  void _showAddBankDialog(BuildContext context, ExpenseProvider provider) {
    final bankController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Link New Bank Account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter your Bank Name and Last 4 Digits of your Account or Debit Card.',
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: bankController,
              decoration: const InputDecoration(
                labelText: 'e.g. HDFC Bank •••• 9988',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            onPressed: () {
              if (bankController.text.trim().isNotEmpty) {
                provider.addBankAccount(bankController.text.trim());
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Successfully linked account "${bankController.text.trim()}"!'),
                    backgroundColor: AppColors.positive,
                  ),
                );
              }
            },
            child: const Text('LINK ACCOUNT'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<ExpenseProvider>(context);
    final user = provider.currentUser;

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
          'Profile & Settings',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // USER PROFILE CARD
            Container(
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
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: user.color,
                    child: Text(
                      user.initials,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              user.name,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_rounded,
                                  color: Colors.white70, size: 18),
                              tooltip: 'Edit Profile',
                              onPressed: () => _showEditProfileDialog(context, provider),
                            ),
                          ],
                        ),
                        Text(
                          '${provider.userEmail} • ${provider.authMethod}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'PRO ACCOUNT ACTIVE',
                                style: TextStyle(
                                  color: AppColors.positive,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                await provider.logout();
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.redAccent),
                                ),
                                child: const Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.95, 0.95), end: const Offset(1, 1)),

            const SizedBox(height: 24),

            // CONTACT NICKNAMES / FRIEND ALIAS EDITING SECTION
            const Text(
              'FRIEND CONTACT ALIASES',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              elevation: 0,
              color: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                children: provider.friends.map((friend) {
                  return ListTile(
                    leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: friend.color,
                      child: Text(
                        friend.initials,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      friend.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.primaryLight),
                      tooltip: 'Edit Friend Display Name',
                      onPressed: () =>
                          _showEditFriendAliasDialog(context, provider, friend),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // RENAME CAMPUS GROUPS SECTION
            const Text(
              'MANAGE CAMPUS GROUP NAMES',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              elevation: 0,
              color: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                children: provider.groups.map((group) {
                  return ListTile(
                    leading: Text(group.icon ?? '📁',
                        style: const TextStyle(fontSize: 20)),
                    title: Text(
                      group.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    subtitle: Text('${group.participantIds.length} members',
                        style: const TextStyle(fontSize: 11)),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit_outlined,
                          size: 18, color: AppColors.primaryLight),
                      tooltip: 'Rename Group',
                      onPressed: () =>
                          _showEditGroupNameDialog(context, provider, group),
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 24),

            // SECURITY & BANKING SECTION
            const Text(
              'SECURITY & LINKED BANKING',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              elevation: 0,
              color: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.lock_person_rounded,
                        color: AppColors.primary),
                    title: const Text('Security UPI PIN'),
                    subtitle: Text('Current PIN: •••• (${provider.userPin})'),
                    trailing: OutlinedButton(
                      onPressed: () => _showEditPinDialog(context, provider),
                      child: const Text('Change PIN'),
                    ),
                  ),
                  const Divider(height: 1, color: AppColors.surfaceBorder),
                  ListTile(
                    leading: const Icon(Icons.account_balance_rounded,
                        color: AppColors.positive),
                    title: const Text('Linked Bank Accounts'),
                    subtitle: Text('${provider.bankAccounts.length} Accounts'),
                    trailing: ElevatedButton.icon(
                      onPressed: () => _showAddBankDialog(context, provider),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.positive,
                        foregroundColor: Colors.black,
                      ),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Link Bank'),
                    ),
                  ),
                  ...provider.bankAccounts.map(
                    (acc) => Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.credit_card_rounded,
                              size: 18, color: AppColors.textMuted),
                          const SizedBox(width: 12),
                          Text(acc,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w600)),
                          const Spacer(),
                          const Icon(Icons.check_circle_rounded,
                              size: 16, color: AppColors.positive),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // PREFERENCES SECTION
            const Text(
              'PREFERENCES & SYSTEM',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              elevation: 0,
              color: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    secondary: Icon(
                      themeProvider.isDarkMode
                          ? Icons.dark_mode_rounded
                          : Icons.light_mode_rounded,
                      color: AppColors.primary,
                    ),
                    title: const Text('Dark Theme Mode'),
                    subtitle: Text(themeProvider.isDarkMode
                        ? 'Electric Royal Blue Dark'
                        : 'Clean Fintech Light'),
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // DATA MANAGEMENT
            const Text(
              'DATA MANAGEMENT',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 10),

            Card(
              elevation: 0,
              color: Theme.of(context).cardTheme.color,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: const BorderSide(color: AppColors.surfaceBorder, width: 1),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_rounded,
                        color: AppColors.primary),
                    title: const Text('Export Statement / CSV Report'),
                    subtitle: const Text('Download all expense logs in CSV format'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Exported quicksplit_statement.csv!'),
                          backgroundColor: AppColors.positive,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1, color: AppColors.surfaceBorder),
                  ListTile(
                    leading: const Icon(Icons.restore_rounded,
                        color: AppColors.negative),
                    title: const Text('Reset Initial Mock Ledger'),
                    subtitle: const Text('Restores default sample bills'),
                    onTap: () {
                      provider.resetInitialData();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Ledger reset to initial state!'),
                          backgroundColor: AppColors.negative,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
            Center(
              child: Column(
                children: [
                  const Text(
                    'Campus QuickSplit v2.4.0 • Production Build',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Designed for GDG Campus Expense Engineering',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
