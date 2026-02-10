# Fitur Notifikasi - Catat Utang

## Apa yang Sudah Ditambahkan?

Aplikasi Catat Utang sekarang memiliki sistem notifikasi otomatis yang akan mengingatkan Anda saat mendekati tanggal jatuh tempo hutang.

## Cara Kerja Notifikasi

### 1. Notifikasi Otomatis
Setiap kali Anda menambahkan hutang dengan **tanggal jatuh tempo**, aplikasi akan secara otomatis menjadwalkan 3 notifikasi:

- **H-3**: Notifikasi "Pengingat: 3 Hari Lagi!" (jam 9 pagi)
- **H-1**: Notifikasi "Pengingat: Besok Jatuh Tempo!" (jam 9 pagi)
- **H-0**: Notifikasi "Hari Ini Jatuh Tempo!" (jam 9 pagi)

### 2. Notifikasi Akan Otomatis Dibatalkan Jika:
- Hutang ditandai sebagai **Lunas**
- Hutang **dihapus**
- Tanggal jatuh tempo **diubah** (akan dijadwalkan ulang dengan tanggal baru)

### 3. Fitur Tes Notifikasi
Di halaman **Profil**, ada tombol "Kirim Notifikasi Tes" untuk memastikan notifikasi berfungsi dengan baik di HP Anda.

## Cara Menggunakan

### Langkah 1: Tambah Hutang dengan Jatuh Tempo
1. Klik tombol **+** di tengah bawah
2. Isi nama, jumlah, dan catatan
3. **PENTING**: Tap pada "Set Tanggal Jatuh Tempo"
4. Pilih tanggal kapan hutang harus dibayar
5. Klik "Simpan Hutang"

✅ Notifikasi otomatis sudah terjadwal!

### Langkah 2: Cek Jadwal di Tab "Jadwal"
- Buka tab **Jadwal** (ikon kalender)
- Lihat semua hutang yang memiliki jatuh tempo
- Hutang yang mendekati deadline akan ditandai dengan warna merah

### Langkah 3: Tes Notifikasi (Opsional)
1. Buka tab **Profil** (ikon orang)
2. Klik tombol "Kirim Notifikasi Tes"
3. Notifikasi akan langsung muncul

## Izin yang Dibutuhkan

Saat pertama kali membuka aplikasi versi baru, Android akan meminta izin:
- ✅ **Izinkan Notifikasi** - Agar aplikasi bisa mengirim pengingat
- ✅ **Izinkan Alarm Tepat Waktu** - Agar notifikasi muncul di waktu yang tepat

**PENTING**: Jika Anda menolak izin ini, notifikasi tidak akan berfungsi!

## Cara Mengaktifkan Izin Secara Manual (Jika Terlewat)

Jika Anda tidak sengaja menolak izin:

1. Buka **Pengaturan HP**
2. Cari **Aplikasi** atau **Apps**
3. Cari **Catat Utang**
4. Tap **Izin** atau **Permissions**
5. Aktifkan:
   - ✅ Notifikasi
   - ✅ Alarm & Pengingat

## Build APK Baru

Untuk menggunakan fitur notifikasi, Anda perlu build ulang aplikasi:

```bash
flutter build apk --release
```

File APK akan ada di: `build\app\outputs\flutter-apk\app-release.apk`

## Catatan Penting

1. **Notifikasi hanya untuk hutang yang belum lunas**
   - Jika hutang sudah ditandai lunas, notifikasi otomatis dibatalkan

2. **Notifikasi bekerja offline**
   - Tidak butuh internet, semua dijadwalkan di HP Anda

3. **Hemat Baterai**
   - Notifikasi menggunakan sistem Android yang efisien
   - Tidak akan menguras baterai

4. **Privasi Terjaga**
   - Semua notifikasi lokal, tidak ada data yang dikirim ke server

## Troubleshooting

### Notifikasi Tidak Muncul?

**Cek 1**: Pastikan izin notifikasi sudah diaktifkan
- Pengaturan HP → Aplikasi → Catat Utang → Izin → Notifikasi ✅

**Cek 2**: Pastikan "Battery Optimization" tidak membatasi aplikasi
- Pengaturan HP → Baterai → Optimasi Baterai
- Cari "Catat Utang" → Pilih "Jangan Optimalkan"

**Cek 3**: Pastikan tanggal jatuh tempo di masa depan
- Notifikasi hanya dijadwalkan jika tanggal masih akan datang

**Cek 4**: Tes dengan tombol di halaman Profil
- Jika tes notifikasi muncul, berarti sistem berfungsi

### Notifikasi Muncul Terlambat?

Beberapa HP (terutama Xiaomi, Oppo, Vivo) memiliki pengaturan ketat:
1. Buka **Pengaturan HP**
2. Cari **Autostart** atau **Startup Manager**
3. Aktifkan untuk aplikasi "Catat Utang"

## Versi Aplikasi

Versi dengan fitur notifikasi: **1.1.0**

---

**Selamat menggunakan fitur notifikasi! Semoga amanah hutang Anda selalu terjaga tepat waktu.** 🙏
