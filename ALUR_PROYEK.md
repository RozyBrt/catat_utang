# 📓 Alur Proyek: Catat Utang

Aplikasi Flutter untuk **mencatat hutang** secara lokal. Semua data disimpan di perangkat (offline), tidak perlu internet, dan dilengkapi **notifikasi otomatis** pengingat jatuh tempo.

---

## 🏗️ Gambaran Besar Arsitektur

```
main.dart
  ├── Inisialisasi Hive (database lokal)
  ├── Inisialisasi NotificationService
  ├── Buat DebtProvider (state management)
  └── Jalankan MyApp → HomeScreen
```

Pola arsitektur yang dipakai: **Provider + Hive**
- **Hive** = database lokal (seperti sqlite tapi lebih simpel, berbasis key-value)
- **Provider** = cara widget Flutter "dengar" perubahan data dan otomatis refresh UI

---

## 📁 Struktur Folder `lib/`

```
lib/
├── main.dart                         ← Titik masuk aplikasi
│
├── models/
│   └── debt.dart                     ← Blueprint satu data hutang
│
├── providers/
│   └── debt_provider.dart            ← Pusat logika & state data
│
├── services/
│   └── notification_service.dart     ← Semua urusan notifikasi
│
├── screens/
│   ├── home_screen.dart              ← Layar utama + navigasi bawah
│   └── sections/
│       ├── dashboard_section.dart    ← Tab Beranda
│       ├── history_section.dart      ← Tab Riwayat
│       ├── schedule_section.dart     ← Tab Jadwal
│       └── profile_section.dart     ← Tab Pengaturan
│
└── widgets/
    ├── debt_dialog.dart              ← Form tambah/edit hutang
    ├── debt_detail_sheet.dart        ← Popup detail hutang
    ├── transaction_item.dart         ← Kartu hutang di list
    ├── summary_card.dart             ← Kartu total ringkasan
    └── empty_state.dart              ← Tampilan kalau list kosong
```

---

## 🧱 Model Data: `Debt`

Satu objek `Debt` menyimpan data berikut:

| Field | Tipe | Keterangan |
|---|---|---|
| `name` | `String` | Nama orang yang berhutang |
| `amount` | `double` | Jumlah uang (Rupiah) |
| `date` | `DateTime` | Tanggal catatan dibuat |
| `note` | `String` | Catatan/alasan pinjam |
| `isPaid` | `bool` | Sudah lunas atau belum |
| `dueDate` | `DateTime?` | Tanggal jatuh tempo (opsional) |
| `paidDate` | `DateTime?` | Tanggal saat lunas dicatat |
| `logs` | `List<String>` | Riwayat semua perubahan |

> `Debt` menyimpan **log otomatis** setiap kali ada perubahan: ganti jumlah, ganti catatan, ganti jatuh tempo, atau tandai lunas.

---

## ⚙️ State Management: `DebtProvider`

`DebtProvider` adalah **satu-satunya sumber kebenaran** data hutang. Semua widget yang butuh data hutang mengambil dari sini.

```
DebtProvider
├── _debts         ← List semua hutang di memori
├── debts          ← Getter publik untuk baca list
├── totalDebt      ← Hitung otomatis total yang belum lunas
│
├── init()         ← Buka Hive box, muat semua data, jadwalkan notifikasi
├── addDebt()      ← Tambah hutang baru → simpan ke Hive → notif UI
├── togglePaid()   ← Toggle lunas/belum lunas → update Hive → notif UI
├── updateDebt()   ← Edit hutang → update Hive → notif UI
└── deleteDebt()   ← Hapus hutang → batalkan notifikasi → hapus dari Hive → notif UI
```

Setiap operasi selalu diakhiri `notifyListeners()` → semua widget yang "dengarkan" provider otomatis **rebuild/refresh**.

---

## 🖥️ Navigasi: `HomeScreen`

`HomeScreen` adalah layar satu-satunya. Navigasi pakai **Bottom Navigation Bar** dengan 4 tab:

