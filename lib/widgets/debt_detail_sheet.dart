import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';

class DebtDetailSheet extends StatelessWidget {
  final Debt debt;
  final String Function(double) formatRupiah;

  const DebtDetailSheet({
    super.key,
    required this.debt,
    required this.formatRupiah,
  });

  Widget _buildDetailSection(String label, String value, IconData icon, {Color? color}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[400]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: color ?? const Color(0xFF1E293B),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    debt.isPaid ? "DIBAYAR LUNAS" : "STATUS: HUTANG",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      color: debt.isPaid ? const Color(0xFF166534) : const Color(0xFF991B1B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatRupiah(debt.amount),
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: debt.isPaid ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  debt.isPaid ? Icons.check_circle : Icons.timer_outlined,
                  color: debt.isPaid ? const Color(0xFF166534) : const Color(0xFF991B1B),
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildDetailSection("Hutang Kepada", debt.name, Icons.person_outline),
          const SizedBox(height: 16),
          _buildDetailSection("Waktu Pinjam", DateFormat('dd MMMM yyyy HH:mm').format(debt.date), Icons.access_time),
          if (debt.isPaid && debt.paidDate != null) ...[
            const SizedBox(height: 16),
            _buildDetailSection("Waktu Dibayar", DateFormat('dd MMMM yyyy HH:mm').format(debt.paidDate!), Icons.check_circle_outline, color: Colors.green),
          ],
          if (!debt.isPaid && debt.dueDate != null) ...[
            const SizedBox(height: 16),
            _buildDetailSection("Jatuh Tempo", DateFormat('dd MMMM yyyy').format(debt.dueDate!), Icons.event, 
                color: debt.isPaid ? null : (debt.dueDate!.difference(DateTime.now()).inDays < 3 ? Colors.red : null)),
          ],
          if (debt.note.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildDetailSection("Catatan", debt.note, Icons.notes_outlined),
          ],
          const SizedBox(height: 32),
          const Text(
            "Riwayat Perubahan",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: debt.logs.length,
                itemBuilder: (context, i) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("• ", style: TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                      Expanded(
                        child: Text(
                          debt.logs[debt.logs.length - 1 - i],
                          style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
