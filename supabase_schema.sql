-- ==============================================================================
-- TABUNGAN SISWA & RETRIBUSI PARKIR SEKOLAH (EDUNAULT)
-- SUPABASE POSTGRESQL DATABASE SCHEMA
-- ==============================================================================
-- CARA PENGGUNAAN:
-- 1. Buka Dashboard Supabase Anda (https://supabase.com/dashboard)
-- 2. Pilih project Anda, lalu buka menu "SQL Editor" di bilah navigasi kiri.
-- 3. Buat "New Query", salin seluruh isi file ini, lalu klik tombol "RUN".
-- 4. Semua tabel, relasi, index, kebijakan RLS, dan data awal akan langsung siap!
-- ==============================================================================

-- 1. TABEL PENGGUNA SISTEM (USERS & ADMIN)
CREATE TABLE IF NOT EXISTS public.app_users (
    id TEXT PRIMARY KEY DEFAULT ('usr_' || gen_random_uuid()::text),
    name TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT CHECK (role IN ('Admin', 'Petugas')) DEFAULT 'Petugas',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 2. TABEL DATA SISWA
CREATE TABLE IF NOT EXISTS public.students (
    id TEXT PRIMARY KEY DEFAULT ('std_' || gen_random_uuid()::text),
    nis TEXT UNIQUE NOT NULL,
    name TEXT NOT NULL,
    jk TEXT CHECK (jk IN ('L', 'P')) DEFAULT 'L',
    class TEXT NOT NULL,
    plat TEXT DEFAULT '',
    balance NUMERIC DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 3. TABEL TRANSAKSI TABUNGAN SISWA
CREATE TABLE IF NOT EXISTS public.savings_transactions (
    id TEXT PRIMARY KEY DEFAULT ('tx_' || gen_random_uuid()::text),
    student_nis TEXT NOT NULL REFERENCES public.students(nis) ON UPDATE CASCADE ON DELETE CASCADE,
    student_name TEXT NOT NULL,
    type TEXT CHECK (type IN ('SETOR', 'TARIK')) NOT NULL,
    amount NUMERIC NOT NULL CHECK (amount > 0),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    note TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- 4. TABEL REKAPITULASI RETRIBUSI PARKIR HARIAN
CREATE TABLE IF NOT EXISTS public.parking_logs (
    id TEXT PRIMARY KEY DEFAULT ('prk_' || gen_random_uuid()::text),
    date DATE NOT NULL DEFAULT CURRENT_DATE,
    amount NUMERIC NOT NULL DEFAULT 0,
    expense NUMERIC NOT NULL DEFAULT 0,
    note TEXT DEFAULT '',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ==============================================================================
-- INDEXES UNTUK PERFORMA QUERY CEPAT
-- ==============================================================================
CREATE INDEX IF NOT EXISTS idx_savings_student_nis ON public.savings_transactions(student_nis);
CREATE INDEX IF NOT EXISTS idx_savings_date ON public.savings_transactions(date);
CREATE INDEX IF NOT EXISTS idx_parking_date ON public.parking_logs(date);
CREATE INDEX IF NOT EXISTS idx_students_class ON public.students(class);
CREATE INDEX IF NOT EXISTS idx_students_name ON public.students(name);

-- ==============================================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- Kebijakan ini memungkinkan aplikasi web mengakses data menggunakan Anon Key
-- ==============================================================================
ALTER TABLE public.app_users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.students ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.savings_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.parking_logs ENABLE ROW LEVEL SECURITY;

-- Policy untuk app_users
DROP POLICY IF EXISTS "Anon Full Access Users" ON public.app_users;
CREATE POLICY "Anon Full Access Users" ON public.app_users 
    FOR ALL TO anon, authenticated 
    USING (true) WITH CHECK (true);

-- Policy untuk students
DROP POLICY IF EXISTS "Anon Full Access Students" ON public.students;
CREATE POLICY "Anon Full Access Students" ON public.students 
    FOR ALL TO anon, authenticated 
    USING (true) WITH CHECK (true);

-- Policy untuk savings_transactions
DROP POLICY IF EXISTS "Anon Full Access Savings" ON public.savings_transactions;
CREATE POLICY "Anon Full Access Savings" ON public.savings_transactions 
    FOR ALL TO anon, authenticated 
    USING (true) WITH CHECK (true);

-- Policy untuk parking_logs
DROP POLICY IF EXISTS "Anon Full Access Parking" ON public.parking_logs;
CREATE POLICY "Anon Full Access Parking" ON public.parking_logs 
    FOR ALL TO anon, authenticated 
    USING (true) WITH CHECK (true);

-- ==============================================================================
-- AKTIFKAN REALTIME NOTIFICATIONS (OPSIONAL / SINKRONISASI OTOMATIS)
-- ==============================================================================
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'students'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.students;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'savings_transactions'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.savings_transactions;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'parking_logs'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.parking_logs;
    END IF;
    IF NOT EXISTS (
        SELECT 1 FROM pg_publication_tables 
        WHERE pubname = 'supabase_realtime' AND tablename = 'app_users'
    ) THEN
        ALTER PUBLICATION supabase_realtime ADD TABLE public.app_users;
    END IF;
END $$;

-- ==============================================================================
-- DATA AWAL (SEED DEMO DATA)
-- ==============================================================================
INSERT INTO public.app_users (id, name, username, password, role)
VALUES 
    ('usr_1', 'Administrator Sekolah', 'admin', 'admin123', 'Admin'),
    ('usr_2', 'Petugas Tabungan & Parkir', 'petugas', 'petugas123', 'Petugas')
ON CONFLICT (username) DO NOTHING;

INSERT INTO public.students (id, nis, name, jk, class, plat, balance)
VALUES 
    ('std_1', '2026001', 'Ahmad Rizky Pratama', 'L', 'X RPL 1', 'B 4123 TZX', 250000),
    ('std_2', '2026002', 'Siti Aisyah Rahma', 'P', 'X RPL 1', 'B 6890 KLR', 450000),
    ('std_3', '2026003', 'Budi Santoso', 'L', 'XI TKJ 2', 'D 1289 VBC', 120000),
    ('std_4', '2026004', 'Dewi Lestari', 'P', 'XI OTKP 1', '', 320000),
    ('std_5', '2026005', 'Muhammad Fadhil', 'L', 'XII AKL 1', 'B 3011 PLM', 180000),
    ('std_6', '2026006', 'Putri Amanda', 'P', 'X RPL 2', 'B 5542 NTY', 210000),
    ('std_7', '2026007', 'Dimas Arya Wijaya', 'L', 'XI TKJ 1', 'B 3899 QWE', 95000),
    ('std_8', '2026008', 'Nabila Zahra', 'P', 'XII AKL 2', '', 150000)
ON CONFLICT (nis) DO NOTHING;

INSERT INTO public.savings_transactions (id, student_nis, student_name, type, amount, date, note)
VALUES 
    ('tx_1', '2026001', 'Ahmad Rizky Pratama', 'SETOR', 200000, CURRENT_DATE - INTERVAL '4 days', 'Setoran awal semester'),
    ('tx_2', '2026001', 'Ahmad Rizky Pratama', 'SETOR', 50000, CURRENT_DATE - INTERVAL '2 days', 'Tabungan mingguan'),
    ('tx_3', '2026002', 'Siti Aisyah Rahma', 'SETOR', 500000, CURRENT_DATE - INTERVAL '3 days', 'Setoran bulanan'),
    ('tx_4', '2026002', 'Siti Aisyah Rahma', 'TARIK', 50000, CURRENT_DATE - INTERVAL '1 days', 'Pembelian buku modul'),
    ('tx_5', '2026003', 'Budi Santoso', 'SETOR', 120000, CURRENT_DATE - INTERVAL '5 days', 'Setoran kas mandiri'),
    ('tx_6', '2026004', 'Dewi Lestari', 'SETOR', 320000, CURRENT_DATE - INTERVAL '3 days', 'Tabungan qurban & perlengkapan'),
    ('tx_7', '2026005', 'Muhammad Fadhil', 'SETOR', 180000, CURRENT_DATE - INTERVAL '2 days', 'Setoran tabungan'),
    ('tx_8', '2026006', 'Putri Amanda', 'SETOR', 210000, CURRENT_DATE - INTERVAL '1 days', 'Setoran tabungan kelas'),
    ('tx_9', '2026007', 'Dimas Arya Wijaya', 'SETOR', 95000, CURRENT_DATE, 'Setoran harian'),
    ('tx_10', '2026008', 'Nabila Zahra', 'SETOR', 150000, CURRENT_DATE, 'Setoran persiapan kelulusan')
ON CONFLICT (id) DO NOTHING;

INSERT INTO public.parking_logs (id, date, amount, expense, note)
VALUES 
    ('prk_1', CURRENT_DATE - INTERVAL '4 days', 85000, 15000, 'Parkir motor 42 unit, cetak karcis'),
    ('prk_2', CURRENT_DATE - INTERVAL '3 days', 95000, 20000, 'Parkir motor 47 unit & konsumsi petugas'),
    ('prk_3', CURRENT_DATE - INTERVAL '2 days', 78000, 10000, 'Parkir motor 39 unit'),
    ('prk_4', CURRENT_DATE - INTERVAL '1 days', 92000, 15000, 'Parkir motor 46 unit & perbaikan tali antrian'),
    ('prk_5', CURRENT_DATE, 110000, 25000, 'Parkir motor & mobil tamu rapat komite')
ON CONFLICT (id) DO NOTHING;
