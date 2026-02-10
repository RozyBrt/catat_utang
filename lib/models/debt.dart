import 'package:hive/hive.dart';

part 'debt.g.dart';

@HiveType(typeId: 0)
class Debt extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  double amount;

  @HiveField(2)
  DateTime date;

  @HiveField(3)
  String note;

  @HiveField(4)
  bool isPaid;

  @HiveField(5)
  List<String> logs;

  @HiveField(6)
  DateTime? dueDate;

  @HiveField(7)
  DateTime? paidDate; // Tanggal kapan hutang dibayar

  Debt({
    required this.name,
    required this.amount,
    required this.date,
    this.note = '',
    this.isPaid = false,
    this.dueDate,
    this.paidDate,
    List<String>? logs,
  }) : logs = logs ?? ["Catatan dibuat pada ${DateTime.now()}"];

  void addLog(String action) {
    logs.add("$action pada ${DateTime.now()}");
  }

  void updateAmount(double newAmount) {
    addLog("Jumlah diubah dari $amount ke $newAmount");
    amount = newAmount;
  }

  void updateNote(String newNote) {
    addLog("Catatan diubah dari '$note' ke '$newNote'");
    note = newNote;
  }
  
  void updateDueDate(DateTime? newDate) {
    addLog("Jatuh tempo diubah ke $newDate");
    dueDate = newDate;
  }

  void markAsPaid(bool status) {
    isPaid = status;
    if (status) {
      paidDate = DateTime.now();
      addLog("Hutang ditandai sebagai LUNAS");
    } else {
      paidDate = null;
      addLog("Status Lunas DIBATALKAN");
    }
  }
}
