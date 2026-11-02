# Panduan Hosting LabaRapi

Bagian ini juga tersedia dalam dokumen Word dan BLUEPRINT.md versi 1.1.

## Panduan hosting Arsitektur dan pilihan layanan

Tujuan: menerbitkan LabaRapi sebagai aplikasi nyata, sekaligus mempertahankan pengalaman yang selaras dengan website VELKIRA dan proyek sebelumnya. Panduan ini untuk tahap implementasi nanti; belum ada hosting, domain atau akun layanan yang diubah.

### Kondisi proyek yang sudah diperiksa

next.config.mjs saat ini memakai output export. README.md dan dokumen/10-hosting-gratis-cloudflare.md menjelaskan build ke out lalu unggah ZIP ke Cloudflare Pages. Ini adalah konfigurasi dan panduan lokal; status website yang benar-benar aktif belum diperiksa. Informasi pengguna menyebut domain velkira.site dibeli di Hostinger, tetapi jenis paket hosting belum diketahui.

| Bagian | Rancangan penerbitan |
| --- | --- |
| Agency dan SunDays | Tetap mengikuti alur statis sebelumnya. Kartu portofolio menautkan LabaRapi. |
| Aplikasi LabaRapi | Usulan labarapi.velkira.site pada Hostinger Node.js Web App bila paket mendukung. |
| Database dan login | Supabase PostgreSQL serta Auth; proyek staging dan produksi dipisah. |
| Pekerjaan latar | Render Background Worker untuk commit batch dan pekerjaan lama; antrean durabel di database. |
| Asisten AI | Panggilan dari server atau worker dengan secret; kuota dan batas anggaran diatur. |
| Alternatif aplikasi | Vercel dengan runtime Next.js jika Hostinger yang dimiliki belum mendukung. |

### Keputusan yang harus dipahami

LabaRapi tidak cukup diterbitkan dengan ZIP statis agency: Route Handlers, sesi server dan panggilan AI membutuhkan runtime. Rekomendasi proyek aplikasi terpisah mempertahankan konfigurasi agency. Nama subdomain adalah usulan, bukan alamat aktif. Tidak perlu membeli domain tambahan untuk memakai subdomain yang tersedia pada domain milik pengguna.

Pilih Hostinger bila akun sudah menyediakan Node.js Web App dan batasnya lulus uji. Kepemilikan domain saja tidak berarti memiliki layanan tersebut. Jika belum tersedia, bandingkan biaya paket yang sesuai dengan alternatif Vercel. Biaya database, worker, email dan AI dihitung terpisah; panduan ini tidak menjanjikan operasional gratis.

## Panduan hosting Persiapan aplikasi dan data

### Persiapan proyek LabaRapi

Implementasikan aplikasi sebagai proyek tersendiri dengan lockfile, versi Node yang didukung provider dan versi Next.js yang dipilih. Konfigurasi LabaRapi menggunakan runtime server; jangan membawa output export dari proyek agency. Perubahan ini hanya untuk proyek aplikasi. Baca panduan framework yang terpasang sebelum menulis konfigurasi final.

| Perintah yang direncanakan | Fungsi dan batas |
| --- | --- |
| npm ci | Memasang dependency dari lockfile pada proyek LabaRapi. |
| npm test | Menjalankan pengujian uang, impor, akses dan AI yang sudah dibuat. |
| npm run build | Membangun aplikasi Next.js untuk runtime server, bukan ZIP out agency. |
| npm start | Script aplikasi yang nanti menjalankan next start dan menghormati port provider. |
| npm run worker | Script worker yang nanti dibangun untuk antrean, claim, lease, retry dan shutdown. |

Script start dan worker tersebut belum tersedia pada source agency saat dokumen ditulis. Jangan menjalankannya di root VELKIRA dengan anggapan LabaRapi sudah dibuat. Build dan pengujian dilakukan dari root proyek aplikasi yang nanti ditetapkan.

### Persiapan Supabase

Buat proyek staging lebih dulu. Terapkan migrasi lengkap beserta policies, grants dan fungsi transaksi; lampiran SQL blueprint baru kerangka struktur. Uji dua toko, tiga role, impor ulang dan pembalikan sebelum membuat produksi. Pilih koneksi database serta pooler sesuai runtime dan dukungan jaringan host; gunakan TLS dan akun worker dengan hak minimum.

Atur Site URL ke origin aplikasi final. Tambahkan redirect login atau pemulihan yang benar-benar dibuat aplikasi, misalnya https://labarapi.velkira.site/auth/callback. Path tersebut harus diimplementasikan dahulu. Produksi memakai alamat yang eksplisit; preview memakai konfigurasi staging terpisah. Uji email undangan, login, logout dan pemulihan; siapkan pengiriman email sesuai batas provider.

### Rahasia dan berkas impor

Masukkan environment pada panel layanan, bukan pada file publik. NEXT_PUBLIC_SUPABASE_URL dan publishable key boleh dipakai klien dengan RLS; OPENAI_API_KEY, DATABASE_URL serta secret administratif tetap di server. Raw file hanya diproses sementara; yang masuk staging dan antrean adalah baris bisnis yang sudah disanitasi. Sesuaikan batas upload dengan host paling ketat sebelum menampilkan angka 10 MB kepada pengguna.

## Panduan hosting Langkah penerbitan layanan

### Jalur utama Hostinger

Panduan resmi Hostinger mencantumkan dukungan Node.js pada paket Business dan sejumlah paket Cloud. Periksa ketersediaan di akun sendiri sebelum membeli atau mengubah layanan. Label menu dapat berubah; gunakan alur Web App atau Node.js, bukan WordPress dan bukan unggahan static out.

