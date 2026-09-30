-- ==============================================================================
-- TABUNGAN SISWA & RETRIBUSI PARKIR SEKOLAH (EDUNAULT)
-- SUPABASE POSTGRESQL DATABASE SCHEMA
-- ==============================================================================
-- CARA PENGGUNAAN:
-- 1. Buka Dashboard Supabase Anda (https://supabase.com/dashboard)
-- 2. Pilih project Anda, lalu buka menu "SQL Editor" di bilah navigasi kiri.
-- 3. Buat "New Query", salin seluruh isi file ini, lalu klik tombol "RUN".
-- 4. Semua tabel, relasi, index, dan kebijakan RLS akan langsung siap (bersih tanpa data dummy)!
-- ==============================================================================

-- 1. TABEL PENGGUNA SISTEM (USERS & ADMIN)
CREATE TABLE IF NOT EXISTS public.app_users (
    id TEXT PRIMARY KEY DEFAULT ('usr_' || gen_random_uuid()::text),
    name TEXT NOT NULL,
    username TEXT UNIQUE NOT NULL,
    password TEXT NOT NULL,
    role TEXT DEFAULT 'user',
    created_at TIMESTAMPTZ DEFAULT now()
);

-- JIKA TABEL SUDAH ADA SEBELUMNYA: Lepas constraint lama & pasang constraint baru
ALTER TABLE public.app_users DROP CONSTRAINT IF EXISTS app_users_role_check;
ALTER TABLE public.app_users ADD CONSTRAINT app_users_role_check 
    CHECK (role IN ('super_admin', 'user', 'Admin', 'Petugas'));

-- Migrasi role lama ke format baru jika ada
UPDATE public.app_users SET role = 'super_admin' WHERE role = 'Admin';
UPDATE public.app_users SET role = 'user' WHERE role = 'Petugas';

-- AKUN DEFAULT SUPER ADMIN (Tanpa data dummy, hanya akun utama untuk login)
INSERT INTO public.app_users (id, name, username, password, role)
VALUES ('usr_superadmin', 'Super Administrator', 'admin', 'admin123', 'super_admin')
ON CONFLICT (username) DO UPDATE 
SET role = 'super_admin',
    name = EXCLUDED.name,
    password = EXCLUDED.password;

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
-- PEMBERSIHAN DATA DUMMY (MENGHAPUS SEMUA DATA DUMMY SEBELUMNYA DI SUPABASE)
-- ==============================================================================
-- Perintah ini memastikan database Supabase Anda bersih dari data dummy lama:
TRUNCATE TABLE public.savings_transactions CASCADE;
TRUNCATE TABLE public.parking_logs CASCADE;
TRUNCATE TABLE public.students CASCADE;
DELETE FROM public.app_users WHERE username NOT IN ('admin');

-- ==============================================================================
-- SKEMA DATABASE SIAP (BERSIH 100% TANPA DATA DUMMY)
-- Anda dapat mulai mengisi data langsung melalui antarmuka web EduVault!
-- ==============================================================================
