# LabaRapi PRD dan Blueprint Pengembangan

PRD dan Blueprint Pengembangan

Aplikasi analisis margin toko online dengan asisten AI

Versi 1.1  |  30 Oktober 2026  |  Pemilik produk VELKIRA

### Tujuan dokumen

Dokumen ini mengunci kebutuhan produk, rumus, alur impor, model data, API, desain, kontrol AI dan rencana pengembangan LabaRapi sebelum coding. Produk ditujukan untuk penggunaan operasional dengan login, penyimpanan database dan hasil yang dapat ditelusuri. Target serta checklist merupakan rencana, bukan klaim aplikasi sudah dibangun.

### Definisi produk

LabaRapi membantu pemilik toko memahami penjualan, modal, biaya dan margin berdasarkan laporan serta biaya yang dimasukkan. Pengguna dapat melihat sumber angka per produk dan periode, kemudian meminta AI menjelaskan hasil. Sistem menghitung nominal; AI membaca hasil yang sudah dihitung.

Label hasil utama adalah margin kontribusi atau hasil setelah biaya tercatat. Jangan menyebutnya laba bersih usaha bila pajak, biaya operasional, retur atau komponen lain belum lengkap. Data yang kurang ditampilkan sebagai belum lengkap, bukan dianggap nol.

### Keputusan awal dan asumsi

| Sudah disepakati | Asumsi untuk perencanaan |
| --- | --- |
| Nama kerja LabaRapi; analisis margin, impor laporan dan sedikit AI. | Target awal penjual Shopee yang sudah merekap dengan spreadsheet; validasi dengan calon pengguna diperlukan. |
| Dokumen lengkap dan Word disimpan di folder coding. Tidak menulis aplikasi pada tahap ini. | IDR, zona waktu Asia/Jakarta, satu toko aktif pada pilot; struktur data mengisolasi toko untuk keamanan. |
| AI berupa ringkasan serta tanya laporan, tanpa tindakan otomatis. | Format resmi laporan belum diberikan. Template CSV LabaRapi menjadi baseline; adapter Shopee menunggu contoh yang sah. |

### Batas penting

Nama, domain dan merek belum diperiksa secara hukum. Tidak ada janji banyak pengguna atau peningkatan keuntungan. API Shopee, harga layanan, model AI dan format laporan dipastikan sebelum integrasi; tidak melakukan scraping atau meminta password marketplace.

## Tahap 1 PRD dan validasi pasar

### Executive summary

Penjualan yang tinggi belum menjelaskan biaya dan margin tiap produk. Penjual yang menggabungkan laporan serta modal secara manual membutuhkan proses yang dapat diperiksa dan diulang. LabaRapi memusatkan pekerjaan impor, pencocokan SKU, kelengkapan biaya, analisis periode dan penjelasan hasil.

### Persona dan target awal

| Pengguna | Masalah utama | Manfaat yang diuji |
| --- | --- | --- |
| Pemilik toko marketplace | Sulit memahami produk yang menyumbang margin atau biaya yang berubah. | Melihat rincian hasil tanpa menggabungkan banyak file sendiri. |
| Admin keuangan toko kecil | Rekap berulang, format laporan berbeda, modal belum lengkap. | Validasi impor, pencocokan SKU dan koreksi yang dapat dilacak. |
| Brand kecil online | Perlu membandingkan hasil produk dan periode. | Definisi metrik konsisten dan penjelasan berbasis data. |

### KPI produk dan bisnis

| KPI | Target awal usulan | Pengukuran |
| --- | --- | --- |
| Validasi kebutuhan | 10–15 wawancara, 3 toko pilot memakai data sendiri. | Catat proses sekarang, hambatan, penggunaan ulang dan kesediaan membayar. |
| Kegunaan | 4 dari 5 peserta menemukan produk bermargin rendah tanpa bantuan. | Tugas memakai laporan yang sudah diverifikasi. |
| Akurasi engine | Seluruh kasus referensi menghasilkan nominal tepat. | Fixture uang, retur, alokasi, pembulatan dan duplikasi. |
| Transparansi | Semua angka laporan memiliki sumber dan rule version. | Telusuri laporan ke ledger, batch dan baris impor. |
| AI aman | Tidak ada angka/referensi yang tak didukung pada set evaluasi rilis. | Uji grounding, data kosong dan permintaan lintas toko. |

Target di atas bukan bukti minat pasar. Rilis komersial memerlukan penggunaan berulang dan komitmen nyata. Hindari mengembangkan fitur luas hanya berdasarkan pujian terhadap ide; ukur apakah produk menggantikan pekerjaan rekap yang benar-benar dilakukan.

## Tahap 1 Core flow dan prioritas fitur

### Alur utama

Daftar/login > buat toko > unggah laporan > pilih jenis dan pemetaan kolom > validasi > cocokkan SKU > tinjau error/duplikasi > konfirmasi impor > lengkapi modal serta biaya > periksa laporan > konfirmasi kelengkapan > minta ringkasan AI atau tanya laporan.

Pemilik dapat membuka rincian sumber, memperbaiki biaya melalui koreksi tercatat, lalu menghasilkan snapshot laporan baru. Perubahan data membuat hasil serta ringkasan lama berlabel kedaluwarsa. Tidak mengubah laporan lama diam-diam.

| MVP wajib | Kriteria penerimaan |
| --- | --- |
| Akun dan toko | Login, owner/editor/viewer, data privat, isolasi antar toko. |
| Impor terverifikasi | Template CSV dan XLSX yang didukung; staging, error per baris, deduplikasi dan commit atomik. |
| Produk dan modal | SKU dipetakan dengan konfirmasi; modal berlaku per tanggal dan di-snapshot pada transaksi. |
| Biaya | Catat kemasan, iklan dan biaya operasional; tunjukkan alokasi serta biaya yang belum lengkap. |
| Analisis | Margin per produk/periode, perbandingan dan rincian sumber; bukan grafik angka tetap. |
| AI terbatas | Ringkasan dan tanya laporan hanya dari snapshot serta metrik terotorisasi. |
| Koreksi dan audit | Pembalikan dan pengganti untuk ledger; histori tidak dihapus diam-diam. |
| Operasional | Validasi, loading, empty/error, backup, monitoring dan panduan pengguna. |

### Fase 2 dan di luar scope

Fase 2: adapter tambahan yang teruji, integrasi resmi marketplace, dashboard banyak toko, lampiran biaya, notifikasi serta simulasi harga. Simulasi harga adalah skenario asumsi, bukan prediksi permintaan. MVP tidak membuat pembukuan pajak, stok gudang, pembayaran, iklan otomatis atau rekomendasi pembelian yang dijalankan sendiri.

### Sitemap

/login, /onboarding, /dashboard, /imports, /imports/[id], /products, /products/[id], /costs, /reports, /reports/[id], /insight dan /settings/team. Halaman publik portfolio hanya studi kasus yang disanitasi; workspace operasional membutuhkan autentikasi.

## Tahap 1 Definisi angka dan basis periode

### Definisi yang wajib konsisten