- Buka Websites lalu Create site atau Add website dan pilih Web App. Gunakan Import Git Repository untuk menghubungkan repository LabaRapi.
- Pilih cabang staging dahulu, root aplikasi yang benar, preset Next.js dan versi Node yang cocok dengan framework. Jangan memilih source agency untuk mengganti situs yang sudah ada.
- Isi environment staging. Periksa build command, start command, runtime, batas upload, memori dan durasi request pada pengaturan yang disediakan.
- Jalankan deployment, baca log yang telah disanitasi dan uji URL sementara bila tersedia. Perbaiki build atau konfigurasi sebelum menghubungkan subdomain.
- Setelah staging lulus dan lingkungan produksi siap, terbitkan commit yang sama ke produksi dengan secrets produksi.

### Worker Render yang dipasangkan

Buat Background Worker dari repository aplikasi yang sama. Tetapkan root, versi runtime, build command dan start command npm run worker sesuai script yang sudah diimplementasikan. Tambahkan koneksi database serta secret yang memang diperlukan; worker tidak memerlukan alamat web publik. Worker Render berjalan terus dan mengambil pekerjaan dari antrean, sehingga pekerjaan lama tidak bergantung pada request halaman.

Untuk rancangan awal, job impor memakai import_batches pada PostgreSQL dengan claim atomik, lease dan retry. Migrasi perlu menambah metadata lease, attempt dan error yang belum ada pada SQL kerangka; job AI memakai ai_runs dengan kontrol sejenis. Uji dua worker, restart dan crash sebelum produksi. Jangan memakai memory queue atau raw file lokal sebagai penyimpanan pekerjaan. WORKER_QUEUE_URL dapat dihapus bila tidak memakai broker antrean tersendiri.

### Alternatif Vercel

Import repository LabaRapi sebagai proyek Next.js, pilih root aplikasi, isi environment staging dan deploy preview. Setelah lulus pengujian, isi environment produksi, deploy commit yang sama dan tambahkan subdomain pada pengaturan Domains. Worker tetap layanan terpisah. Jangan memaksakan pekerjaan panjang setelah respons serverless berakhir. Periksa ketentuan paket untuk penggunaan komersial, durasi fungsi, upload dan biaya sebelum memilih.

## Panduan hosting Domain integrasi dan perawatan

### Hubungkan subdomain yang diusulkan

Tambahkan labarapi.velkira.site pada panel host aplikasi dahulu, lalu ikuti record DNS yang diberikan panel. Edit record pada penyedia DNS yang benar-benar otoritatif: jika nameserver masih Hostinger, gunakan panel DNS Hostinger; jika sudah Cloudflare, edit di Cloudflare. Pendaftar domain dan pengelola DNS dapat berbeda.

Untuk subdomain, panel lazimnya meminta CNAME atau record tujuan lain; gunakan jenis, nama dan target persis dari host, bukan IP contoh. Tunggu verifikasi dan sertifikat HTTPS, lalu uji login pada origin final. Pertahankan record agency, www, MX dan TXT email. Menghubungkan subdomain tidak mengharuskan pemindahan domain atau penggantian nameserver.

### Samakan dengan portofolio sebelumnya

Pada tahap implementasi, tambahkan kartu LabaRapi di bagian portofolio agency, halaman studi kasus publik dan tautan Buka aplikasi ke subdomain final. Sediakan tautan Kembali ke VELKIRA di aplikasi. Logo, font, forest, lime dan gaya penulisan mengikuti Tahap 4. Kredensial dan data toko tidak ikut halaman publik.

Pembaruan agency tetap mengikuti panduan lama: npm run build, npm test, lalu package-site.ps1 dan unggah release/velkira-sundays-hosting.zip ke proyek Pages yang benar. Paket tersebut hanya memuat file publik. Aplikasi dan worker diperbarui lewat deployment masing-masing; database berubah melalui migrasi terkontrol. Dokumen internal, .env dan file laporan tidak masuk ZIP.

### Uji sebelum menyerahkan alamat ke klien

- Agency, SunDays dan link portofolio tetap terbuka; subdomain aplikasi memiliki HTTPS tanpa aset localhost.
- Login, undangan, logout, redirect dan pembatasan akses dua toko berhasil pada alamat final.
- Impor valid tampil pada laporan setelah worker selesai; duplikat, timeout dan restart tidak menggandakan uang.
- AI menjawab dengan sumber atau memberi status gagal yang jelas; API key tidak muncul pada browser maupun paket statis.
- Backup dapat dipulihkan; error, antrean, email dan biaya provider dipantau oleh pengelola yang ditetapkan.

### Pembaruan dan rollback

Simpan commit, versi migrasi dan deployment terakhir yang stabil. Rilis database dengan perubahan yang kompatibel, uji di staging, lalu deploy aplikasi dan worker. Bila gagal, hentikan penerimaan job baru dan rollback kode yang masih kompatibel; jangan menghapus ledger atau memulihkan database lama tanpa rencana rekonsiliasi. Kesiapan hosting baru dinyatakan setelah URL final dan alur nyata diuji.

## Referensi resmi

- [Hostinger Node.js Web App](https://www.hostinger.com/support/how-to-deploy-a-nodejs-website-in-hostinger/)
- [Cloudflare Pages static Next.js](https://developers.cloudflare.com/pages/framework-guides/nextjs/deploy-a-static-nextjs-site/)
- [Vercel custom domain](https://vercel.com/docs/domains/working-with-domains/add-a-domain)
- [Supabase redirect URL](https://supabase.com/docs/guides/auth/redirect-urls)
- [Render Background Worker](https://render.com/docs/background-workers)
