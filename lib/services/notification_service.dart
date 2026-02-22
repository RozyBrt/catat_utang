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
      
      // 2. Deteksi Zona Waktu Lokal
      final now = DateTime.now();
      final tzAbbr = now.timeZoneName;       // e.g. "WIB", "WITA", "WIT", "EST"
      final offsetSeconds = now.timeZoneOffset.inSeconds; // Dalam detik, sama dengan loc.currentTimeZone.offset

      // Mapping nama singkatan timezone OS ke nama IANA timezone
      // Prioritas zona waktu Indonesia + zona umum lainnya
      const tzAbbreviationMap = <String, String>{
        // Indonesia
        'WIB':  'Asia/Jakarta',
        'WITA': 'Asia/Makassar',
        'WIT':  'Asia/Jayapura',
        // Asia Tenggara lainnya
        'WIB ':  'Asia/Jakarta',
        'ICT':  'Asia/Bangkok',
        'SGT':  'Asia/Singapore',
        'MYT':  'Asia/Kuala_Lumpur',
        'PHT':  'Asia/Manila',
        'JST':  'Asia/Tokyo',
        'KST':  'Asia/Seoul',
        'CST':  'Asia/Shanghai',
        'IST':  'Asia/Kolkata',
        'PKT':  'Asia/Karachi',
        // Eropa
        'GMT':  'Europe/London',
        'UTC':  'UTC',
        'CET':  'Europe/Paris',
        'EET':  'Europe/Helsinki',
        // Amerika
        'EST':  'America/New_York',
        'EDT':  'America/New_York',
        'CST ':  'America/Chicago',
        'CDT':  'America/Chicago',
        'MST':  'America/Denver',
        'MDT':  'America/Denver',
        'PST':  'America/Los_Angeles',
        'PDT':  'America/Los_Angeles',
        // Australia
        'AEST': 'Australia/Sydney',
        'AEDT': 'Australia/Sydney',
        'ACST': 'Australia/Darwin',
        'AWST': 'Australia/Perth',
      };

      // Cari lokasi yang punya offset sama (dalam detik — satuan yang benar)
      String selectedTimeZone = 'Asia/Jakarta'; // Default fallback

      try {
        // Langkah 1: Coba map langsung dari nama singkatan timezone OS
        if (tzAbbreviationMap.containsKey(tzAbbr)) {
          selectedTimeZone = tzAbbreviationMap[tzAbbr]!;
          debugPrint("Timezone resolved via abbreviation map: $tzAbbr → $selectedTimeZone");
        } else {
          // Langkah 2: Fallback — cari berdasarkan offset (dalam detik, satuan yang benar)
          final locations = tz.timeZoneDatabase.locations.values;
          String? matchedByOffset;
          for (var loc in locations) {
            // loc.currentTimeZone.offset adalah dalam DETIK (bukan milidetik)
            if (loc.currentTimeZone.offset == offsetSeconds) {
              matchedByOffset ??= loc.name; // Simpan match pertama
              // Prioritaskan zona yang namanya mengandung nama negara/kota yang lebih dikenal
              if (loc.name.startsWith('Asia/') || loc.name.startsWith('America/') || loc.name.startsWith('Europe/')) {
                selectedTimeZone = loc.name;
                break;
              }
            }
          }
          // Gunakan hasil fallback jika ada
          if (matchedByOffset != null && selectedTimeZone == 'Asia/Jakarta') {
            selectedTimeZone = matchedByOffset;
          }
          debugPrint("Timezone resolved via offset fallback ($offsetSeconds s): $selectedTimeZone");
        }
      } catch (e) {
        debugPrint("Match timezone error: $e — using default: $selectedTimeZone");
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
