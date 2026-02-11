import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';

class DebtDialog extends StatefulWidget {
  final Debt? debt;
  final int? index;

  const DebtDialog({super.key, this.debt, this.index});

  @override
  State<DebtDialog> createState() => _DebtDialogState();
}

class _DebtDialogState extends State<DebtDialog> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController noteController;
  DateTime? selectedDueDate;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.debt?.name ?? '');
    amountController = TextEditingController(text: widget.debt?.amount.toStringAsFixed(0) ?? '');
    noteController = TextEditingController(text: widget.debt?.note ?? '');
    selectedDueDate = widget.debt?.dueDate;
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, 
      {bool isNumber = false, bool isMultiline = false}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber 
          ? TextInputType.number 
          : (isMultiline ? TextInputType.multiline : TextInputType.text),
      maxLines: isMultiline ? null : 1,
      minLines: isMultiline ? 3 : 1,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.debt != null && widget.index != null;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        top: 32,
        left: 24,
        right: 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isEditing ? 'Edit Catatan Hutang' : 'Tambah Catatan Hutang',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 24),
            _buildTextField(nameController, 'Hutang Kepada (Nama)', Icons.person_outline),
            const SizedBox(height: 16),
            _buildTextField(amountController, 'Jumlah (Rp)', Icons.monetization_on_outlined, isNumber: true),
            const SizedBox(height: 16),
            _buildTextField(noteController, 'Catatan / Alasan Pinjam', Icons.notes_outlined, isMultiline: true),
            const SizedBox(height: 16),
            
            // Due Date Picker
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selectedDueDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 3650)),
                );
                if (picked != null) {
                  setState(() => selectedDueDate = picked);
                }
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today_outlined, size: 20, color: Colors.indigo),
                    const SizedBox(width: 12),
                    Text(
                      selectedDueDate == null 
                        ? 'Set Tanggal Jatuh Tempo (Opsional)' 
                        : 'Jatuh Tempo: ${DateFormat('dd MMM yyyy').format(selectedDueDate!)}',
                      style: TextStyle(
                        color: selectedDueDate == null ? Colors.grey[600] : Colors.indigo,
                        fontWeight: selectedDueDate == null ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (selectedDueDate != null)
                      IconButton(
                        icon: const Icon(Icons.close, size: 18),
                        onPressed: () => setState(() => selectedDueDate = null),
                      )
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            if (isEditing) ...[
              const Text(
                'Riwayat Perubahan',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Container(
                height: 100,
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  itemCount: widget.debt!.logs.length,
                  itemBuilder: (context, i) => Text(
                    "• ${widget.debt!.logs[widget.debt!.logs.length - 1 - i]}",
                    style: const TextStyle(fontSize: 10, color: Colors.blueGrey),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isNotEmpty && amountController.text.isNotEmpty) {
                    final amount = double.tryParse(amountController.text) ?? 0;
                    if (isEditing) {
                      final updatedDebt = widget.debt!;
                      if (updatedDebt.amount != amount) updatedDebt.updateAmount(amount);
                      if (updatedDebt.note != noteController.text) updatedDebt.updateNote(noteController.text);
                      if (updatedDebt.dueDate != selectedDueDate) updatedDebt.updateDueDate(selectedDueDate);
                      updatedDebt.name = nameController.text;
                      context.read<DebtProvider>().updateDebt(widget.index!, updatedDebt);
                    } else {
                      context.read<DebtProvider>().addDebt(Debt(
                            name: nameController.text,
                            amount: amount,
                            date: DateTime.now(),
                            note: noteController.text,
                            dueDate: selectedDueDate,
                          ));
                    }
                    Navigator.pop(context);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
                child: Text(isEditing ? 'Perbarui Catatan' : 'Simpan Hutang'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