| Metrik | Aturan |
| --- | --- |
| Penjualan bruto produk | Nilai item sebelum diskon penjual dan refund; tidak mencampur dana ongkir titipan. |
| Pendapatan produk neto | Bruto dikurangi diskon penjual dan refund penjualan, ditambah subsidi yang benar-benar menjadi hak penjual dan belum tercatat. |
| Margin kontribusi | Pendapatan neto dikurangi biaya platform, HPP terpakai, kemasan dan ongkir yang ditanggung penjual. |
| Setelah iklan | Margin kontribusi dikurangi biaya iklan yang dialokasikan; tandai biaya belum teralokasi. |
| Hasil setelah biaya tercatat | Pendapatan neto dikurangi seluruh biaya tercatat pada tingkat toko; bukan otomatis laba bersih akuntansi. |
| Persentase margin | Kontribusi dibagi pendapatan neto dikali 100; jika penyebut nol/tidak positif, tampilkan tidak berlaku. |

### Basis tanggal

Gunakan basis kejadian penjualan selesai untuk laporan margin MVP. Pesanan batal atau belum selesai tidak menjadi penjualan; biaya yang benar-benar dikenakan tetap diakui pada tanggal kejadiannya. Refund diakui pada tanggal kejadian refund, dengan referensi transaksi asal. Dana dicairkan dan saldo marketplace merupakan rekonsiliasi kas terpisah; jangan menjumlahkan payout dengan penjualan sebagai pendapatan ganda.

### Uang dan pembulatan

Simpan IDR sebagai numeric integer rupiah, bukan floating point. Quantity retail berupa integer; produk berbasis berat/pecahan ditunda sampai kontraknya ditetapkan. Alokasi diskon/biaya per pesanan menggunakan proporsi nilai item yang relevan, metode largest remainder dan tie-break ID stabil. Jumlah hasil alokasi wajib sama dengan sumber sampai rupiah terakhir.

### Biaya dan retur

HPP memakai biaya efektif saat penjualan dengan snapshot cost rate. Mengubah modal terbaru tidak mengubah histori tanpa proses hitung ulang eksplisit. Refund mengurangi pendapatan; pengembalian HPP hanya dilakukan jika barang benar-benar kembali layak jual dan telah dikonfirmasi. Barang rusak/hilang tidak otomatis mengembalikan HPP.

## Tahap 1 Kelengkapan dan alur impor

### Status kualitas data

Laporan dibedakan menjadi Belum Lengkap, Siap Ditinjau dan Dikonfirmasi Pemilik. Konfirmasi hanya tersedia saat error pemblokir selesai, pemetaan sumber jelas, serta owner menegaskan biaya yang relevan sudah dimasukkan. Status ini bukan sertifikasi kebenaran laporan keuangan.

| Kondisi | Aturan produk |
| --- | --- |
| Modal kosong | Tidak dianggap nol. Jumlah transaksi/pendapatan yang belum memiliki HPP ditampilkan. |
| Biaya bernilai nol | Bedakan nol yang dikonfirmasi dari field kosong atau tidak tersedia. |
| Iklan tanpa SKU | Masuk total biaya toko; laporan produk diberi catatan biaya belum dialokasikan. |
| Biaya teralokasi | Total toko memakai biaya asal sekali; alokasi hanya untuk analisis produk. |
| Selisih rekonsiliasi | Penyesuaian tak terpetakan tetap terlihat dan memblokir status terkonfirmasi. |
| Laporan tumpang tindih | Deduplikasi per event bisnis, bukan hanya file hash. |
| Format tidak dikenal | Tolak atau minta mapping; jangan menebak kolom uang secara diam-diam. |

### Tahap impor

Validasi tipe/ukuran file > parse tanpa menjalankan formula > pilih kolom yang diizinkan > buang data pembeli yang tidak diperlukan > simpan baris bersih di staging > normalisasi tanggal/angka > periksa SKU dan event key > tampilkan preview > commit dalam transaksi. Data staging belum memengaruhi laporan. Batch failed yang diunggah ulang dikenali sebagai batch yang sama dan dapat diproses ulang secara terkendali, bukan membuat duplikat. Event key sama dengan payload hash berbeda harus ditandai konflik untuk koreksi eksplisit.

### Format awal yang didukung

Template LabaRapi memuat source_event_id, event_kind, occurred_on, sku, quantity, amount_idr, order_reference dan line_reference. Setiap amount menyatakan dampak ekonomi dengan tanda yang terdokumentasi. Template dan contoh XLSX memakai nilai literal, bukan formula. Adapter Shopee memerlukan contoh file legal yang disanitasi, dokumentasi mapping serta fixture validasi sebelum diberi label didukung.

File identik dikenali melalui SHA 256. Source event key harus stabil terhadap pergantian nama dan urutan file; bila sumber tidak menyediakan identitas yang cukup, tampilkan kemungkinan duplikat untuk tinjauan. Jangan menolak transaksi sah hanya karena nominal dan tanggalnya sama.

## Tahap 1 Edge cases dan non functional requirements

| Skenario | Respons yang diwajibkan |
| --- | --- |
| Koneksi putus/klik ganda | Request ID dan hash payload; cari status sebelum retry; tidak ada commit parsial. |
| Impor salah toko | Tampilkan toko tujuan sebelum commit; rollback berupa reversal tercatat, bukan hapus ledger. |
| Retur sebagian | Gunakan item/quantity dan referensi sumber; jangan membalik seluruh pesanan. |
| Biaya/kurs asing | MVP IDR saja; mata uang lain ditolak, bukan dikonversi diam-diam. |
| Periode kosong/negatif | Tampilkan empty state atau kerugian sesuai data; jangan memaksakan insight positif. |
| Dua editor bersamaan | Version check menolak overwrite; data baru dimuat ulang dengan draft yang dijaga. |
| AI timeout atau kuota | Laporan numerik tetap bekerja; tampilkan AI belum tersedia dan jalur retry terkontrol. |
| Unggahan berbahaya | Tolak macro, formula aktif, file terenkripsi dan archive bomb; simpan error tanpa data pribadi. |

### Standar awal

Asumsi beban pilot: sampai 10 pengguna aktif serentak, file 10 MB, 20.000 baris per batch dan 100.000 event per toko. Angka ini target uji, bukan kemampuan terukur. Gunakan pagination 25–100 item dan pemrosesan batch server. Target p95 baca laporan 2 detik, proses batch 60 detik pada dataset uji; catat lingkungan dan sesuaikan sebelum rilis.

### Aksesibilitas dan SEO

UI mobile 360–1440 px, keyboard, fokus terlihat, label form, status berteks, reduced motion dan tabel/chart dengan ringkasan angka. Target kontras teks 4,5 banding 1. Workspace privat noindex; halaman publik memiliki metadata tanpa bocoran data toko.

### Keandalan

Target pemulihan usulan RPO 24 jam dan RTO 8 jam hanya setelah backup serta restore diuji pada paket layanan yang dipilih. Simpan audit perubahan tanpa isi data pribadi. Tetapkan retensi staging dan laporan bersama owner sebelum produksi.

## Tahap 2 Arsitektur teknis

