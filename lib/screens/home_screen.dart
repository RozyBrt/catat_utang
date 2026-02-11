import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/debt.dart';
import '../providers/debt_provider.dart';
import '../widgets/debt_dialog.dart';
import '../widgets/debt_detail_sheet.dart';
import 'sections/dashboard_section.dart';
import 'sections/history_section.dart';
import 'sections/schedule_section.dart';
import 'sections/profile_section.dart';

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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DebtDialog(debt: debt, index: index),
    );
  }

  void _showDebtDetail(BuildContext context, Debt debt) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DebtDetailSheet(debt: debt, formatRupiah: _formatRupiah),
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
                DashboardSection(
                  provider: provider,
                  totalAktif: totalAktif,
                  totalLunas: totalLunas,
                  recentDurationHours: _recentDurationHours,
                  formatRupiah: _formatRupiah,
                  onViewAll: () => setState(() => _currentIndex = 1),
                  onEdit: _showDebtDialog,
                  onShowDetail: _showDebtDetail,
                ),
                HistorySection(
                  provider: provider,
                  onEdit: _showDebtDialog,
                  onShowDetail: _showDebtDetail,
                ),
                ScheduleSection(
                  provider: provider,
                  onEdit: _showDebtDialog,
                  onShowDetail: _showDebtDetail,
                ),
                const ProfileSection(),
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
}
