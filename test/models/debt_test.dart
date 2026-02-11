import 'package:flutter_test/flutter_test.dart';
import 'package:catat_utang/models/debt.dart';

void main() {
  group('Debt Model Tests', () {
    test('Debt should be created with correct properties', () {
      final debt = Debt(
        name: 'John Doe',
        amount: 100000,
        date: DateTime(2026, 2, 10),
        note: 'Test debt',
        dueDate: DateTime(2026, 2, 15),
      );

      expect(debt.name, 'John Doe');
      expect(debt.amount, 100000);
      expect(debt.note, 'Test debt');
      expect(debt.isPaid, false);
      expect(debt.dueDate, DateTime(2026, 2, 15));
      expect(debt.logs, isNotEmpty);
    });

    test('Debt should have initial log entry', () {
      final debt = Debt(
        name: 'Jane Doe',
        amount: 250000,
        date: DateTime(2026, 2, 10),
        note: 'Test',
      );

      expect(debt.logs.length, 1);
      expect(debt.logs.first, contains('Catatan dibuat pada'));
    });

    test('Debt should handle paid status correctly', () {
      final debt = Debt(
        name: 'Test User',
        amount: 50000,
        date: DateTime(2026, 2, 10),
        dueDate: DateTime(2026, 2, 20),
      );

      expect(debt.isPaid, false);
      expect(debt.paidDate, isNull);

      debt.markAsPaid(true);

      expect(debt.isPaid, true);
      expect(debt.paidDate, isNotNull);
      expect(debt.logs.last, contains('LUNAS'));
    });

    test('Debt should track amount updates in logs', () {
      final debt = Debt(
        name: 'Test',
        amount: 100000,
        date: DateTime(2026, 2, 10),
      );

      final initialLogCount = debt.logs.length;
      debt.updateAmount(150000);

      expect(debt.amount, 150000);
      expect(debt.logs.length, initialLogCount + 1);
      expect(debt.logs.last, contains('Jumlah diubah'));
      expect(debt.logs.last, contains('100000'));
      expect(debt.logs.last, contains('150000'));
    });

    test('Debt should track note updates in logs', () {
      final debt = Debt(
        name: 'Test',
        amount: 100000,
        date: DateTime(2026, 2, 10),
        note: 'Original note',
      );

      final initialLogCount = debt.logs.length;
      debt.updateNote('Updated note');

      expect(debt.note, 'Updated note');
      expect(debt.logs.length, initialLogCount + 1);
      expect(debt.logs.last, contains('Catatan diubah'));
    });

    test('Debt should track due date updates in logs', () {
      final debt = Debt(
        name: 'Test',
        amount: 100000,
        date: DateTime(2026, 2, 10),
        dueDate: DateTime(2026, 2, 15),
      );

      final initialLogCount = debt.logs.length;
      final newDueDate = DateTime(2026, 2, 20);
      debt.updateDueDate(newDueDate);

      expect(debt.dueDate, newDueDate);
      expect(debt.logs.length, initialLogCount + 1);
      expect(debt.logs.last, contains('Jatuh tempo diubah'));
    });

    test('Debt should handle unpaid status correctly', () {
      final debt = Debt(
        name: 'Test',
        amount: 100000,
        date: DateTime(2026, 2, 10),
      );

      debt.markAsPaid(true);
      expect(debt.isPaid, true);
      expect(debt.paidDate, isNotNull);

      debt.markAsPaid(false);
      expect(debt.isPaid, false);
      expect(debt.paidDate, isNull);
      expect(debt.logs.last, contains('DIBATALKAN'));
    });

    test('Debt should add custom log entries', () {
      final debt = Debt(
        name: 'Test',
        amount: 100000,
        date: DateTime(2026, 2, 10),
      );

      final initialLogCount = debt.logs.length;
      debt.addLog('Custom action');

      expect(debt.logs.length, initialLogCount + 1);
      expect(debt.logs.last, contains('Custom action'));
      expect(debt.logs.last, contains('pada'));
    });

    test('Debt should handle optional due date', () {
      final debtWithDueDate = Debt(
        name: 'Test 1',
        amount: 100000,
        date: DateTime(2026, 2, 10),
        dueDate: DateTime(2026, 2, 15),
      );

      final debtWithoutDueDate = Debt(
        name: 'Test 2',
        amount: 200000,
        date: DateTime(2026, 2, 10),
      );

      expect(debtWithDueDate.dueDate, isNotNull);
      expect(debtWithoutDueDate.dueDate, isNull);
    });
  });
}
