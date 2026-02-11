import 'package:flutter/material.dart';
import '../../models/debt.dart';
import '../../providers/debt_provider.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/transaction_item.dart';

class HistorySection extends StatelessWidget {
  final DebtProvider provider;
  final Function(BuildContext, {Debt? debt, int? index}) onEdit;
  final Function(BuildContext, Debt debt) onShowDetail;

  const HistorySection({
    super.key,
    required this.provider,
    required this.onEdit,
    required this.onShowDetail,
  });

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 32, 24, 8),
            child: Text(
              'Riwayat Hutang',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
            ),
          ),
          const TabBar(
            labelColor: Color(0xFF6366F1),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF6366F1),
            indicatorSize: TabBarIndicatorSize.label,
            tabs: [
              Tab(text: 'Belum Lunas'),
              Tab(text: 'Sudah Lunas'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildFilteredList(provider, isPaid: false),
                _buildFilteredList(provider, isPaid: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilteredList(DebtProvider provider, {required bool isPaid}) {
    final filtered = provider.debts
        .asMap()
        .entries
        .where((e) => e.value.isPaid == isPaid)
        .toList()
        .reversed
        .toList();

    if (filtered.isEmpty) {
      return const EmptyState(
        icon: Icons.inbox_outlined,
        message: 'Tidak ada data',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return TransactionItem(
          debt: entry.value,
          index: entry.key,
          provider: provider,
          onEdit: onEdit,
          onShowDetail: onShowDetail,
        );
      },
    );
  }
}