| Lapisan | Pilihan dan alasan |
| --- | --- |
| Frontend | Next.js App Router, React, TypeScript strict; mengikuti teknologi proyek dan mendukung aplikasi privat. |
| UI | CSS Modules, token desain dan satu library chart terpilih bila diperlukan; tidak menambah UI framework bertumpuk. |
| Backend | Route Handlers untuk validasi/otorisasi; worker proses impor untuk pekerjaan yang melebihi batas request host. |
| Database dan auth | PostgreSQL/Supabase Auth, RLS, transaksi dan indeks; akun undangan untuk pilot. |
| Impor | Parser CSV/XLSX server yang dipilih setelah evaluasi keamanan, lisensi dan fixture format. |
| AI | OpenAI Responses API melalui server; model terkonfigurasi dan dipilih setelah evaluasi kualitas/biaya. |
| Hosting | Runtime Next.js dan worker terkelola; database privat terotorisasi. Static export agency tetap terpisah. |

### Alur sumber kebenaran

File > staging bersih > validasi/mapping > commit ledger > engine deterministik > snapshot laporan > konteks AI terkurasi > jawaban dengan referensi. AI tidak mengubah ledger, mapping, biaya atau harga. Semua perubahan uang terjadi melalui jalur server yang tervalidasi dan diaudit.

### State caching dan pekerjaan latar

Database merupakan sumber kebenaran; browser menyimpan filter dan draft saja. Setiap mutasi keuangan menaikkan data_version toko secara atomik. Snapshot dibedakan melalui store, versi data, rentang tanggal dan calculation_version. Cache jawaban AI memakai fingerprint snapshot, pertanyaan, prompt dan model; jangan dipakai lintas toko.

Batch memiliki status validating, review, committing, committed, failed atau reversed. Worker memakai claim/lease, timeout dan retry idempotent; crash sebelum commit tidak mengubah laporan. Tidak memakai proses fire-and-forget di serverless yang dapat berhenti setelah response.

## Tahap 2 Rancangan AI dan batas data

### Dua fitur AI pada MVP

Ringkasan periode menjelaskan hasil serta perubahan yang didukung data. Tanya laporan menjawab pertanyaan tentang toko, produk dan periode yang dipilih. Pertanyaan dibatasi 500 karakter dan disanitasi sebelum disimpan/dikirim. Jika pertanyaan belum jelas, minta periode atau produk; jika data kurang, sebutkan bagian yang belum tersedia.

### Grounding dan verifikasi

Server menentukan store dari session dan mengambil snapshot serta snapshot pembanding yang diizinkan. Konteks berisi agregat, SKU alias, definisi metrik dan fact ID. Model mengembalikan structured output dengan answer, evidence_ids dan limitations. Server memeriksa schema, setiap fact ID dan klaim angka sebelum menampilkan; keluaran yang tidak didukung diganti penjelasan deterministik. Struktur JSON tidak menjamin isi benar, sehingga evaluasi grounding tetap wajib.

### Batas kemampuan

- AI tidak menghitung uang sebagai sumber hasil; angka berasal dari engine dan ditampilkan dengan tautan sumber.
- AI tidak memiliki tool tulis, SQL bebas, akses web, atau aksi mengubah harga/iklan.
- Isi file dan nama produk diperlakukan sebagai data, bukan instruksi; uji prompt injection.
- Jika korelasi terlihat, jangan menyebutnya sebab pasti atau menjanjikan keuntungan.

### Privasi dan biaya

Kirim agregat minimum, bukan file mentah, kontak pembeli, alamat, nomor telepon atau kredensial. Owner mengaktifkan fitur setelah mengetahui data yang dikirim. Gunakan store=false bila didukung; pengaturan ini bukan jaminan zero retention dan kebijakan provider tetap diperiksa. Batas konteks, output, kuota per toko serta anggaran harian diatur server. Model belum ditetapkan agar tidak mengunci pilihan sebelum evaluasi.

### Kegagalan dan pengujian

Tangani penolakan model, output terpotong, schema salah, referensi tidak sah, timeout dan limit provider. Hindari retry otomatis jika hasil request sebelumnya tidak pasti dan bisa menimbulkan biaya ganda. Set evaluasi mencakup biaya kosong, margin negatif, dua toko, periode berbeda, angka besar dan pertanyaan di luar laporan.

## Tahap 2 Struktur folder keamanan dan konfigurasi

```text
labarapi/
  app/(auth)/                 Login dan undangan
  app/(workspace)/            Dashboard impor biaya laporan AI
  app/api/v1/                 API terautentikasi
  components/                 Form tabel chart dan evidence
  lib/auth/                   Session membership dan role
  lib/imports/                Parser mapping dan deduplikasi
  lib/accounting/             Engine uang alokasi dan versi
  lib/ai/                     Konteks schema guard dan kuota
  workers/                    Pemrosesan batch impor
  supabase/migrations/        DDL RLS dan fungsi transaksi
  tests/fixtures/             File yang disanitasi dan golden cases
  docs/                       Blueprint runbook dan keputusan
```

| Environment | Sifat dan penggunaan |
| --- | --- |
| NEXT_PUBLIC_SUPABASE_URL | Publik; URL proyek. |
| NEXT_PUBLIC_SUPABASE_PUBLISHABLE_KEY | Publik terbatas; tetap memerlukan RLS. |
| SUPABASE_SECRET_KEY | Secret server untuk operasi auth administratif; bukan CRUD rutin. |
| DATABASE_URL | Secret migrasi/worker; role minimum dan konteks toko diverifikasi. |
| OPENAI_API_KEY dan OPENAI_MODEL | Secret API di server; model konfigurasi, bukan dari browser. |
| APP_URL dan WORKER_QUEUE_URL | Origin callback dan alamat antrean yang terkontrol. |
| AI_DAILY_BUDGET dan AI_REQUEST_LIMIT | Batas terukur server; angka ditetapkan owner sebelum pilot. |

Owner mengelola toko dan anggota; editor mengimpor/mengoreksi biaya; viewer hanya membaca laporan. Aktifkan RLS dan periksa membership di semua API, worker serta fungsi transaksi. Key istimewa tidak dikirim ke browser. Cabut akses anonim dan direct write tabel keuangan. Secrets berbeda antara development, staging dan produksi.

## Tahap 3 ERD dan model identitas impor

Relasi logis: auth.users menjadi anggota stores melalui store_members. Store memiliki products, cost_rates, import_batches, ledger_entries, report_snapshots dan ai_runs. Batch memiliki import_rows. Ledger mengacu pada batch, produk dan cost rate bila relevan; snapshot merangkum ledger pada versi tertentu. AI mengacu pada snapshot yang sama tokonya.

| Tabel | Kolom inti dan tipe | Kunci dan aturan |
| --- | --- | --- |
| stores | id uuid; name text; data_version bigint; created_at timestamptz. | PK id; versi naik setiap perubahan yang memengaruhi laporan. IDR/Jakarta aturan MVP. |
| store_members | store_id uuid; user_id uuid; role text; active boolean. | PK store_id dan user_id; FK stores dan auth.users. Role owner/editor/viewer. |
| products | id uuid; store_id uuid; sku text; name text; active boolean. | PK id; unique store_id,id dan store_id,sku. SKU canonical hasil mapping. |
| cost_rates | id uuid; store_id uuid; product_id uuid; effective_on date; unit_cost_idr numeric(20,0). | FK produk dalam store yang sama; unique produk dan tanggal; biaya tidak negatif. |
| import_batches | id uuid; store_id uuid; file_hash char(64); adapter_version text; status text; created_by uuid; request_id uuid; created_at timestamptz. | FK store/auth; unique toko dan file hash; metadata sumber tanpa file mentah. |
| import_rows | id uuid; store_id uuid; batch_id uuid; row_no integer; product_id uuid nullable; clean_data jsonb; issues jsonb. | FK batch/produk sama toko; unique batch dan nomor baris; field data hanya allowlist. |

