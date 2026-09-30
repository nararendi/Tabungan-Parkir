// ==============================================================================
// EDUVAULT - GLOBAL SUPABASE DATABASE CONFIGURATION
// ==============================================================================
// File ini memungkinkan aplikasi EduVault terhubung otomatis ke database
// Supabase Cloud yang sama di SEMUA browser, komputer, laptop, dan HP tanpa
// perlu mengatur ulang koneksi satu per satu di setiap perangkat!
//
// CARA PENGGUNAAN:
// 1. Masukkan URL Project Supabase Anda pada properti `url`
// 2. Masukkan Anon Public Key Supabase Anda pada properti `anonKey`
// 3. Simpan file ini dan lakukan git push (atau deploy ke Vercel).
// ==============================================================================

window.EDUVAULT_DEFAULT_CONFIG = {
    // Contoh: "https://xxxxxxxxxxxxxxxxxxxx.supabase.co"
    url: "",

    // Kunci panjang publik Supabase yang diawali dengan "eyJhbGciOi..."
    anonKey: ""
};
