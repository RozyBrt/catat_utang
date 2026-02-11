import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';

class TransactionItem extends StatelessWidget {
  final Debt debt;
  final int index;
  final DebtProvider provider;
  final bool isScheduleView;
  final int? daysDiff;
  final Function(BuildContext, {Debt? debt, int? index}) onEdit;
  final Function(BuildContext, Debt debt) onShowDetail;

  const TransactionItem({
    super.key,
    required this.debt,
    required this.index,
    required this.provider,
    this.isScheduleView = false,
    this.daysDiff,
    required this.onEdit,
    required this.onShowDetail,
  });

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => onShowDetail(context, debt),
        onLongPress: () => onEdit(context, debt: debt, index: index),
        child: Row(
          children: [
            InkWell(
              onTap: () => provider.togglePaid(index),
              borderRadius: BorderRadius.circular(100),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: debt.isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  debt.isPaid ? Icons.check_circle_outlined : Icons.timer_outlined,
                  color: debt.isPaid ? const Color(0xFF166534) : const Color(0xFF991B1B),
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87, fontSize: 14),
                      children: [
                        TextSpan(
                          text: '${debt.isPaid ? "Sudah Bayar" : "Pinjam Ke"}: ',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '${debt.name} (${_formatRupiah(debt.amount)})',
                        ),
                      ],
                    ),
                  ),
                  if (debt.isPaid && debt.paidDate != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, size: 12, color: Colors.green),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Lunas pada: ${DateFormat('dd MMM yyyy').format(debt.paidDate!)}",
                              style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!debt.isPaid && debt.dueDate != null)
                    Builder(builder: (context) {
                      final due = debt.dueDate!;
                      final diff = daysDiff;
                      final isUrgent = diff != null && diff < 3;
                      return Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Row(
                          children: [
                            Icon(Icons.event,
                                size: 12,
                                color: isUrgent ? Colors.red : Colors.grey),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                "Jatuh Tempo: ${DateFormat('dd MMM yyyy').format(due)}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: isUrgent ? Colors.red : Colors.blueGrey,
                                  fontWeight: isUrgent
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  if (debt.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2.0),
                      child: Text(
                        debt.note,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: const Icon(Icons.info_outline_rounded, size: 18, color: Colors.indigo),
                  onPressed: () => onShowDetail(context, debt),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                  onPressed: () => onEdit(context, debt: debt, index: index),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: const Icon(Icons.delete_outline_rounded, size: 18, color: Colors.redAccent),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Hapus Catatan?"),
                        content: const Text("Data ini akan dihapus permanen dari riwayat."),
                        actions: [
                          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Batal")),
                          TextButton(
                            onPressed: () {
                              provider.deleteDebt(index);
                              Navigator.pop(context);
                            }, 
                            child: const Text("Hapus", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