### Data pribadi dan staging

File mentah diproses sementara dengan batas resource dan tidak disimpan permanen. clean_data hanya mempertahankan kolom bisnis yang diperlukan, tanpa nama/kontak/alamat pembeli. Preview dan error tidak menggemakan kolom sensitif. Batalkan impor yang belum dipublikasikan melalui status dan cleanup staging; histori commit tetap utuh.

### Tenant integrity

Semua relasi antar entitas bisnis memakai foreign key gabungan store_id dan id, bukan sekadar percaya store_id dari browser. Role owner/editor diverifikasi dari session. Undangan, pencabutan akses dan perubahan role menjadi audit event; owner terakhir tidak boleh dinonaktifkan.

## Tahap 3 Ledger snapshot dan audit

| Tabel | Kolom inti dan tipe | Aturan |
| --- | --- | --- |
| ledger_entries | id uuid; store_id uuid; batch_id/product_id/cost_rate_id uuid nullable; event_key text; payload_hash char(64); kind text; amount_idr numeric(20,0); occurred_on date; quantity integer nullable; reverses_id uuid nullable; source_refs jsonb. | Event immutable. Unique toko,event_key; FK gabungan satu toko. amount bertanda; reversal menunjuk event asal. |
| report_snapshots | id uuid; store_id uuid; data_version bigint; calculation_version text; start_on/end_on date; metrics jsonb; coverage jsonb; confirmed_by uuid nullable; confirmed_at timestamptz nullable. | Unique toko,versi,rentang,rule. Angka JSON berupa string integer; konfirmasi hanya untuk snapshot terkini. |
| ai_runs | id uuid; store_id uuid; snapshot_id uuid; comparison_id uuid nullable; user_id uuid; request_id uuid; status text; model/prompt_version text; context_hash char(64); question text; answer jsonb; usage jsonb. | FK snapshot/pembanding sama toko; request ID unik per toko/user; payload sudah disanitasi. |
| audit_events | id bigint; store_id uuid; actor_id uuid; action text; entity_ref text; created_at timestamptz. | Append only dari server; tidak menyimpan file atau kontak pembeli. |

### Aturan ledger

Penerimaan bernilai positif dan biaya/refund bernilai negatif. Jenis event: gross_sale, seller_discount, refund, subsidy, platform_fee, cogs, packing, shipping, ad_cost, operating_cost dan unmapped. Reversal penuh bernilai kebalikan event asal, punya ID baru dan tidak menghapus histori. Refund sebagian adalah event tersendiri dengan referensi item, bukan reversal penuh pesanan.

### Konsistensi hitung ulang

Commit memasukkan ledger serta menaikkan versi toko dalam satu transaksi. Koreksi menghasilkan reversal dan replacement yang diaudit. Source refs menunjuk batch, baris dan aturan asal, bukan data pembeli. Tidak mengubah ledger lama setelah biaya terbaru diedit; recalculation historis memerlukan preview dan konfirmasi owner.

### Indeks

Indeks ledger pada toko,tanggal,kind dan toko,produk,tanggal; staging pada batch,row_no; biaya pada produk,tanggal; snapshot pada toko,versi,rentang; AI pada toko,status,waktu. PK/unique sudah terindeks. Validasi rencana query dan dataset pilot sebelum menambah indeks lain.

## Tahap 3 Kontrak API

Base path /api/v1/stores/{storeId}. Semua endpoint memerlukan session valid dan membership aktif. JSON UTF-8; ID UUID berupa string; money dan versi bigint berupa string; timestamp UTC dan tanggal periode lokal Asia/Jakarta. Filter tanggal memakai awal inklusif dan akhir eksklusif.

| Route | Akses | Hasil dan aturan |
| --- | --- | --- |
| POST /imports | Owner/editor | 202 batch; multipart CSV/XLSX; request_id; parser allowlist dan batas ukuran. |
| GET /imports/{id} | Anggota | 200 preview/status/issues dengan pagination; tidak membocorkan raw file. |
| PUT /imports/{id}/mapping | Owner/editor | 200 mapping kategori/SKU dengan expected_version; hanya sebelum commit. |
| POST /imports/{id}/commit | Owner/editor | 202 atau 200; worker idempotent; hasil final ditelusuri melalui batch. |
| DELETE /imports/{id} | Owner/editor | 204 cancel staging; batch committed ditolak 409. |
| POST /imports/{id}/reverse | Owner | 200 reversal terotorisasi dengan alasan dan expected_version. |
| GET dan POST /products | Anggota; tulis editor | Daftar atau 201 produk; SKU canonical unik per toko. |
| POST /products/{id}/cost-rates | Owner/editor | 201 biaya efektif tanggal; tidak menimpa histori diam-diam. |
| POST /expenses | Owner/editor | 201 event biaya manual; request_id dan aturan alokasi eksplisit. |
| POST dan GET /reports | Anggota | Buat snapshot deterministik atau daftar; snapshot sesuai versi data. |
| POST /reports/{id}/confirm | Owner | 200 attest kelengkapan; blokir jika stale atau error diketahui. |
| POST /insights; GET /insights/{id} | Anggota dengan AI aktif | 202 job/200 cache dan hasil evidence; quota serta akses diperiksa. |

Mutasi tidak boleh mengandalkan larangan UI. Server menetapkan actor dan menghitung hash payload; retry request ID sama/payload sama mengembalikan hasil, payload berbeda 409. Perubahan ledger dan audit atomik. Pagination default 25 maksimal 100, limit dataset dibatasi server.

## Tahap 3 Payload validasi dan error

### Contoh biaya manual

```json
POST /api/v1/stores/{id}/expenses
{
  "request_id": "uuid-client",
  "expected_data_version": "8",
  "kind": "ad_cost",
  "occurred_on": "2026-10-01",
  "amount_idr": "150000",
  "product_id": null,
  "allocation": "unallocated",
  "note": "Biaya iklan yang belum dipetakan ke produk"
}
```

Input biaya menggunakan nominal positif; server mengubahnya menjadi dampak ledger negatif. Jangan mencampur kontrak input ini dengan signed amount pada template ledger. Nominal integer dan rentang divalidasi, currency hanya IDR, tanggal valid, serta product_id harus berasal dari toko yang sama.

### Permintaan AI

```json
POST /api/v1/stores/{id}/insights
{
  "request_id": "uuid-client",
  "snapshot_id": "uuid-snapshot",
  "comparison_id": null,
  "question": "Produk mana yang margin kontribusinya terkecil?"
}
202 {"data":{"id":"uuid-job","status":"pending"}}
200 {"data":{"answer":"...","evidence_ids":["fact-1"],
"limitations":["Biaya iklan belum teralokasi"]}}
```

### Kontrak error

