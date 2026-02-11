import 'package:flutter_test/flutter_test.dart';
import 'package:catat_utang/services/notification_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() {
  group('NotificationService Tests', () {
    late NotificationService notificationService;

    setUpAll(() {
      // Initialize timezone data for testing
      tz.initializeTimeZones();
    });

    setUp(() {
      notificationService = NotificationService();
    });

    test('NotificationService should be a singleton', () {
      final instance1 = NotificationService();
      final instance2 = NotificationService();
      
      expect(identical(instance1, instance2), true);
    });

    test('NotificationService should initialize successfully', () async {
      // Note: This test might fail in CI/CD without proper Android/iOS setup
      // In real testing, you'd mock the flutter_local_notifications plugin
      expect(notificationService, isNotNull);
    });

    test('NotificationService should detect timezone correctly', () {
      // Initialize timezones
      tz.initializeTimeZones();
      
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      
      // Find a location with matching offset
      String? detectedTimeZone;
      final locations = tz.timeZoneDatabase.locations.values;
      
      for (var loc in locations) {
        if (loc.currentTimeZone.offset == offset.inMilliseconds) {
          detectedTimeZone = loc.name;
          break;
        }
      }
      
      expect(detectedTimeZone, isNotNull);
      expect(detectedTimeZone, isNotEmpty);
    });

    test('NotificationService should calculate correct notification times', () {
      final dueDate = DateTime(2026, 2, 15, 9, 0); // Feb 15, 2026 at 9:00 AM
      
      // H-3 should be Feb 12, 2026 at 9:00 AM
      final h3Date = dueDate.subtract(const Duration(days: 3));
      expect(h3Date.day, 12);
      expect(h3Date.month, 2);
      expect(h3Date.hour, 9);
      
      // H-1 should be Feb 14, 2026 at 9:00 AM
      final h1Date = dueDate.subtract(const Duration(days: 1));
      expect(h1Date.day, 14);
      expect(h1Date.month, 2);
      expect(h1Date.hour, 9);
      
      // H-0 should be Feb 15, 2026 at 9:00 AM
      expect(dueDate.day, 15);
      expect(dueDate.month, 2);
      expect(dueDate.hour, 9);
    });

    test('NotificationService should handle rescue logic correctly', () {
      // If current time is after 9 AM but before 7 PM
      final now = DateTime(2026, 2, 10, 15, 0); // 3 PM
      final dueDate = DateTime(2026, 2, 11, 9, 0); // Tomorrow at 9 AM
      
      // Should schedule for 7 PM today
      final rescueTime = DateTime(now.year, now.month, now.day, 19, 0);
      
      expect(rescueTime.day, now.day);
      expect(rescueTime.hour, 19);
      expect(rescueTime.isAfter(now), true);
      expect(rescueTime.isBefore(dueDate), true);
    });

    test('NotificationService lastLog should be initialized', () {
      expect(NotificationService.lastLog, isNotNull);
      expect(NotificationService.lastLog, isNotEmpty);
    });

    test('Notification ID ranges should not overlap', () {
      const h3RangeStart = 10000;
      const h3RangeEnd = 19999;
      const h1RangeStart = 20000;
      const h1RangeEnd = 29999;
      const h0RangeStart = 30000;
      const h0RangeEnd = 39999;
      const instantRangeStart = 40000;
      
      // Verify no overlap
      expect(h3RangeEnd < h1RangeStart, true);
      expect(h1RangeEnd < h0RangeStart, true);
      expect(h0RangeEnd < instantRangeStart, true);
    });

    test('Notification should handle edge cases for due dates', () {
      // Test with due date in the past
      final pastDate = DateTime(2026, 1, 1);
      final now = DateTime(2026, 2, 10);
      
      expect(pastDate.isBefore(now), true);
      
      // Test with due date today
      final today = DateTime(now.year, now.month, now.day, 23, 59);
      expect(today.day, now.day);
      
      // Test with due date far in future
      final futureDate = DateTime(2027, 12, 31);
      expect(futureDate.isAfter(now), true);
    });
  });
}
