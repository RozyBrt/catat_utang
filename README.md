# Catat Utang 📝

Aplikasi pencatat hutang pribadi yang modern, aman, dan pintar. Dibuat dengan Flutter untuk membantu Anda mengelola piutang dan hutang dengan pengingat otomatis agar tetap amanah.

## ✨ Fitur Utama

- **Pencatatan Hutang Digital**: Simpan nama, jumlah, catatan, dan tanggal jatuh tempo dengan mudah.
- **Log Perubahan (History Log)**: Setiap perubahan (update jumlah, catatan, atau tanggal) terekam secara otomatis untuk transparansi.
- **Sistem Pengingat Pintar (Smart Notifications)**:
  - Notifikasi otomatis pada **H-3, H-1, dan Hari Jatuh Tempo** (Pukul 09:00 WIB).
  - **Logika Rescue (Second Chance)**: Jika Anda mencatat hutang di sore hari untuk besok, sistem otomatis menjadwalkan pengingat jam 19:00 malam ini agar Anda tidak lupa.
- **Manajemen Riwayat**: Pisahkan catatan antara hutang yang masih aktif dan yang sudah lunas.
- **Jadwal Bayar**: Halaman khusus untuk memantau urutan hutang berdasarkan tanggal jatuh tempo terdekat.
- **Privasi 100%**: Semua data disimpan secara lokal di perangkat Anda menggunakan Hive (Offline). Tidak ada data yang dikirim ke server.

## 🚀 Teknologi yang Digunakan

- **Framework**: Flutter
- **Database Lokal**: Hive (NoSQL yang sangat cepat)
- **State Management**: Provider
- **Local Notifications**: `flutter_local_notifications`
- **Timezone Support**: `timezone` & `flutter_timezone` (Konfigurasi manual fallback untuk stabilitas build)
- **UI Design**: Vanilla CSS-like styling dengan kustomisasi Glassmorphism dan Vibrant Colors.

## 🛠️ Cara Menjalankan Project

1. **Clone repository ini**
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