```
BottomNavigationBar
  ├── [0] 🏠 Beranda    → DashboardSection
  ├── [1] 💼 Riwayat   → HistorySection
  ├──     [+]            → FAB (Floating Action Button) — Tambah hutang baru
  ├── [2] 📅 Jadwal    → ScheduleSection
  └── [3] ⚙️ Pengaturan → ProfileSection
```

`IndexedStack` dipakai agar **semua tab tetap hidup** di memori, jadi tidak reload saat pindah tab.

> **Tampilan Layar:**

| Beranda | Riwayat (Belum Lunas) | Riwayat (Sudah Lunas) |
|:---:|:---:|:---:|
| ![Beranda](assets/screenshots/01_beranda.jpeg) | ![Riwayat Belum Lunas](assets/screenshots/02_riwayat_belum_lunas.jpeg) | ![Riwayat Lunas](assets/screenshots/03_riwayat_lunas.jpeg) |

| Jadwal Bayar | Form Tambah Hutang | Detail Hutang |
|:---:|:---:|:---:|
| ![Jadwal](assets/screenshots/04_jadwal.jpeg) | ![Form Tambah](assets/screenshots/05_form_tambah.jpeg) | ![Detail](assets/screenshots/06_detail_hutang.jpeg) |

---

## 🔄 Alur Fitur Utama

### 1. Tambah Hutang Baru

```
Pengguna tekan tombol [+]
  → HomeScreen buka DebtDialog (modal bottom sheet)
    → Pengguna isi: Nama, Jumlah, Catatan, Jatuh Tempo
    → Tekan "Simpan Hutang"
      → DebtProvider.addDebt(debt)
        → Simpan ke Hive (persisten)
        → NotificationService.scheduleDebtReminder(debt)
        → notifyListeners() → UI semua tab refresh
```

### 2. Tandai Hutang Lunas

```
Pengguna tap ikon lingkaran (✅/⏳) di kartu hutang
  → TransactionItem memanggil provider.togglePaid(index)
    → DebtProvider.togglePaid()
      → debt.markAsPaid(!debt.isPaid)
        → Jika lunas: catat paidDate, tambah log
        → Jika dibatalkan: hapus paidDate, tambah log
      → Simpan ke Hive
      → NotificationService: batalkan notif kalau lunas
      → notifyListeners() → UI refresh
```

### 3. Edit Hutang

```
Pengguna long-press kartu hutang, ATAU tekan ikon ✏️
  → HomeScreen buka DebtDialog dengan data hutang yang ada
    → Pengguna ubah data
    → Tekan "Perbarui Catatan"
      → DebtProvider.updateDebt(index, updatedDebt)
        → Log perubahan otomatis dicatat (jumlah, catatan, jatuh tempo)
        → Update di Hive
        → NotificationService reschedule notifikasi
        → notifyListeners() → UI refresh
```

### 4. Hapus Hutang

```
Pengguna tekan ikon 🗑️ di kartu hutang
  → Muncul dialog konfirmasi "Hapus Catatan?"
    → Pengguna tekan "Hapus"
      → DebtProvider.deleteDebt(index)
        → NotificationService.cancelDebtNotifications(debt)
        → Hapus dari Hive
        → notifyListeners() → UI refresh
```

### 5. Lihat Detail Hutang

```
Pengguna tap kartu hutang, ATAU tekan ikon ℹ️
  → HomeScreen buka DebtDetailSheet (modal bottom sheet)
    → Tampilkan: jumlah, nama, waktu pinjam
    → Kalau belum lunas: tampilkan jatuh tempo (merah kalau < 3 hari)
    → Kalau lunas: tampilkan tanggal lunas
    → Tampilkan semua riwayat perubahan (logs)
```

---

## 📋 Tiap Tab: Apa yang Ditampilkan

### 🏠 Beranda (`DashboardSection`)
![Beranda](assets/screenshots/01_beranda.jpeg)
- Judul besar "CATATAN HUTANG SAYA"
- Total yang harus dibayar
- Dua summary card: **Belum Dibayar** (merah) dan **Sudah Dibayar** (hijau)
- List hutang **terbaru** — hanya yang dibuat dalam **6 jam terakhir** (bisa diubah via `_recentDurationHours`)
- Tombol "Lihat Semua" → pindah ke tab Riwayat

