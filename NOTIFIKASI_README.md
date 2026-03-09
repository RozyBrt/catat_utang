# Fitur Notifikasi - Lunasin

## Apa yang Sudah Ditambahkan?

Aplikasi Catat Utang memiliki sistem notifikasi otomatis yang akan mengingatkan Anda saat mendekati tanggal jatuh tempo hutang.

## Cara Kerja Notifikasi

### 1. Notifikasi Otomatis
Setiap kali Anda menambahkan hutang dengan **tanggal jatuh tempo**, aplikasi akan secara otomatis menjadwalkan hingga 3 notifikasi:

- **H-3**: Notifikasi "3 Hari Lagi!" (jam 09:00 waktu lokal)
- **H-1**: Notifikasi "Besok Jatuh Tempo!" (jam 09:00 waktu lokal)
- **H-0**: Notifikasi "Hari Ini Jatuh Tempo!" (jam 09:00 waktu lokal)

> **Catatan Timezone**: Jam notifikasi mengikuti timezone lokal perangkat secara otomatis (WIB, WITA, WIT, dll.) — bukan hardcode WIB.

### 2. Logika Rescue (Second Chance) 🔔
Jika Anda menambahkan hutang **pada hari yang sama** dengan jadwal notifikasi, tetapi jam 09:00 sudah terlewat, sistem akan otomatis **rescheduling notifikasi ke jam 19:00 malam itu juga**, sehingga Anda tetap mendapat pengingat di hari yang sama.

### 3. Notifikasi Akan Otomatis Dibatalkan Jika:
- Hutang ditandai sebagai **Lunas**
- Hutang **dihapus**
- Tanggal jatuh tempo **diubah** (akan dijadwalkan ulang dengan tanggal baru)

### 4. Fitur Tes Notifikasi
Di tab **Pengaturan**, ada tombol "Kirim Notifikasi Tes" untuk memastikan notifikasi berfungsi dengan baik di HP Anda.

---

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
- Hutang yang mendekati deadline akan ditandai dengan warna merah (< 3 hari)

### Langkah 3: Tes Notifikasi (Opsional)
1. Buka tab **Pengaturan** (ikon gear/roda gigi)
2. Klik tombol "Kirim Notifikasi Tes"
3. Notifikasi akan langsung muncul

---

## Izin yang Dibutuhkan

Saat pertama kali membuka aplikasi, Android akan meminta izin:
- ✅ **Izinkan Notifikasi** - Agar aplikasi bisa mengirim pengingat

**PENTING**: Jika Anda menolak izin ini, notifikasi tidak akan berfungsi!

## Cara Mengaktifkan Izin Secara Manual (Jika Terlewat)

Jika Anda tidak sengaja menolak izin:

1. Buka **Pengaturan HP**
2. Cari **Aplikasi** atau **Apps**
3. Cari **Lunasin**
4. Tap **Izin** atau **Permissions**
5. Aktifkan:
   - ✅ Notifikasi
   - ✅ Alarm & Pengingat

---

## Build APK

Untuk build aplikasi ke APK release:

```bash
flutter build apk --release --android-skip-build-dependency-validation
```

File APK akan ada di: `build\app\outputs\flutter-apk\app-release.apk`

---

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

5. **Timezone Otomatis**
   - Jadwal notifikasi mengikuti timezone lokal perangkat secara real-time
   - Timezone di-refresh otomatis setiap kali app dibuka kembali (foreground)

---

## Troubleshooting

### Notifikasi Tidak Muncul?

**Cek 1**: Pastikan izin notifikasi sudah diaktifkan
- Pengaturan HP → Aplikasi → Catat Utang → Izin → Notifikasi ✅

**Cek 2**: Pastikan "Battery Optimization" tidak membatasi aplikasi
- Pengaturan HP → Baterai → Optimasi Baterai
- Cari "Catat Utang" → Pilih "Jangan Optimalkan"

**Cek 3**: Pastikan tanggal jatuh tempo di masa depan
- Notifikasi hanya dijadwalkan jika tanggal masih akan datang

**Cek 4**: Tes dengan tombol di tab Pengaturan
- Jika tes notifikasi muncul, berarti sistem berfungsi

### Notifikasi Muncul Terlambat?

Beberapa HP (terutama Xiaomi, Oppo, Vivo) memiliki pengaturan ketat:
1. Buka **Pengaturan HP**
2. Cari **Autostart** atau **Startup Manager**
3. Aktifkan untuk aplikasi "Catat Utang"

---

## Versi Aplikasi

Versi saat ini: **1.2.2**

---

**Selamat menggunakan fitur notifikasi! Semoga amanah hutang Anda selalu terjaga tepat waktu.** 🙏
