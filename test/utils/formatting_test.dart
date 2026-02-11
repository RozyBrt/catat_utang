import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('Currency Formatting Tests', () {
    test('Should format currency correctly for Indonesian Rupiah', () {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      expect(formatter.format(0), 'Rp 0');
      expect(formatter.format(1000), contains('1'));
      expect(formatter.format(10000), contains('10'));
      expect(formatter.format(100000), contains('100'));
      expect(formatter.format(1000000), contains('1'));
    });

    test('Should handle large amounts', () {
      final formatter = NumberFormat.currency(
        locale: 'id_ID',
        symbol: 'Rp ',
        decimalDigits: 0,
      );

      final result = formatter.format(1000000000);
      expect(result, contains('Rp'));
      expect(result, contains('1'));
    });
  });

  group('Date Comparison Tests', () {
    test('Should compare dates correctly', () {
      final date1 = DateTime(2026, 2, 11);
      final date2 = DateTime(2026, 2, 15);
      final date3 = DateTime(2026, 2, 11);
      
      expect(date1.isBefore(date2), true);
      expect(date2.isAfter(date1), true);
      expect(date1.isAtSameMomentAs(date3), true);
    });

    test('Should calculate days difference correctly', () {
      final date1 = DateTime(2026, 2, 11);
      final date2 = DateTime(2026, 2, 15);
      
      final difference = date2.difference(date1).inDays;
      expect(difference, 4);
    });

    test('Should handle same day comparison', () {
      final date1 = DateTime(2026, 2, 11, 10, 0);
      final date2 = DateTime(2026, 2, 11, 15, 0);
      
      expect(date1.year, date2.year);
      expect(date1.month, date2.month);
      expect(date1.day, date2.day);
    });

    test('Should detect overdue dates', () {
      final now = DateTime(2026, 2, 11);
      final pastDate = DateTime(2026, 2, 5);
      final futureDate = DateTime(2026, 2, 20);
      
      expect(pastDate.isBefore(now), true);
      expect(futureDate.isAfter(now), true);
    });

    test('Should handle month boundaries', () {
      final endOfMonth = DateTime(2026, 2, 28);
      final startOfNextMonth = DateTime(2026, 3, 1);
      
      final difference = startOfNextMonth.difference(endOfMonth).inDays;
      expect(difference, 1);
    });

    test('Should handle year boundaries', () {
      final endOfYear = DateTime(2026, 12, 31);
      final startOfNextYear = DateTime(2027, 1, 1);
      
      final difference = startOfNextYear.difference(endOfYear).inDays;
      expect(difference, 1);
    });
  });

  group('Number Validation Tests', () {
    test('Should validate positive numbers', () {
      expect(100000 > 0, true);
      expect(0 > 0, false);
      expect(-100 > 0, false);
    });

    test('Should validate number ranges', () {
      const minAmount = 1000;
      const maxAmount = 100000000;
      
      expect(50000 >= minAmount && 50000 <= maxAmount, true);
      expect(500 >= minAmount, false);
      expect(200000000 <= maxAmount, false);
    });
  });

  group('String Validation Tests', () {
    test('Should validate non-empty strings', () {
      expect('John Doe'.isNotEmpty, true);
      expect(''.isEmpty, true);
      expect('   '.trim().isEmpty, true);
    });

    test('Should validate string length', () {
      const minLength = 3;
      const maxLength = 50;
      
      expect('John'.length >= minLength, true);
      expect('Jo'.length >= minLength, false);
      expect('A' * 100, hasLength(greaterThan(maxLength)));
    });
  });
}
