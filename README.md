# Lunasin 📝

Aplikasi pencatat hutang pribadi yang modern, aman, dan pintar. Dibuat dengan Flutter untuk membantu Anda mengelola piutang dan hutang dengan pengingat otomatis agar tetap amanah.

## ✨ Fitur Utama

- **Pencatatan Hutang Digital**: Simpan nama, jumlah, catatan, dan tanggal jatuh tempo dengan mudah.
- **Log Perubahan (History Log)**: Setiap perubahan (update jumlah, catatan, atau tanggal) terekam secara otomatis untuk transparansi.
- **Sistem Pengingat Pintar (Smart Notifications)**:
  - Notifikasi otomatis pada **H-3, H-1, dan Hari Jatuh Tempo** (Pukul 09:00 waktu lokal perangkat).
  - **Logika Rescue (Second Chance)**: Jika jadwal notifikasi jam 09:00 sudah terlewat di hari yang sama, sistem otomatis rescheduling ke jam 19:00 malam itu, agar pengingat tetap tersampaikan.
  - Timezone otomatis mengikuti sistem perangkat (WIB, WITA, WIT, dll.) dan di-refresh setiap kali app dibuka kembali.
- **Manajemen Riwayat**: Pisahkan catatan antara hutang yang masih aktif dan yang sudah lunas.
- **Jadwal Bayar**: Halaman khusus untuk memantau urutan hutang berdasarkan tanggal jatuh tempo terdekat. Hutang yang < 3 hari dari jatuh tempo ditandai merah.
- **Privasi 100%**: Semua data disimpan secara lokal di perangkat menggunakan Hive (Offline). Tidak ada data yang dikirim ke server.

## 🚀 Teknologi yang Digunakan

| Teknologi | Keterangan |
|---|---|
| **Flutter** | Framework utama (Dart SDK ^3.9.0) |
| **Hive** | Database lokal NoSQL berbasis key-value, cepat dan ringan |
| **Provider** | State management — sumber kebenaran tunggal data hutang |
| **flutter_local_notifications** | Sistem notifikasi lokal terjadwal |
| **timezone & flutter_timezone** | Deteksi dan sinkronisasi timezone lokal dari OS secara dinamis |
| **intl** | Format mata uang Rupiah dan tanggal |

## 🛠️ Cara Menjalankan Project

1. **Clone repository ini** (https://github.com/RozyBrt/lunasin.git)
2. **Setup Dependencies**:
   ```powershell
   flutter pub get
   ```
3. **Run App (Debug Mode)**:
   ```powershell
   flutter run
   ```
4. **Build APK (Release Mode)**:
   ```powershell
   flutter build apk --release --android-skip-build-dependency-validation
   ```

## 📱 Persyaratan Sistem

- Android SDK 21 (Lollipop) atau lebih tinggi.
- Rekomendasi Android 13+ untuk pengalaman notifikasi terbaik.

## 🔧 Konfigurasi Build (Development)

- **Java/JDK**: 17
- **Kotlin**: 2.1.0
- **Android Gradle Plugin (AGP)**: 8.6.0

---

*Dibuat untuk mempermudah manajemen keuangan pribadi dengan prinsip keterbukaan dan kedisiplinan.*
