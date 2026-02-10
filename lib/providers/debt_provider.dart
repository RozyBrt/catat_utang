import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/debt.dart';

class DebtProvider with ChangeNotifier {
  static const String _boxName = 'debts_box';
  List<Debt> _debts = [];

  List<Debt> get debts => _debts;

  double get totalDebt => _debts.where((d) => !d.isPaid).fold(0, (sum, item) => sum + item.amount);

  Future<void> init() async {
    final box = await Hive.openBox<Debt>(_boxName);
    _debts = box.values.toList();
    notifyListeners();
  }

  Future<void> addDebt(Debt debt) async {
    final box = Hive.box<Debt>(_boxName);
    await box.add(debt);
    _debts = box.values.toList();
    notifyListeners();
  }

  Future<void> togglePaid(int index) async {
    final box = Hive.box<Debt>(_boxName);
    final debt = box.getAt(index);
    if (debt != null) {
      debt.markAsPaid(!debt.isPaid);
      await debt.save();
      _debts = box.values.toList();
      notifyListeners();
    }
  }

  Future<void> updateDebt(int index, Debt updatedDebt) async {
    final box = Hive.box<Debt>(_boxName);
    await box.putAt(index, updatedDebt);
    _debts = box.values.toList();
    notifyListeners();
  }

  Future<void> deleteDebt(int index) async {
    final box = Hive.box<Debt>(_boxName);
    await box.deleteAt(index);
    _debts = box.values.toList();
    notifyListeners();
  }
}
