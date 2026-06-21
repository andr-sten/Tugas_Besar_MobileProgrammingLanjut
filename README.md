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

## 📱 Progress Flutter (Planned)

- [ ] UI Login  
- [ ] UI Register  
- [ ] UI Home  
- [ ] UI Layanan  
- [ ] UI Jadwal  
- [ ] UI Antrian  

---