Gunakan error.code, message, fields opsional dan request_id server. 400 JSON/query rusak; 401 session tidak valid; 403 hak akses; 404 resource tidak tersedia; 409 versi/duplikasi konflik; 413 file terlalu besar; 415 tipe tidak didukung; 422 isi data tidak valid; 429 limit; 500 internal; 503 provider/database gagal. Jangan mengirim stack trace, data pembeli atau credentials.

Buat/import/simpan biaya/AI memiliki loading dan error nyata. Setelah timeout, jangan menampilkan sukses lokal; muat status request. Report detail menyertakan data_version, calculation_version, periode, metrics, coverage serta source refs yang dapat diakses pengguna.

## Tahap 4 Design system dan UI

Arah visual: dashboard editorial yang rapi, hangat dan berkarakter. Gunakan keluarga warna VELKIRA dari app/globals.css, dengan sidebar forest dan area kerja chalk yang terang agar angka mudah dibaca. Identitas agency tetap terasa, sementara kepadatan informasi disesuaikan dengan aplikasi analisis. Tabel sumber dan kelengkapan data sama pentingnya dengan grafik.

| Token | HEX | Pemakaian |
| --- | --- | --- |
| Forest dan panel | 101B1A / 192925 | Sidebar, tombol utama dan identitas VELKIRA. |
| Lime | D9F27E | Aksen pilihan aktif; teks forest, bukan putih. |
| Chalk dan surface | F3F5EE / FFFFFF | Kanvas area kerja dan panel data. |
| Text dan muted | 101B1A / 52655C | Teks utama dan sekunder pada area terang. |
| Mist dan sage | A8CAD6 / A6B8AE | Grafik pembanding dan teks sidebar. |
| Border | D7E1DE | Pemisah; input memerlukan batas kontras memadai. |
| Success | 166534 / DCFCE7 | Impor selesai atau data terkonfirmasi. |
| Warning | 92400E / FEF3C7 | Biaya belum lengkap atau snapshot stale. |
| Error | B42318 / FEE4E2 | Validasi, kegagalan dan nilai negatif berlabel. |

### Tipografi spacing dan komponen

Heading Manrope 28–36 px; body Inter 14–16 px dengan fallback Arial, mengikuti keluarga font agency. Label 12–13 px; angka tabular dan format rupiah konsisten. Simpan font berlisensi lokal. Skala jarak 4/8/12/16/24/32 px, panel radius 12 px dan tombol 8 px; bayangan hanya pada overlay.

Reusable UI: nav, button, input uang/tanggal, uploader, mapping table, error summary, status kualitas, metric card, chart dengan tabel alternatif, source drawer, confirmation dialog dan AI evidence card. Masing-masing memiliki default, focus, hover, disabled, loading, empty dan error sesuai kebutuhan nyata; bukan state tambahan yang tidak dipakai.

### Layout

Desktop: sidebar 224 px, pemilih periode/toko, indikator kelengkapan, metrik dan tabel produk. Konten memakai grid 12 kolom dengan gap 24 px dan padding 32 px. Mobile memakai padding 16 px, navigasi ringkas dan scroll lokal pada tabel. Data belum lengkap terlihat sebelum ringkasan AI. Panel tidak semuanya dibungkus kartu.

## Tahap 4 Rincian halaman dan pengalaman

| Halaman | Komponen dan perilaku utama |
| --- | --- |
| Onboarding | Toko, timezone/currency terkunci MVP, undangan tim dan penjelasan data minimum. |
| Dashboard | Periode, completeness, sumber terakhir, hasil toko dan produk; nol hanya jika query berhasil. |
| Impor | Upload, tipe sumber, mapping, preview bersih, error per baris, duplikasi dan commit. |
| Produk dan modal | SKU, alias sumber terkonfirmasi, biaya efektif, coverage HPP dan histori. |
| Biaya | Nominal, jenis, tanggal, alokasi, alasan koreksi dan total belum teralokasi. |
| Laporan | Snapshot versi, rumus, tabel produk, pembanding, source refs dan status stale. |
| Asisten Insight | Pertanyaan periode/produk, jawaban grounded, limitations, evidence links dan kuota. |
| Settings | Anggota, role, akses AI, retensi dan pengaturan biaya yang benar-benar tersedia. |

### Aturan interaksi

Jangan langsung memublikasikan hasil setelah unggah; pengguna harus melihat preview dan konfirmasi. Tampilkan perbedaan sebelum koreksi dan alasan yang diwajibkan. Dialog pembalikan batch menyebut toko, periode dan jumlah event terdampak. Simpan draft selama layar terbuka; jangan menaruh data finansial mentah di localStorage tanpa kebijakan yang disepakati.

### Empty error dan freshness

Data kosong menawarkan impor/template, bukan grafik contoh di workspace produksi. Query gagal berbeda dari nol. Snapshot lama tetap bisa dibuka dengan label versi dan tanggal; action konfirmasi dinonaktifkan jika data_version sudah berubah. AI selalu menyebut periode dan keterbatasan yang relevan.

### Bahasa produk

Gunakan istilah modal, biaya, margin kontribusi dan hasil setelah biaya tercatat. Hindari kata keuntungan pasti, prediksi pasti atau laba bersih bila tidak didukung. Penjelasan AI dapat dikoreksi/dilaporkan tanpa mengubah angka engine.

## Tahap 4 Komposisi visual yang menjadi ciri produk

### Tampilan awal dashboard

Pada desktop 1440 px, sidebar forest memuat wordmark LabaRapi, toko aktif, navigasi dan tautan Kembali ke VELKIRA. Area chalk dibuka dengan judul Ringkasan toko, periode, waktu impor terakhir dan tombol Impor laporan. Satu baris status kelengkapan berada langsung di bawah judul, bukan disembunyikan pada tooltip.

Angka margin kontribusi menjadi fokus pada bidang terbuka, dengan label dan keterangan biaya yang tercakup. Dua metrik pendamping berukuran lebih kecil menampilkan pendapatan neto dan biaya tercatat. Ini membentuk hierarki yang jelas tanpa deretan kartu identik. Semua nominal berasal dari data toko; rancangan visual memakai fixture yang diberi label sebagai bahan desain.

| Area | Komposisi desktop | Perilaku mobile |
| --- | --- | --- |
| Analisis utama | Grafik batang kontribusi 8 kolom; daftar biaya belum lengkap 4 kolom. | Grafik lalu daftar biaya; label dan satuan tetap terlihat. |
| Produk | Tabel selebar konten: SKU, neto, HPP, biaya, kontribusi dan status. | SKU dan kontribusi diprioritaskan; detail terbuka saat baris dipilih. |
| Sumber angka | Drawer 420 px berisi rumus, batch, tanggal dan baris sumber. | Halaman detail penuh dengan tombol kembali dan posisi daftar terjaga. |
| Asisten | Tombol Jelaskan laporan membuka panel dengan periode dan referensi. | Panel penuh setelah pengguna meminta; status data tetap terlihat. |

### Ritme visual dan grafik

Gunakan judul rata kiri, angka rata kanan, garis pemisah tipis dan ruang kosong yang konsisten. Grafik memakai forest sebagai seri utama dan mist untuk pembanding; lime hanya menyorot pilihan pengguna. Nilai negatif memiliki tanda minus dan label. Sumbu, periode, unit serta tabel alternatif wajib ada. Grafik tanpa data menampilkan ajakan impor, bukan bentuk dekoratif.