### 💼 Riwayat (`HistorySection`)
![Riwayat Belum Lunas](assets/screenshots/02_riwayat_belum_lunas.jpeg) ![Riwayat Lunas](assets/screenshots/03_riwayat_lunas.jpeg)
- Dua tab: **"Belum Lunas"** dan **"Sudah Lunas"**
- Semua hutang diurutkan dari yang terbaru
- Setiap item bisa dilihat detailnya, diedit, atau dihapus

### 📅 Jadwal (`ScheduleSection`)
![Jadwal](assets/screenshots/04_jadwal.jpeg)
- Hanya menampilkan hutang yang **belum lunas dan punya tanggal jatuh tempo**
- Diurutkan dari jatuh tempo yang paling dekat
- Menampilkan berapa hari lagi jatuh tempo (merah kalau urgent < 3 hari)

### ⚙️ Pengaturan (`ProfileSection`)
- Tombol **"Kirim Notifikasi Tes"** untuk cek apakah notifikasi berfungsi
- Info aplikasi: versi, penyimpanan (Hive/Lokal), privasi (100% Offline)
- Status terakhir NotificationService (untuk debugging)

### 📝 Form & Detail
![Form Tambah](assets/screenshots/05_form_tambah.jpeg) ![Detail Hutang](assets/screenshots/06_detail_hutang.jpeg)

---

## 🔔 Sistem Notifikasi: `NotificationService`

Service ini adalah **singleton** (satu instance untuk seluruh app).

```
Saat app pertama kali dibuka:
  → NotificationService.initialize()
    → Deteksi timezone lokal (WIB/WITA/WIT/dst.)
    → Setup flutter_local_notifications
    → Minta izin notifikasi ke user (Android/iOS)
```

**Jadwal notifikasi otomatis per hutang:**

```
Saat hutang punya dueDate dan belum lunas:
  → Notifikasi dijadwalkan 3x:
    ├── H-3 (3 hari sebelum jatuh tempo) jam 09:00 → "3 Hari Lagi!"
    ├── H-1 (1 hari sebelum)             jam 09:00 → "Besok Jatuh Tempo!"
    └── H-0 (hari H jatuh tempo)         jam 09:00 → "Hari Ini Jatuh Tempo!"
         (kalau jam 09:00 sudah lewat hari itu, rescheduled ke jam 19:00)

Saat hutang ditandai lunas / jatuh tempo dihapus:
  → Semua notifikasi hutang tersebut dibatalkan
```

ID notifikasi digenerate dari Hive key hutang supaya tidak tabrakan antar hutang.

---

## 🗄️ Penyimpanan Data: Hive

- Hive menyimpan data di **file lokal perangkat** (bukan cloud, bukan server)
- `debt.g.dart` adalah file *auto-generated* yang memberi tahu Hive cara serialize/deserialize objek `Debt`
- Box name: `'debts_box'`
- Kalau app dihapus, data ikut hilang

---

## 🔗 Diagram Ketergantungan Antar File

```
main.dart
  ├── uses → DebtProvider, NotificationService, Debt (model)
  └── runs → HomeScreen

HomeScreen
  ├── uses → DebtProvider (via Consumer<DebtProvider>)
  ├── shows → DashboardSection, HistorySection, ScheduleSection, ProfileSection
  ├── opens → DebtDialog (tambah/edit)
  └── opens → DebtDetailSheet (lihat detail)

DashboardSection / HistorySection / ScheduleSection
  └── uses → TransactionItem (untuk setiap kartu hutang di list)

DebtDialog
  └── calls → DebtProvider.addDebt() / DebtProvider.updateDebt()

TransactionItem
  └── calls → DebtProvider.togglePaid() / DebtProvider.deleteDebt()

DebtProvider
  ├── uses → Hive (baca/tulis/hapus data)
  └── uses → NotificationService (jadwalkan/batalkan notifikasi)
```
