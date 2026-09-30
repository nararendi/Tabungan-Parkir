# 💳 EduVault • Tabungan Siswa & Retribusi Parkir

Aplikasi web modern untuk pengelolaan transaksi tabungan siswa dan retribusi parkir harian sekolah. Aplikasi ini sudah dilengkapi dengan antarmuka modern yang responsif, visualisasi grafik interaktif, ekspor/impor Excel, modul cetak buku tabungan resmi, serta **konektor database Supabase (PostgreSQL Cloud)**.

---

## 🚀 Fitur Unggulan

1. **Dashboard Eksekutif**:
   - 4 Kartu KPI Interaktif: Total Saldo Kas Tabungan, Total Siswa Terdaftar, Rekap Parkir Bersih, dan Mutasi Hari Ini.
   - Grafik Tren 7 Hari Terakhir (Setor vs Tarik) menggunakan Chart.js dengan aksen modern.
   - Tabel 5 aktivitas mutasi terkini.

2. **Pencatatan Transaksi Tabungan**:
   - Pencarian siswa cepat dengan auto-complete dan indikator saldo berjalan.
   - Toggle tombol Setor (+) dan Tarik (-) dinamis.
   - Validasi saldo (mencegah penarikan melebihi saldo).
   - Buku Induk Tabungan: Pengelompokan mutasi per siswa (accordion) yang bisa dibuka-tutup.
   - Format mata uang Rupiah otomatis (`Rp 50.000`).

3. **Pencatatan Rekap Parkir Harian**:
   - Formulir rekap harian: Pendapatan kotor, Beban pengeluaran operasional (cetak karcis, konsumsi), dan Hasil Bersih (Net).
   - Riwayat catatan parkir dengan paginasi dan aksi hapus.

4. **Kelola Data Master Siswa**:
   - Direktori siswa: NIS, Nama Siswa, Jenis Kelamin (L/P), Kelas, dan Nomor Plat Kendaraan.
   - Tambah, Edit, dan Hapus data siswa.
   - **Impor Excel (.xlsx)** dengan pratinjau data (modal preview) sebelum disimpan.
   - **Unduh Template Excel** untuk memudahkan pengisian data massal.

5. **Pusat Laporan Keuangan & Cetak Resmi**:
   - 3 Mode Laporan:
     1. Rekap Mutasi Tabungan Global (Semua Siswa).
     2. **Buku Tabungan Digital Siswa (Passbook Individu)** dengan saldo awal, mutasi debit/kredit, dan saldo akhir kumulatif.
     3. Rekapitulasi Parkir Harian (Pendapatan vs Pengeluaran).
   - Filter rentang tanggal & shortcut preset (Hari Ini, 7 Hari, Bulan Ini, Semua).
   - **Ekspor Excel (.xlsx)** menggunakan SheetJS.
   - **Cetak Laporan / Simpan PDF** dengan Kop Surat Resmi dan kolom tanda tangan Bendahara / Kepala Sekolah.

6. **Integrasi Supabase Cloud**:
   - Hub Pengaturan Supabase langsung dari UI aplikasi.
   - Uji koneksi instan (*Test Connection*).
   - Fitur **Migrasi 1-Klik** untuk mengunggah seluruh data lokal ke tabel Supabase.
   - Sinkronisasi dua arah real-time (*Supabase Realtime*).
   - Tetap berfungsi 100% secara offline / mode lokal jika Supabase belum dihubungkan.

---

## 🛠️ Cara Menjalankan Aplikasi

1. Buka file **`index.html`** langsung di browser Anda (Google Chrome, Microsoft Edge, Mozilla Firefox, dll).
2. Tidak memerlukan instalasi Node.js, `npm install`, atau kompilasi server yang rumit.
3. Login default:
   - **Admin**: Username: `admin` | Password: `admin123`
   - **Petugas**: Username: `petugas` | Password: `petugas123`

---

## ⚡ Panduan Menghubungkan ke Supabase (3 Langkah Mudah)

### Langkah 1: Siapkan Database di Supabase
1. Buka [Dashboard Supabase](https://supabase.com/dashboard) dan buat / buka project Anda.
2. Di bilah menu kiri, klik menu **SQL Editor**.
3. Buat query baru (**New Query**), buka file **`supabase_schema.sql`** yang ada di folder ini, salin seluruh kodenya, lalu klik tombol **RUN**.
4. Semua tabel (`students`, `savings_transactions`, `parking_logs`, `app_users`), relasi, index, dan kebijakan RLS akan dibuat secara otomatis.

### Langkah 2: Ambil URL & Anon Key
1. Di Dashboard Supabase, buka menu **Project Settings** (ikon gear di pojok kiri bawah) -> **API**.
2. Salin nilai:
   - **Project URL** (contoh: `https://xyzabcdef.supabase.co`)
   - **anon / public key** (kunci panjang yang diawali `eyJ...`)

### Langkah 3: Masukkan ke Aplikasi EduVault
1. Buka aplikasi **EduVault** di browser Anda.
2. Klik tombol **"Hubungkan Supabase"** di header atas atau menu **"Supabase Hub"** di sidebar.
3. Masukkan Project URL dan Anon Key Anda.
4. Klik **"Tes Koneksi"**, lalu klik **"Simpan & Hubungkan"**.
5. Jika Anda ingin mengunggah data demo lokal yang sudah ada ke Supabase, cukup klik tombol **"Migrasi ke Cloud"**.
6. Status indikator akan berubah menjadi hijau **🟢 Supabase Live**, dan aplikasi Anda sudah resmi berjalan dengan database cloud PostgreSQL!

---

## 📁 Struktur Berkas

- **`index.html`**: Aplikasi web utama (HTML5, Tailwind CSS, Lucide Icons, Chart.js, SheetJS, dan Supabase JS Client v2).
- **`supabase_schema.sql`**: Skrip SQL lengkap untuk inisialisasi tabel, indeks, keamanan RLS, dan data awal di Supabase.
- **`README.md`**: Dokumentasi panduan lengkap.
- **`index`**: Pengalih otomatis ke `index.html`.