### Halaman portofolio yang selaras

Kartu LabaRapi pada VELKIRA menampilkan cuplikan UI buatan sendiri, masalah yang diselesaikan dan tautan ke studi kasus atau aplikasi. Halaman studi kasus memakai header forest, tipografi agency dan satu visual produk besar. Tidak menyalin nuansa coffee shop SunDays ke tabel keuangan. Nama, logo marketplace dan bukti klien hanya digunakan bila sah serta benar.

## Tahap 4 Standar estetika dan penerimaan UI

### Aturan agar hasil terasa dirancang

- Pilih satu susunan utama yang mengikuti pekerjaan penjual: periode, kelengkapan, hasil, produk, lalu penjelasan. Jangan membangun halaman dari kumpulan komponen acak.
- Gunakan maksimal dua keluarga font, satu keluarga ikon garis dan satu skala radius. Ikon hanya membantu tindakan yang memiliki label; hindari emoji dekoratif.
- Utamakan bidang warna solid, garis tipis dan tipografi. Hindari gradien ungu generik, glow, glassmorphism berulang, kartu melayang, grid bento tanpa tujuan dan ornamen sparkle AI.
- Gunakan bahasa Indonesia yang konkret: Impor laporan, Periksa modal, Lihat sumber dan Jelaskan laporan. Hindari slogan bombastis, testimoni palsu, skor AI serta persentase peningkatan tanpa bukti.
- AI menjadi alat bantu pada laporan, bukan pusat seluruh antarmuka. Jangan membuka chatbot otomatis atau menutupi tabel dengan ajakan berulang.
- Gerak 120–180 ms hanya untuk fokus, drawer dan transisi status. Hormati reduced motion; angka uang tidak dihitung naik sebagai animasi.

### Pemeriksaan visual sebelum coding final

Siapkan rancangan dashboard desktop 1440 px dan mobile 390 px, halaman impor, serta detail laporan terlebih dahulu. Gunakan dataset uji yang sama agar hierarki, panjang SKU, minus dan nominal besar dapat dibandingkan. Nilai hasil berdasarkan komposisi, keterbacaan, konsistensi dan keberhasilan menemukan sumber angka, bukan banyaknya efek.

| Pemeriksaan | Syarat lulus |
| --- | --- |
| Konsistensi | Token warna dan font selaras dengan VELKIRA; tidak ada warna atau radius ad hoc. |
| Responsif | Periksa 360, 390, 768, 1024 dan 1440 px; tidak ada scroll halaman horizontal. |
| Angka dan isi | Rp 1.234.567.890, nilai negatif, SKU panjang dan label dua baris tidak terpotong. |
| Aksesibilitas | Kontras teks target 4,5:1, fokus terlihat, keyboard berfungsi dan target sentuh 44 px. |
| Keadaan data | Kosong, gagal, belum lengkap, memuat dan kedaluwarsa memiliki tampilan yang jelas. |
| Kegunaan | Penguji dapat melihat biaya yang kurang dan membuka sumber tanpa bantuan. |

Status dokumen ini adalah spesifikasi visual. Kualitas UI akhir harus dibuktikan melalui rancangan layar, hasil browser dan pemeriksaan di perangkat; blueprint saja belum membuktikan tampilan aplikasi sudah bagus.

## Tahap 5 Aturan proyek dan tahap pengerjaan

### Project rules

- Baca blueprint dan panduan versi framework/SDK sebelum coding; gunakan TypeScript strict.
- Uang dihitung server dengan integer/decimal yang tepat; AI tidak menjadi mesin hitung.
- Parser tidak menjalankan formula; tidak menyimpan data pembeli yang tidak diperlukan.
- Setiap mutation keuangan memerlukan membership, idempotency, transaksi dan audit.
- FK serta kebijakan akses harus mencegah data lintas toko, termasuk worker dan AI.
- Data kosong, belum lengkap, gagal dimuat dan nol tidak boleh disamakan.
- Perubahan histori memakai koreksi eksplisit; jangan menimpa atau menghapus ledger.
- Tidak menambah API marketplace, model, billing atau fitur di luar MVP tanpa keputusan tertulis.

### Checklist implementasi berurutan

- [ ] **01** — Validasi calon pengguna, contoh laporan sah, definisi metrik dan batas MVP.; Pemilik
- [ ] **02** — Fixture CSV/XLSX, mapping versi dan golden dataset; belum perlu UI lengkap.; 01
- [ ] **03** — Proyek server, staging, auth, stores/membership, secrets dan RLS.; 01
- [ ] **04** — Migrasi, transaksi, deduplikasi, audit dan tes lintas toko.; 02 dan 03
- [ ] **05** — Engine uang, retur, biaya efektif, alokasi, coverage dan snapshot.; 04
- [ ] **06** — Parser dan worker; preview error/duplicate; commit/reversal atomik.; 04 dan 05
- [ ] **07** — Produk, biaya, laporan, source refs dan status kualitas pada UI responsif.; 05 dan 06
- [ ] **08** — AI summary/Q&A dengan context minimum, evidence, quota dan evaluasi.; 07

Tahap 01 menutup ketidakjelasan format sumber. Adapter Shopee hanya dikerjakan setelah contoh dan fixture tersedia. Jika belum tersedia, kerjakan template standar dan engine terlebih dahulu; jangan menandai dukungan marketplace otomatis sebagai selesai.

## Tahap 5 QA rilis dan kriteria selesai

- [ ] **09  QA finansial** — Golden cases semua tepat rupiah; total alokasi sama sumber; payout tidak dihitung dua kali.
- [ ] **10  QA impor** — File identik, urutan berbeda, overlap, partial failure, retry dan worker crash tidak menggandakan ledger.
- [ ] **11  QA akses dan AI** — Tes IDOR/RLS dua toko, role, upload berbahaya, formula injection, prompt injection, evidence dan limit.
- [ ] **12  QA UI** — Lulus standar visual Tahap 4, ukuran 360–1440 px, keyboard, angka panjang dan seluruh keadaan data.
- [ ] **13  UAT dan evaluasi** — Pilot memakai data yang diizinkan; peserta memahami perbedaan margin dan laba bersih.
- [ ] **14  Rilis** — Backup/restore, monitor, domain/HTTPS, secrets, kuota provider dan rollback diuji.
- [ ] **15  Handover** — Runbook impor/koreksi/restore, data retention, pengelola dan hasil pengujian diserahkan.

### Definition of done

MVP selesai setelah pengguna dapat menyimpan data nyata dengan aman, mengimpor format yang dinyatakan didukung, menelusuri hasil ke sumber dan mengoreksi tanpa kehilangan histori. Perhitungan serta duplikasi harus lulus fixture. AI harus gagal dengan aman tanpa merusak laporan. Tidak ada temuan kritis akses atau uang yang belum ditangani.

### Rilis dan pemeliharaan

Pisahkan development, staging dan produksi. Pantau error, durasi batch, backlog worker, konflik/duplikasi, kuota AI dan backup tanpa log isi file sensitif. Deploy dari commit teruji. Rollback aplikasi tidak menghapus transaksi; recovery database mengikuti runbook. Verifikasi metadata publik dan noindex area kerja.

