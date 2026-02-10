import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  
  // UBAH ANGKA INI: Berapa jam catatan muncul di beranda
  static const int _recentDurationHours = 6; 

  String _formatRupiah(double amount) {
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(amount);
  }

  void _showDebtDialog(BuildContext context, {Debt? debt, int? index}) {
    final isEditing = debt != null && index != null;
    final nameController = TextEditingController(text: debt?.name ?? '');
    final amountController =
        TextEditingController(text: debt?.amount.toStringAsFixed(0) ?? '');
    final noteController = TextEditingController(text: debt?.note ?? '');
    DateTime? selectedDueDate = debt?.dueDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
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
                      setModalState(() => selectedDueDate = picked);
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
                            onPressed: () => setModalState(() => selectedDueDate = null),
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
                      itemCount: debt.logs.length,
                      itemBuilder: (context, i) => Text(
                        "• ${debt.logs[debt.logs.length - 1 - i]}",
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
                          final updatedDebt = debt;
                          if (updatedDebt.amount != amount) updatedDebt.updateAmount(amount);
                          if (updatedDebt.note != noteController.text) updatedDebt.updateNote(noteController.text);
                          if (updatedDebt.dueDate != selectedDueDate) updatedDebt.updateDueDate(selectedDueDate);
                          updatedDebt.name = nameController.text;
                          context.read<DebtProvider>().updateDebt(index, updatedDebt);
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
        ),
      ),
    );
  }

  void _showDebtDetail(BuildContext context, Debt debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                      _formatRupiah(debt.amount),
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
      ),
    );
  }

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Consumer<DebtProvider>(
          builder: (context, provider, _) {
            final totalAktif = provider.debts.where((d) => !d.isPaid).fold(0.0, (sum, item) => sum + item.amount);
            final totalLunas = provider.debts.where((d) => d.isPaid).fold(0.0, (sum, item) => sum + item.amount);

            return IndexedStack(
              index: _currentIndex,
              children: [
                _buildHomeDashboard(provider, totalAktif, totalLunas),
                _buildDebtHistory(provider),
                _buildSchedulePage(provider),
                _buildPlaceholder("Halaman Profil", Icons.person_pin_outlined, Colors.orange),
              ],
            );
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDebtDialog(context),
        backgroundColor: const Color(0xFF6366F1),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildHomeDashboard(DebtProvider provider, double totalAktif, double totalLunas) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'CATATAN\nHUTANG SAYA',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w900,
              height: 1.1,
              letterSpacing: -0.5,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "Total Yang Harus Dibayar: ${_formatRupiah(totalAktif)}",
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildSummaryCard(
                  'BELUM DIBAYAR',
                  _formatRupiah(totalAktif),
                  const Color(0xFFFEE2E2),
                  const Color(0xFF991B1B),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSummaryCard(
                  'TOTAL SUDAH DIBAYAR',
                  _formatRupiah(totalLunas),
                  const Color(0xFFDCFCE7),
                  const Color(0xFF166534),
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Catatan Pinjaman Terbaru',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
              ),
              TextButton(
                onPressed: () => setState(() => _currentIndex = 1),
                child: const Text('Lihat Semua', style: TextStyle(color: Color(0xFF6366F1))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Builder(
            builder: (context) {
              final now = DateTime.now();
              final recentItems = provider.debts.asMap().entries
                  .where((e) => now.difference(e.value.date).inHours < _recentDurationHours)
                  .toList()
                  .reversed
                  .toList();
              
              if (recentItems.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Tidak ada catatan dalam $_recentDurationHours jam terakhir", 
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                );
              }

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: recentItems.length > 5 ? 5 : recentItems.length,
                itemBuilder: (context, index) {
                  final entry = recentItems[index];
                  return _buildTransactionItem(entry.value, entry.key, provider);
                },
              );
            },
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildDebtHistory(DebtProvider provider) {
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

  Widget _buildSchedulePage(DebtProvider provider) {
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
                
                return _buildTransactionItem(debt, entry.key, provider, isScheduleView: true, daysDiff: diff);
              },
            ),
        ),
      ],
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox_outlined, size: 64, color: Colors.grey[200]),
            const SizedBox(height: 16),
            Text('Tidak ada data', style: TextStyle(color: Colors.grey[400])),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 100),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final entry = filtered[index];
        return _buildTransactionItem(entry.value, entry.key, provider);
      },
    );
  }

  Widget _buildPlaceholder(String text, IconData icon, Color color) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: color.withOpacity(0.2)),
          const SizedBox(height: 16),
          Text(text, style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Fitur ini akan segera hadir!", style: TextStyle(color: Colors.blueGrey)),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: textColor.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              amount,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(Debt debt, int index, DebtProvider provider, {bool isScheduleView = false, int? daysDiff}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showDebtDetail(context, debt),
        onLongPress: () => _showDebtDialog(context, debt: debt, index: index),
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
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Row(
                        children: [
                          Icon(Icons.event, size: 12, color: daysDiff != null && daysDiff < 3 ? Colors.red : Colors.grey),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              "Jatuh Tempo: ${DateFormat('dd MMM yyyy').format(debt.dueDate!)}",
                              style: TextStyle(
                                fontSize: 11, 
                                color: daysDiff != null && daysDiff < 3 ? Colors.red : Colors.blueGrey,
                                fontWeight: daysDiff != null && daysDiff < 3 ? FontWeight.bold : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  onPressed: () => _showDebtDetail(context, debt),
                ),
                IconButton(
                  constraints: const BoxConstraints(),
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  icon: const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
                  onPressed: () => _showDebtDialog(context, debt: debt, index: index),
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

  Widget _buildBottomNav() {
    return BottomAppBar(
      height: 72,
      padding: EdgeInsets.zero,
      notchMargin: 8,
      shape: const CircularNotchedRectangle(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'Beranda', 0),
          _buildNavItem(Icons.account_balance_wallet_outlined, 'Riwayat', 1),
          const SizedBox(width: 48),
          _buildNavItem(Icons.calendar_month_outlined, 'Jadwal', 2),
          _buildNavItem(Icons.person_outline, 'Profil', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: isSelected ? const Color(0xFF6366F1) : Colors.grey),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? const Color(0xFF6366F1) : Colors.grey,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
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
}
