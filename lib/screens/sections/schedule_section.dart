import 'package:flutter/material.dart';
import '../../models/debt.dart';
import '../../providers/debt_provider.dart';
import '../../widgets/transaction_item.dart';

class ScheduleSection extends StatelessWidget {
  final DebtProvider provider;
  final Function(BuildContext, {Debt? debt, int? index}) onEdit;
  final Function(BuildContext, Debt debt) onShowDetail;

  const ScheduleSection({
    super.key,
    required this.provider,
    required this.onEdit,
    required this.onShowDetail,
  });

  @override
  Widget build(BuildContext context) {
    final upcoming = provider.debts
        .asMap()
        .entries
        .where((e) => !e.value.isPaid && e.value.dueDate != null)
        .toList();
    
    // Sort by due date
    upcoming.sort((a, b) => a.value.dueDate!.compareTo(b.value.dueDate!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(24, 32, 24, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Jadwal Bayar',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              Text(
                'Jangan lupa tunaikan amanah tepat waktu',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
        Expanded(
          child: upcoming.isEmpty 
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_month_outlined, size: 80, color: Colors.grey[200]),
                  const SizedBox(height: 16),
                  const Text('Tidak ada jadwal terdekat', style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              itemCount: upcoming.length,
              itemBuilder: (context, index) {
                final entry = upcoming[index];
                final debt = entry.value;
                final diff = debt.dueDate!.difference(DateTime.now()).inDays;
                
                return TransactionItem(
                  debt: debt,
                  index: entry.key,
                  provider: provider,
                  isScheduleView: true,
                  daysDiff: diff,
                  onEdit: onEdit,
                  onShowDetail: onShowDetail,
                );
              },
            ),
        ),
      ],
    );
  }
}
