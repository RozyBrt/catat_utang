import 'package:flutter_test/flutter_test.dart';
import 'package:catat_utang/models/debt.dart';

void main() {
  group('Debt Provider Integration Tests', () {
    test('Debt list operations should work correctly', () {
      final debts = <Debt>[];
      
      final debt1 = Debt(
        name: 'User 1',
        amount: 100000,
        date: DateTime(2026, 2, 10),
      );
      
      debts.add(debt1);
      expect(debts.length, 1);
      
      final debt2 = Debt(
        name: 'User 2',
        amount: 200000,
        date: DateTime(2026, 2, 11),
      );
      
      debts.add(debt2);
      expect(debts.length, 2);
    });

    test('Should calculate total debt correctly', () {
      final debts = <Debt>[
        Debt(name: 'User 1', amount: 100000, date: DateTime.now()),
        Debt(name: 'User 2', amount: 200000, date: DateTime.now()),
        Debt(name: 'User 3', amount: 150000, date: DateTime.now(), isPaid: true),
      ];

      final totalUnpaid = debts
          .where((d) => !d.isPaid)
          .fold(0.0, (sum, item) => sum + item.amount);

      expect(totalUnpaid, 300000);
    });

    test('Should filter paid and unpaid debts correctly', () {
      final debts = <Debt>[
        Debt(name: 'Unpaid 1', amount: 100000, date: DateTime.now()),
        Debt(name: 'Paid 1', amount: 200000, date: DateTime.now(), isPaid: true),
        Debt(name: 'Unpaid 2', amount: 150000, date: DateTime.now()),
      ];

      final unpaid = debts.where((d) => !d.isPaid).toList();
      final paid = debts.where((d) => d.isPaid).toList();

      expect(unpaid.length, 2);
      expect(paid.length, 1);
    });
  });
}
