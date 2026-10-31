# Tokoku · Toko Pak Irfan

Aplikasi kasir sederhana untuk toko sembako. Spesifikasi kerja yang berlaku ada di [Panduan Tokoku](Panduan/TOKOKU.md). `Panduan/BLUEPRINT.md` adalah rancangan LabaRapi lama dan tidak lagi menjadi acuan fitur aplikasi ini.

## Pakai aplikasi

1. Buka **Barang**, lalu masukkan nama dan harga jual barang.
2. Buka **Kasir**, pilih jumlah barang, lalu simpan transaksi sebagai **Lunas** atau **Hutang**. Untuk hutang, isi nama pelanggan dan uang yang dibayar saat itu.
3. Buka **Hutang** untuk melihat sisa tagihan dan mencatat pembayaran sebagian atau pelunasan.
4. Buka **Riwayat** untuk melihat barang, jumlah, dan harga pada saat transaksi terjadi. **Beranda** menampilkan penjualan dan uang masuk hari ini.

Data disimpan lokal di perangkat. Menghapus aplikasi atau data aplikasi dapat menghapus catatan. Belum tersedia cadangan, ekspor, sinkronisasi, atau pemakaian bersama beberapa perangkat. Simpan catatan penting secara terpisah sampai fitur cadangan tersedia.

## Jalankan dan build

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
flutter build apk --release
```

APK berada di `build/app/outputs/flutter-apk/app-release.apk` setelah build. Konfigurasi Android saat ini memakai debug signing untuk build release, sehingga APK tersebut hanya untuk uji instalasi dan belum siap distribusi resmi.