### Keputusan komersial

Belum ada harga langganan, jaminan permintaan pasar atau model AI final. Anggaran hosting, database, antrean, email dan AI disusun setelah pilot. Nama LabaRapi tetap nama kerja sampai pemeriksaan merek/domain. Peluncuran komersial memerlukan kesiapan layanan dan bukti penggunaan, bukan sekadar tampilan selesai.

## Lampiran A SQL identitas dan impor

DDL struktur PostgreSQL. Belum merupakan migrasi produksi lengkap: policies, grant dan fungsi transaksi wajib ditulis serta diuji sebelum akses dibuka. Field waktu memakai timestamptz dan tanggal periode memakai date.

```sql
CREATE TABLE stores (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 name text NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 160),
 data_version bigint NOT NULL DEFAULT 0 CHECK (data_version>=0),
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE TABLE store_members (
 store_id uuid REFERENCES stores(id),
 user_id uuid REFERENCES auth.users(id),
 role text NOT NULL CHECK (role IN ('owner','editor','viewer')),
 active boolean NOT NULL DEFAULT true,
 PRIMARY KEY(store_id,user_id)
);
CREATE TABLE products (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 store_id uuid NOT NULL REFERENCES stores(id),
 sku text NOT NULL CHECK (length(trim(sku)) BETWEEN 1 AND 100),
 name text NOT NULL CHECK (length(trim(name)) BETWEEN 1 AND 200),
 active boolean NOT NULL DEFAULT true,
 UNIQUE(store_id,id), UNIQUE(store_id,sku)
);
CREATE TABLE import_batches (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 store_id uuid NOT NULL REFERENCES stores(id),
 file_hash char(64) NOT NULL, adapter_version text NOT NULL,
 status text NOT NULL CHECK (status IN ('validating','review',
   'committing','committed','failed','reversed')),
 created_by uuid NOT NULL REFERENCES auth.users(id),
 request_id uuid NOT NULL, version integer NOT NULL DEFAULT 1,
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(store_id,id), UNIQUE(store_id,file_hash),
 UNIQUE(store_id,created_by,request_id)
);
CREATE TABLE import_rows (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 store_id uuid NOT NULL, batch_id uuid NOT NULL,
 row_no integer NOT NULL CHECK (row_no>0), product_id uuid,
 clean_data jsonb NOT NULL, issues jsonb NOT NULL DEFAULT '[]',
 FOREIGN KEY(store_id,batch_id) REFERENCES import_batches(store_id,id),
 FOREIGN KEY(store_id,product_id) REFERENCES products(store_id,id),
 UNIQUE(batch_id,row_no)
);
```

Raw file tidak disimpan dalam tabel. clean_data merupakan payload terstruktur allowlist; JSONB bukan alasan untuk menyimpan seluruh kolom mentah. Membuat toko dan owner pertamanya harus atomik serta diotorisasi server.

## Lampiran B SQL biaya dan ledger

```sql
CREATE TABLE cost_rates (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 store_id uuid NOT NULL, product_id uuid NOT NULL,
 effective_on date NOT NULL,
 unit_cost_idr numeric(20,0) NOT NULL CHECK (unit_cost_idr>=0),
 created_by uuid NOT NULL REFERENCES auth.users(id),
 FOREIGN KEY(store_id,product_id) REFERENCES products(store_id,id),
 UNIQUE(store_id,id), UNIQUE(store_id,product_id,effective_on)
);
CREATE TABLE ledger_entries (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 store_id uuid NOT NULL REFERENCES stores(id),
 batch_id uuid, product_id uuid, cost_rate_id uuid,
 event_key text NOT NULL, payload_hash char(64) NOT NULL,
 kind text NOT NULL CHECK (kind IN ('gross_sale','seller_discount',
  'refund','subsidy','platform_fee','cogs','packing','shipping',
  'ad_cost','operating_cost','unmapped')),
 amount_idr numeric(20,0) NOT NULL CHECK (amount_idr<>0),
 occurred_on date NOT NULL,
 quantity integer CHECK (quantity>=0),
 reverses_id uuid,
 source_refs jsonb NOT NULL,
 created_by uuid NOT NULL REFERENCES auth.users(id),
 created_at timestamptz NOT NULL DEFAULT now(),
 UNIQUE(store_id,id), UNIQUE(store_id,event_key),
 UNIQUE(store_id,reverses_id),
 CHECK (reverses_id IS NULL OR reverses_id<>id),
 FOREIGN KEY(store_id,batch_id) REFERENCES import_batches(store_id,id),
 FOREIGN KEY(store_id,product_id) REFERENCES products(store_id,id),
 FOREIGN KEY(store_id,cost_rate_id) REFERENCES cost_rates(store_id,id),
 FOREIGN KEY(store_id,reverses_id) REFERENCES ledger_entries(store_id,id)
);
CREATE INDEX ledger_period ON ledger_entries(store_id,occurred_on,kind);
CREATE INDEX ledger_product ON ledger_entries(store_id,product_id,occurred_on);
CREATE INDEX import_queue ON import_batches(status,created_at);
```

### Invarian yang harus ditegakkan transaksi

Tidak boleh ada UPDATE/DELETE langsung ke ledger. Reversal harus menunjuk event toko sama dan memiliki nominal tepat berlawanan; satu event hanya dapat dibalik penuh sekali. Biaya/HPP harus cocok dengan produk pada cost_rate yang dipakai. Source event key stabil dan payload hash diperiksa sebelum replay. Kehadiran constraint saja belum menjamin invarian lintas tabel ini.

Komponen bernilai nol tidak membutuhkan ledger event, tetapi konfirmasi nol tetap disimpan di staging/coverage. Transaksi gratis dapat memiliki gross sale nol yang tidak dicatat dan HPP tetap bernilai biaya. Perubahan biaya historis menghasilkan koreksi baru, bukan edit event lama.

## Lampiran C SQL snapshot AI dan audit

```sql
CREATE TABLE report_snapshots (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 store_id uuid NOT NULL REFERENCES stores(id),
 data_version bigint NOT NULL,
 calculation_version text NOT NULL,
 start_on date NOT NULL, end_on date NOT NULL,
 metrics jsonb NOT NULL, coverage jsonb NOT NULL,
 confirmed_by uuid REFERENCES auth.users(id), confirmed_at timestamptz,
 created_at timestamptz NOT NULL DEFAULT now(),
 CHECK (end_on>start_on),
 CHECK ((confirmed_by IS NULL) = (confirmed_at IS NULL)),
 UNIQUE(store_id,id),
 UNIQUE(store_id,data_version,start_on,end_on,calculation_version)
);
CREATE TABLE ai_runs (
 id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
 store_id uuid NOT NULL, snapshot_id uuid NOT NULL, comparison_id uuid,
 user_id uuid NOT NULL REFERENCES auth.users(id), request_id uuid NOT NULL,
 status text NOT NULL CHECK (status IN ('pending','done','failed')),
 model text NOT NULL, prompt_version text NOT NULL,
 context_hash char(64) NOT NULL,
 question text NOT NULL CHECK (length(question)<=500),
 answer jsonb, usage jsonb,
 created_at timestamptz NOT NULL DEFAULT now(),
 FOREIGN KEY(store_id,snapshot_id) REFERENCES report_snapshots(store_id,id),
 FOREIGN KEY(store_id,comparison_id) REFERENCES report_snapshots(store_id,id),
 UNIQUE(store_id,user_id,request_id)
);
CREATE TABLE audit_events (
 id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
 store_id uuid NOT NULL REFERENCES stores(id),
 actor_id uuid NOT NULL REFERENCES auth.users(id),
 action text NOT NULL, entity_ref text NOT NULL,
 created_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX ai_status ON ai_runs(store_id,status,created_at);
CREATE INDEX audit_history ON audit_events(store_id,created_at);
ALTER TABLE stores ENABLE ROW LEVEL SECURITY;
ALTER TABLE store_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE cost_rates ENABLE ROW LEVEL SECURITY;
ALTER TABLE import_batches ENABLE ROW LEVEL SECURITY;
ALTER TABLE import_rows ENABLE ROW LEVEL SECURITY;
ALTER TABLE ledger_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE report_snapshots ENABLE ROW LEVEL SECURITY;
ALTER TABLE ai_runs ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_events ENABLE ROW LEVEL SECURITY;
```

