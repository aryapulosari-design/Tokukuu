# Panduan Tokoku · Toko Pak Irfan

Dokumen kerja per 1 November 2026. Aplikasi ini dibuat untuk toko sembako kecil yang perlu mengingat harga, mencatat penjualan, dan menagih hutang. Rancangan LabaRapi di `BLUEPRINT.md` adalah dokumen lama yang tidak menggambarkan kebutuhan Tokoku.

## Alur utama

| Halaman | Fungsi |
| --- | --- |
| Beranda | Penjualan hari ini, uang yang masuk hari ini, total hutang aktif, jumlah barang, dan transaksi terbaru. |
| Barang | Menambah, mencari, melihat, dan mengubah nama serta harga jual. Nama barang harus unik. |
| Kasir | Memilih barang dan jumlah, melihat total, lalu menyimpan transaksi lunas atau hutang. |
| Hutang | Melihat sisa per transaksi dan mencatat pembayaran dengan nominal yang tidak melebihi sisa. |
| Riwayat | Melihat rincian transaksi dengan nama dan harga barang yang tersimpan saat penjualan. |

## Aturan uang dan data

- Rupiah disimpan sebagai bilangan bulat. Total baris = harga saat transaksi × jumlah; total transaksi = jumlah seluruh baris.
- Transaksi lunas menyimpan pembayaran sebesar total. Transaksi hutang memerlukan nama pelanggan, dan pembayaran awal harus lebih kecil dari total.
- Sisa hutang = total transaksi − pembayaran awal − seluruh pembayaran berikutnya. Pembayaran berikutnya harus positif dan tidak melebihi sisa.
- Harga barang boleh berubah, tetapi harga transaksi lama tidak berubah.
- Uang masuk hari ini menghitung pembayaran awal dari transaksi hari ini dan cicilan hutang yang dicatat hari ini. Penjualan hari ini menghitung nilai transaksi hari ini, termasuk yang belum lunas.
- Data disimpan dalam satu dokumen JSON lokal melalui `shared_preferences` dengan kunci `toko_pak_irfan_v1`. Data prototipe CSV lama memakai kunci lain dan tidak dihapus otomatis.

## QA yang sudah dan belum dilakukan

Tes otomatis memeriksa harga historis, perhitungan sisa hutang, pembayaran berlebih, transaksi hutang tanpa pelanggan, dan format rupiah. Pada pemeriksaan terakhir, `flutter analyze` bersih dan `flutter test` lulus. Tampilan kosong Beranda, Barang, dan Kasir telah dilihat pada jendela Windows selebar sekitar 402 px dan desktop 1536 px; peringatan sidebar ditemukan dan diperbaiki.

Masih perlu uji langsung pada ponsel Android kecil, uji kasir dengan banyak barang, dan uji penyimpanan setelah aplikasi ditutup lalu dibuka lagi. Belum ada stok, barcode, cetak struk, diskon, retur, laporan laba, cadangan, ekspor, akun, sinkronisasi, ataupun banyak perangkat. Fitur ini tidak diklaim tersedia.

Risiko utama sebelum dipakai sebagai catatan tunggal toko: data hanya ada di satu perangkat dan dapat hilang jika perangkat rusak atau data aplikasi terhapus. APK produksi juga memerlukan application ID final dan keystore milik pemilik toko.