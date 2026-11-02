# Tokoku — Kasir Toko Pak Irfan

Tokoku adalah aplikasi kasir sederhana untuk membantu toko sembako mengelola daftar barang, mencatat penjualan tunai maupun hutang, dan memantau pembayaran pelanggan. Aplikasi dibuat dengan Flutter dan menyimpan data secara lokal di perangkat.

## Fitur

- **Beranda:** ringkasan penjualan hari ini, uang yang diterima hari ini, total hutang yang belum lunas, jumlah barang aktif, dan transaksi terbaru.
- **Barang:** tambah dan ubah nama, harga jual, dan satuan barang; cari barang serta nonaktifkan barang tanpa menghapus riwayatnya. Nama barang harus unik.
- **Kasir:** cari barang, masukkan jumlah termasuk pecahan, berikan diskon, lalu simpan transaksi sebagai lunas atau hutang. Metode pembayaran yang tersedia mencakup tunai, transfer, dan QRIS.
- **Hutang:** lihat tagihan yang dikelompokkan per pelanggan dan catat pembayaran sebagian atau pelunasan.
- **Riwayat:** periksa rincian transaksi, harga saat transaksi dibuat, diskon, pembayaran, dan sisa hutang. Transaksi tanpa cicilan dapat dibatalkan; arsipnya tetap tersimpan.
- **Cadangan dan ekspor:** simpan/pulihkan data lengkap dalam berkas JSON dan ekspor penjualan ke CSV untuk dibuka di spreadsheet.

Saat pertama kali dijalankan tanpa data, aplikasi mengisi daftar barang contoh agar kasir dapat langsung dicoba. Ubah atau nonaktifkan barang contoh sebelum dipakai untuk transaksi sebenarnya.

## Menjalankan aplikasi

Pastikan [Flutter SDK](https://docs.flutter.dev/get-started/install) sudah terpasang, lalu jalankan dari direktori proyek:

```powershell
flutter pub get
flutter analyze
flutter test
flutter run -d windows
```

Untuk menjalankan di perangkat atau emulator Android, gunakan:

```powershell
flutter run
```

Untuk membuat APK uji instalasi:

```powershell
flutter build apk --release
```

Hasilnya tersedia di `build/app/outputs/flutter-apk/app-release.apk`.

## Penyimpanan dan keamanan data

Data barang, transaksi, dan pembayaran disimpan lokal menggunakan `shared_preferences`; aplikasi tidak menyinkronkan atau mengunggah data ke server. Data tidak otomatis ikut berpindah ke perangkat lain dan dapat hilang jika data aplikasi dihapus atau perangkat rusak.

Gunakan menu **Lainnya → Simpan cadangan** secara berkala dan simpan berkas JSON di lokasi yang aman. **Pulihkan cadangan** akan mengganti seluruh data yang sedang ada di perangkat, jadi buat cadangan kondisi saat ini terlebih dahulu. **Ekspor penjualan CSV** berisi rincian barang per transaksi; CSV ini bukan berkas untuk memulihkan data.

## Batasan dan kesiapan rilis

- Tokoku belum menyediakan stok, barcode, cetak struk, retur, akun pengguna, sinkronisasi, atau pemakaian bersama beberapa perangkat.
- APK release saat ini menggunakan debug signing dan application ID contoh `com.example.tokokuu`. APK tersebut hanya untuk uji instalasi, belum untuk distribusi resmi. Rilis resmi memerlukan application ID final dan konfigurasi signing milik pemilik aplikasi.
- Petunjuk kebutuhan dan aturan kerja aplikasi ada di [Panduan Tokoku](Panduan/TOKOKU.md). [Blueprint LabaRapi](Panduan/BLUEPRINT.md) adalah dokumen proyek lama dan bukan spesifikasi fitur Tokoku.
