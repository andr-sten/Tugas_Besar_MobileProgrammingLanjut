<?php

namespace Database\Seeders;

use App\Models\User;
use App\Models\Layanan;
use App\Models\Jadwal;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Carbon\Carbon;

class DatabaseSeeder extends Seeder
{
    /**
     * Jalankan seeder untuk mengisi data awal.
     * Perintah: php artisan db:seed
     */
    public function run(): void
    {
        // 1. BUAT DATA LAYANAN (Pondasi Utama)
        $akademik = Layanan::create([
            'nama' => 'Administrasi Akademik',
            'durasi' => 15,
            'ruangan' => 'Gedung A, Lantai 1'
        ]);

        $keuangan = Layanan::create([
            'nama' => 'Bagian Keuangan (UKT)',
            'durasi' => 20,
            'ruangan' => 'Gedung Rektorat, Meja 5'
        ]);

        $perpus = Layanan::create([
            'nama' => 'Layanan Perpustakaan',
            'durasi' => 10,
            'ruangan' => 'Gedung Perpustakaan Pusat'
        ]);

        // 2. BUAT DATA JADWAL (Slot Waktu untuk Layanan)
        $hari_ini = Carbon::today();
        
        // Jadwal Akademik (Hari ini)
        Jadwal::create([
            'layanan_id' => $akademik->id,
            'tanggal' => $hari_ini,
            'jam_mulai' => '08:00:00',
            'jam_selesai' => '12:00:00',
            'kuota' => 20
        ]);

        // Jadwal Keuangan (Hari ini)
        Jadwal::create([
            'layanan_id' => $keuangan->id,
            'tanggal' => $hari_ini,
            'jam_mulai' => '09:00:00',
            'jam_selesai' => '15:00:00',
            'kuota' => 15
        ]);

        // 3. BUAT DATA USER (Admin & Mahasiswa)
        
        // Admin Akademik (Terkoneksi ke Layanan Akademik)
        User::create([
            'name' => 'Staf Akademik 01',
            'username' => 'admin_akademik',
            'password' => Hash::make('password123'),
            'role' => 'admin',
            'layanan_id' => $akademik->id,
            'nomor_meja' => 'Meja 01'
        ]);

        // Admin Keuangan
        User::create([
            'name' => 'Bendahara Kampus',
            'username' => 'admin_keuangan',
            'password' => Hash::make('password123'),
            'role' => 'admin',
            'layanan_id' => $keuangan->id,
            'nomor_meja' => 'Loket 05'
        ]);

        // Mahasiswa Test (Untuk testing ambil antrian)
        User::create([
            'name' => 'Budi Mahasiswa',
            'username' => '22010001', // NIM
            'password' => Hash::make('password123'),
            'role' => 'mahasiswa',
            'prodi' => 'Teknik Informatika'
        ]);

        $this->command->info('Database Q-Campus berhasil diisi data awal!');
    }
}