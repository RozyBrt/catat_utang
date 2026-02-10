import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/debt.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static String lastLog = "Not Initialized";

  static const int _scheduledIdRange = 0;
  static const int _instantIdRange = 100000;

  Future<bool> initialize() async {
    if (_initialized) return true;

    try {
      // 1. Initialize Timezones
      tz.initializeTimeZones();
      
      // 2. Deteksi Zona Waktu Lokal (Manual/Safe Way)
      // Mengambil offset dari waktu sistem sekarang
      final now = DateTime.now();
      final offset = now.timeZoneOffset;
      
      // Cari lokasi yang punya offset sama
      String selectedTimeZone = 'Asia/Jakarta'; // Default fallback
      
      try {
        final locations = tz.timeZoneDatabase.locations.values;
        for (var loc in locations) {
          if (loc.currentTimeZone.offset == offset.inMilliseconds) {
            selectedTimeZone = loc.name;
            break;
          }
        }
      } catch (e) {
        debugPrint("Match timezone error: $e");
      }
      
      tz.setLocalLocation(tz.getLocation(selectedTimeZone));

      // 3. Android Settings
      const androidSettings = AndroidInitializationSettings('notif_icon');
      
      // 4. iOS Settings
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(android: androidSettings, iOS: iosSettings);

      await _notifications.initialize(initSettings);
      
      // Request permissions but don't let it block _initialized state
      try {
        await _requestPermissions();
        lastLog = "Initialized & Permissions Requested";
      } catch (e) {
        lastLog = "Initialized, but Permission Request Failed: $e";
        debugPrint("Minor: Permission request failed: $e");
      }
      
      _initialized = true;
      debugPrint("NotificationService initialized: $_initialized (Detected: $selectedTimeZone)");
      lastLog = "Success (TZ: $selectedTimeZone)";
      return true;
    } catch (e) {
      lastLog = "FATAL Error: $e";
      debugPrint("FATAL: Notification initialization failed: $e");
      return false;
    }
  }

  Future<bool?> _requestPermissions() async {
    return await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  Future<void> scheduleDebtReminder(Debt debt, [int? fallbackId]) async {
    if (debt.dueDate == null || debt.isPaid) {
      await cancelDebtNotifications(debt);
      return;
    }

    final int baseId = (debt.key is int) ? (debt.key as int) : (fallbackId ?? 0);
    final now = DateTime.now();
    final dueDate = debt.dueDate!;

    await _cancelById(baseId);

    final schedules = [
      {'days': 3, 'title': '3 Hari Lagi!'},
      {'days': 1, 'title': 'Besok Jatuh Tempo!'},
      {'days': 0, 'title': 'Hari Ini Jatuh Tempo!'},
    ];

    for (var s in schedules) {
      final daysBefore = s['days'] as int;
      DateTime notifDate = DateTime(dueDate.year, dueDate.month, dueDate.day - daysBefore, 9, 0);

      if (notifDate.isBefore(now)) {
        final eveningRescue = DateTime(now.year, now.month, now.day, 19, 0);
        bool isSameDayAsNotif = notifDate.year == now.year && 
                               notifDate.month == now.month && 
                               notifDate.day == now.day;

        if (isSameDayAsNotif && eveningRescue.isAfter(now)) {
          notifDate = eveningRescue;
        }
      }

      if (notifDate.isAfter(now)) {
        final finalId = _generateId(baseId, daysBefore);
        await _notifications.zonedSchedule(
          finalId,
          s['title'] as String,
          'Ke ${debt.name}: ${_formatCurrency(debt.amount)}',
          tz.TZDateTime.from(notifDate, tz.local),
          _notifDetails('debt_reminders', 'Pengingat Hutang'),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> cancelDebtNotifications(Debt debt) async {
    if (debt.key is int) {
      await _cancelById(debt.key as int);
    }
  }

  Future<void> _cancelById(int baseId) async {
    for (int i = 0; i <= 3; i++) {
      await _notifications.cancel(_generateId(baseId, i));
    }
  }

  int _generateId(int baseId, int offset) {
    return _scheduledIdRange + (baseId * 10) + offset;
  }

  Future<void> showInstantNotification(String title, String body) async {
    try {
      if (!_initialized) {
        lastLog = "Not initialized, trying now...";
        final ok = await initialize();
        if (!ok) {
          lastLog = "Auto-init failed";
          return;
        }
      }
      
      final int instantId = _instantIdRange + (DateTime.now().millisecondsSinceEpoch % 10000);
      lastLog = "Showing notif: $instantId";
      
      await _notifications.show(
        instantId,
        title,
        body,
        _notifDetails('instant_notifications', 'Notifikasi Instan', importance: Importance.max),
      );
      lastLog = "Show called successfully";
    } catch (e) {
      lastLog = "Show error: $e";
      debugPrint("Error showing notification: $e");
    }
  }

  NotificationDetails _notifDetails(String id, String name, {Importance importance = Importance.high}) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        id, name,
        channelDescription: 'Pemberitahuan aplikasi',
        importance: importance,
        priority: Priority.max,
        icon: 'notif_icon',
        playSound: true,
        enableVibration: true,
      ),
      iOS: const DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(amount);
  }

  Future<void> cancelAll() async => await _notifications.cancelAll();
}
