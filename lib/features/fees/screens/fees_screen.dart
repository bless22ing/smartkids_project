import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../shared/models/app_constants.dart';
import '../models/fee_model.dart';
import '../services/fee_service.dart';
import '../../auth/services/auth_service.dart';

class FeesScreen extends ConsumerStatefulWidget {
  const FeesScreen({super.key});

  @override
  ConsumerState<FeesScreen> createState() => _FeesScreenState();
}

class _FeesScreenState extends ConsumerState<FeesScreen> {
  // Default to current month and year
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch fees for selected month
    final feesAsync = ref.watch(
      monthlyFeesProvider((
      month: _selectedMonth,
      year: _selectedYear,
      )),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees'),
      ),
      body: Column(
        children: [
          // Month selector
          Padding(
            padding: const EdgeInsets.all(16),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chevron_left),
                      onPressed: () {
                        setState(() {
                          if (_selectedMonth == 1) {
                            _selectedMonth = 12;
                            _selectedYear--;
                          } else {
                            _selectedMonth--;
                          }
                        });
                      },
                    ),
                    Text(
                      '${_monthName(_selectedMonth)} $_selectedYear',
                      style: theme.textTheme.titleMedium,
                    ),
                    IconButton(
                      icon: const Icon(Icons.chevron_right),
                      onPressed: () {
                        setState(() {
                          if (_selectedMonth == 12) {
                            _selectedMonth = 1;
                            _selectedYear++;
                          } else {
                            _selectedMonth++;
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Summary row
          feesAsync.when(
            data: (fees) => _buildSummary(fees, theme),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          const SizedBox(height: 8),

          // Fee list
          Expanded(
            child: feesAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),

              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),

              data: (fees) {
                if (fees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.payments_outlined,
                          size: 64,
                          color: theme.disabledColor,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No fee records for this month',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Generate fees to create records for all students',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.disabledColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () =>
                              _showGenerateFeesDialog(context),
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate Fees'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: fees.length,
                  separatorBuilder: (_, __) =>
                  const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final fee = fees[index];
                    return _FeeTile(
                      fee: fee,
                      onRecordPayment: () =>
                          _showRecordPaymentDialog(context, fee),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Summary cards — total due, collected, outstanding
  Widget _buildSummary(List<FeeModel> fees, ThemeData theme) {
    final totalDue =
    fees.fold(0.0, (sum, f) => sum + f.amountDue);
    final totalPaid =
    fees.fold(0.0, (sum, f) => sum + f.amountPaid);
    final totalBalance =
    fees.fold(0.0, (sum, f) => sum + f.balance);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Total Due',
            value: '\$${totalDue.toStringAsFixed(0)}',
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Collected',
            value: '\$${totalPaid.toStringAsFixed(0)}',
            color: Colors.green,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Outstanding',
            value: '\$${totalBalance.toStringAsFixed(0)}',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  // Dialog to generate fees for all students
  Future<void> _showGenerateFeesDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Generate Monthly Fees'),
        content: Text(
          'This will create fee records for all active students '
              'for ${_monthName(_selectedMonth)} $_selectedYear. '
              'Students without a fee record will be added.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading indicator
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text('Generating fees...'),
                    ],
                  ),
                  duration: Duration(seconds: 10),
                ),

              );

              try {
                // Fetch all active students from Firestore
                final studentsSnap = await FirebaseFirestore.instance
                    .collection('students')
                    .where('active', isEqualTo: true)
                    .get();

                // Convert to the simple map format FeeService expects
                final students = studentsSnap.docs.map((doc) {
                  final data = doc.data();
                  return {
                    'id': doc.id,
                    'name': data['name'] ?? '',
                    'classId': data['classId'] ?? 'ecda',
                  };
                }).toList();

                // Generate fee records
                await ref.read(feeServiceProvider).generateMonthlyFees(
                  students: students,
                  month: _selectedMonth,
                  year: _selectedYear,
                );

                if (context.mounted) {
                  // Dismiss loading snackbar
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Fee records generated for ${students.length} students',
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to generate fees: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }

  // Dialog to record a payment
  Future<void> _showRecordPaymentDialog(
      BuildContext context, FeeModel fee) async {
    final amountCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Record Payment — ${fee.studentName}'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Balance info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Balance due:',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600)),
                    Text(
                      '\$${fee.balance.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: fee.balance > 0
                            ? Colors.red
                            : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Amount field
              TextFormField(
                controller: amountCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                    decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Amount (USD)',
                  prefixText: '\$ ',
                  border: OutlineInputBorder(),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) {
                    return 'Enter an amount';
                  }
                  final amount = double.tryParse(v);
                  if (amount == null || amount <= 0) {
                    return 'Enter a valid amount';
                  }
                  if (amount > fee.balance) {
                    return 'Amount exceeds balance due';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 12),

              // Note field
              TextFormField(
                controller: noteCtrl,
                decoration: const InputDecoration(
                  labelText: 'Note (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;

              final userAsync = ref.read(currentUserProvider);
              final uid = userAsync.value?.uid ?? '';

              try {
                await ref.read(feeServiceProvider).recordPayment(
                  feeId: fee.id,
                  amount: double.parse(amountCtrl.text),
                  recordedBy: uid,
                  note: noteCtrl.text.trim(),
                );

                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Payment recorded successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            child: const Text('Record Payment'),
          ),
        ],
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April',
      'May', 'June', 'July', 'August',
      'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

// ================= FEE TILE =================

class _FeeTile extends StatelessWidget {
  final FeeModel fee;
  final VoidCallback onRecordPayment;

  const _FeeTile({
    required this.fee,
    required this.onRecordPayment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.dividerColor),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor:
          fee.status.color.withValues(alpha: 0.15),
          child: Icon(
            fee.status == FeeStatus.paid
                ? Icons.check_circle_outline
                : fee.status == FeeStatus.partial
                ? Icons.timelapse
                : Icons.cancel_outlined,
            color: fee.status.color,
          ),
        ),
        title: Text(
          fee.studentName,
          style: theme.textTheme.titleSmall,
        ),
        subtitle: Text(
          'Due: \$${fee.amountDue.toStringAsFixed(0)} • '
              'Paid: \$${fee.amountPaid.toStringAsFixed(0)} • '
              'Balance: \$${fee.balance.toStringAsFixed(0)}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Status badge
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: fee.status.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                fee.status.displayName,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: fee.status.color,
                ),
              ),
            ),
            // Record payment button — only if not fully paid
            if (fee.status != FeeStatus.paid) ...[
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                tooltip: 'Record Payment',
                onPressed: onRecordPayment,
                color: theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ================= SUMMARY CARD =================

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.disabledColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}