Policies harus membatasi setiap baris berdasarkan membership aktif. Viewer tidak dapat menulis; hanya owner mengubah tim/akses AI. Fungsi transaksi dan worker memakai otorisasi toko, bukan key istimewa tanpa pembatasan. RLS yang diaktifkan tanpa policies/grant teruji bukan implementasi akses yang selesai.

## Lampiran D Kasus referensi perhitungan

| Kasus uji | Input dan hasil yang diwajibkan |
| --- | --- |
| Transaksi dasar | Bruto 100.000; diskon penjual 10.000; biaya platform 5.000; HPP 50.000; kemasan 2.000. Neto 90.000, kontribusi 33.000, margin 36,6667 persen sebelum pembulatan tampilan. |
| Biaya iklan | Iklan 10.000 membuat hasil setelah iklan 23.000. Alokasi produk tidak mengurangi total toko untuk kedua kali. |
| Payout | Dana cair 85.000 pada contoh neto 90.000 dan fee 5.000 bukan penjualan tambahan. Selisih payout lain ditelusuri terpisah. |
| Biaya belum diketahui | HPP kosong menghasilkan label belum lengkap. Jangan menampilkan kontribusi 83.000 seolah HPP nol. |
| Retur sebagian | Dua unit, refund satu unit: kurangi pendapatan satu unit sesuai dokumen. HPP dikembalikan hanya setelah satu unit layak jual dikonfirmasi. |
| Pembulatan | Alokasikan 10.000 pada tiga item berbobot sama: 3.334, 3.333, 3.333 dengan tie-break stabil. |
| Pendapatan nol | Margin persen tidak berlaku; biaya tetap ditampilkan dan tidak dibagi nol. |
| Impor ulang | File sama atau laporan overlap tidak menambah event identik. Event berbeda bernominal sama tetap diterima. |

### Kualitas laporan dan AI

Uji snapshot sebelum dan sesudah koreksi; versi lama harus tetap dapat dijelaskan. Uji perubahan periode, tanggal refund, angka negatif, biaya tidak teralokasi dan data baru setelah AI selesai. Model tidak boleh menyatakan biaya kosong nol, mengubah persentase, atau mengacu pada fact ID toko lain.

### Kriteria tinjauan rumus

Pemilik produk dan penguji harus menyepakati fixture sebelum UI final. Untuk laporan komersial dengan kebutuhan akuntansi/pajak, tinjauan pihak kompeten diperlukan sesuai scope; LabaRapi tidak mengklaim laporan sebagai pengganti pembukuan resmi hanya karena hasil aritmetiknya tepat.

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

## Referensi hosting resmi

Diperiksa pada 30 Oktober 2026. Kemampuan layanan, ketentuan komersial, kuota dan label dashboard dapat berubah. Rancangan gabungan aplikasi, database serta worker di panduan ini merupakan keputusan proyek yang harus diuji, bukan konfigurasi yang sudah diterapkan pada akun pengguna.

Hostinger Node.js Web App
https://www.hostinger.com/support/how-to-deploy-a-nodejs-website-in-hostinger/

Cloudflare Pages static Next.js
https://developers.cloudflare.com/pages/framework-guides/nextjs/deploy-a-static-nextjs-site/

Cloudflare Pages Direct Upload
https://developers.cloudflare.com/pages/get-started/direct-upload/

Vercel custom domain
https://vercel.com/docs/domains/working-with-domains/add-a-domain

Vercel environment variables
https://vercel.com/docs/environment-variables

Supabase redirect URL
https://supabase.com/docs/guides/auth/redirect-urls

Render Background Worker
https://render.com/docs/background-workers

### Acuan lokal untuk website sebelumnya

README.md menjelaskan proses build dan batas static export. dokumen/10-hosting-gratis-cloudflare.md memuat langkah unggah agency dan SunDays. next.config.mjs mengonfirmasi output export, sedangkan package-site.ps1 hanya mengemas out. app/globals.css menjadi acuan keluarga warna VELKIRA. Pemeriksaan ini membaca source lokal, bukan dashboard hosting.

## Referensi keputusan dan lokasi file

### Referensi teknis resmi

Referensi diperiksa pada 30 Oktober 2026. Informasi provider dapat berubah; verifikasi versi SDK, kemampuan model, kuota dan retensi saat implementasi. Target produk serta aturan margin di dokumen merupakan keputusan rancangan, bukan jaminan provider.

Supabase Row Level Security
https://supabase.com/docs/guides/database/postgres/row-level-security

OpenAI Structured Outputs
https://developers.openai.com/api/docs/guides/structured-outputs

OpenAI Data Controls
https://developers.openai.com/api/docs/guides/your-data

OWASP File Upload Cheat Sheet
https://cheatsheetseries.owasp.org/cheatsheets/File_Upload_Cheat_Sheet.html

OWASP CSV Injection
https://community.owasp.org/attacks/CSV_Injection

### Kontrol unggahan dan ekspor

Batasi jenis, ukuran dan jumlah baris, periksa isi file dan gunakan parser yang tidak mengeksekusi formula. Untuk ekspor, gunakan tipe sel literal aman dan uji formula injection; memberi tanda kutip CSV saja tidak cukup. Laporan mentah tidak dikirim ke model AI.

### Keputusan yang masih perlu dikonfirmasi

Format contoh Shopee yang sah, SKU dan unit, komponen biaya sumber, kebijakan refund/restock, metode alokasi iklan, kelengkapan biaya, data retention, provider/model AI, anggaran, domain, pemeriksaan merek serta toko pilot. Pertanyaan ini tidak menghalangi penyusunan blueprint, tetapi menjadi syarat tahap implementasi terkait.

### File dan status

Simpan BLUEPRINT.md dan LabaRapi PRD dan Blueprint.docx di dokumen/labarapi dalam folder proyek. Markdown menjadi acuan kerja coding; Word menjadi dokumen tinjauan pemilik dan calon klien. Keduanya berasal dari isi yang sama. Tidak ada aplikasi, migrasi, akun provider, deployment atau bukti minat beli yang dibuat oleh dokumen ini.
