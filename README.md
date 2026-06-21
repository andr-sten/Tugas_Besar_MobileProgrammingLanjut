# q_campus_antrian_mahasiswa

# 📘 Sistem Reservasi Antrian Layanan Administrasi Kampus

---

## 👥 Anggota Kelompok

1. Inez Dea Ariska — STI202303642  
2. Rido Kurniawan — STI202303434  
3. Andrean Syah Putra — STI202303719  
4. Turiman — STI202303581    
5. Fani Amalia — STI202303653  

## 🔗 Repository

**Backend Repository:** https://github.com/andr-sten/TugasBesar_Backend

---

## Link Repository Backend

https://github.com/andr-sten/TugasBesar_Backend

## 🚀 Deskripsi Proyek

Proyek ini merupakan pengembangan **Web API berbasis Laravel** yang digunakan untuk mengelola sistem antrian layanan administrasi kampus. Aplikasi ini dirancang untuk membantu mahasiswa dalam mengambil nomor antrian secara online serta memudahkan admin dalam mengelola layanan dan antrian.

---

## 🎯 Tujuan

- Mengurangi antrean manual di kampus  
- Meningkatkan efisiensi pelayanan administrasi  
- Memberikan sistem antrian digital berbasis mobile  
- Menyediakan API untuk integrasi dengan aplikasi Flutter  

---

## 🧱 Arsitektur Sistem


Flutter (Mobile App)
↓
REST API (Laravel)
↓
MySQL Database


---

## ⚙️ Teknologi yang Digunakan

- Laravel (Backend API)  
- MySQL (Database)  
- Laravel Sanctum (Authentication)  
- Flutter (Mobile App - On Progress)  

---

## 📌 Fitur yang Sudah Dibuat (Progress Saat Ini)

### 🔐 Authentication
- [x] Register mahasiswa  
- [x] Login (NIM / Username)  
- [x] Token Authentication (Sanctum)  
- [x] Logout  

---

### 📋 Layanan
- [x] Get semua layanan  
- [x] Tambah layanan (admin)  
- [x] Edit layanan  
- [x] Hapus layanan  

---

### 📅 Jadwal
- [x] Get jadwal berdasarkan layanan  
- [x] Tambah jadwal (admin)  
- [x] Edit jadwal  
- [x] Hapus jadwal  

---

### 🎫 Antrian
- [x] Ambil nomor antrian  
- [x] Lihat antrian user  
- [x] Lihat semua antrian (admin)  
- [x] Update status antrian (dipanggil / selesai)  

---

## 🔌 Endpoint Utama

| Method | Endpoint | Deskripsi |
|--------|----------|----------|
| POST   | /api/register        | Registrasi |
| POST   | /api/login           | Login |
| GET    | /api/layanan         | List layanan |
| GET    | /api/jadwal/{id}     | Jadwal layanan |
| POST   | /api/antrian         | Ambil antrian |
| GET    | /api/antrian/user    | Antrian user |
| GET    | /api/antrian         | Semua antrian (admin) |
| PUT    | /api/antrian/{id}    | Update status |

---

## 🗄️ Struktur Database

Tabel utama yang digunakan:

- `users`  
- `layanan`  
- `jadwal`  
- `antrian`  

---

## 📱 Progress Flutter (Selesai)

- [x] UI Login  
- [x] UI Register  
- [x] UI Home Mahasiswa & Admin 
- [x] UI Layanan & Jadwal (Admin)
- [x] UI Ambil Antrian & QR Code (Mahasiswa)
- [x] UI Kelola Antrian (Admin)
- [x] Dark Mode Support

---

## 📸 Dokumentasi & Alur Aplikasi (Screenshots)

Berikut adalah detail proses penggunaan aplikasi mulai dari awal pembukaan aplikasi, proses pengambilan antrian, hingga pengelolaan (CRUD) oleh Admin:

### 1. Splash Screen
Tampilan transisi saat aplikasi pertama kali dibuka (Logo Q-Campus).
<p align="center">
  <img src="img/splashscreen.jpeg" width="30%">
  <img src="img/splashscreen1.jpeg" width="30%">
</p>

### 2. Onboarding
Halaman pengenalan sistem yang muncul khusus untuk pengguna yang baru pertama kali menginstal aplikasi.
<p align="center">
  <img src="img/onboarding1.jpeg" width="30%">
  <img src="img/onboarding2.jpeg" width="30%">
  <img src="img/onboarding3.jpeg" width="30%">
</p>

### 3. Autentikasi (Login & Registrasi)
Halaman bagi pengguna (Mahasiswa/Admin) untuk mendaftar akun dan masuk ke dalam sistem.
<p align="center">
  <img src="img/loginscreen.jpeg" width="30%">
  <img src="img/registerscreen.jpeg" width="30%">
  <img src="img/registerscreen2.jpeg" width="30%">
</p>

### 4. Alur Mahasiswa: Dashboard & Pengambilan Antrian
Proses lengkap mahasiswa mulai dari melihat dashboard, memilih layanan & jadwal, pop-up konfirmasi, hingga mendapatkan Tiket Antrian digital (QR Code).
<p align="center">
  <img src="img/dashboardmahasiswa.jpeg" width="30%">
  <img src="img/layananscreenmahasiswa.jpeg" width="30%">
  <img src="img/pilihjadwalmodal.jpeg" width="30%">
</p>
<p align="center">
  <img src="img/konfirmasiantrianmodal.jpeg" width="30%">
  <img src="img/antriandiambilmodal.jpeg" width="30%">
  <img src="img/showqrmahasiswamodal.jpeg" width="30%">
</p>

### 5. Alur Pemanggilan & Notifikasi
Tampilan ketika mahasiswa sudah mendapatkan antrian, memantau sisa antrian secara realtime, serta notifikasi saat dipanggil.
<p align="center">
  <img src="img/mahasiswadashboard2sudahambil.jpeg" width="30%">
  <img src="img/panggilannotification.jpeg" width="30%">
</p>

### 6. Alur Admin: Kelola Antrian Masuk & Scan QR
Dashboard panel admin untuk mengontrol jalannya antrian (Panggil, Ulang, Selesai, Batal) serta fitur untuk pemindaian (scan) QR Code tiket mahasiswa.
<p align="center">
  <img src="img/admindashboard1.jpeg" width="30%">
  <img src="img/generate qr admin.jpeg" width="30%">
  <img src="img/scanscreen.jpeg" width="30%">
</p>

### 7. Alur Admin: CRUD Layanan & Jadwal
Halaman di mana admin dapat menambah (Create), membaca (Read), mengubah (Update), dan menghapus (Delete) daftar Layanan beserta sesi Jadwalnya.
<p align="center">
  <img src="img/layananadmin.jpeg" width="30%">
  <img src="img/tambahlayananmodal.jpeg" width="30%">
  <img src="img/editlayanan.jpeg" width="30%">
</p>
<p align="center">
  <img src="img/jadwaladmin.jpeg" width="30%">
  <img src="img/tambahjadwalmodal.jpeg" width="30%">
  <img src="img/konfirmasihapusmodal.jpeg" width="30%">
</p>

### 8. Mode Gelap & Pengaturan Profil
Antarmuka pengguna saat mengaktifkan Dark Mode, ditambah dengan pengaturan profil Admin dan profil Mahasiswa.
<p align="center">
  <img src="img/themeseting.jpeg" width="30%">
  <img src="img/profilemahasiswascreen.jpeg" width="30%">
  <img src="img/profilscreenadmin.jpeg" width="30%">
</p>

---
