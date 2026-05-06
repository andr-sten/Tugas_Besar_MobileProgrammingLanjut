<?php

use App\Http\Controllers\FrontEndController;
use App\Http\Controllers\CustomAuthController;
use Illuminate\Support\Facades\Route;

Route::get('/', [FrontEndController::class, 'index'])->name('home');

// Auth Routes
Route::get('/login', [CustomAuthController::class, 'showLogin'])->name('login')->middleware('guest');
Route::post('/login', [CustomAuthController::class, 'login'])->middleware('guest');
Route::get('/register', [CustomAuthController::class, 'showRegister'])->name('register');
Route::post('/register', [CustomAuthController::class, 'register']);

Route::post('/logout', [CustomAuthController::class, 'logout'])->name('logout');

// Protected Routes
Route::middleware('auth')->group(function () {
    Route::get('/dashboard', [FrontEndController::class, 'dashboard'])->name('dashboard');
    
    // Mahasiswa Routes
    Route::get('/semua-layanan', [FrontEndController::class, 'pilihLayanan'])->name('mahasiswa.layanan.index');
    Route::get('/antrian/status-aktif', [\App\Http\Controllers\AntrianController::class, 'checkStatus'])->name('antrian.checkStatus');
    Route::post('/antrian', [\App\Http\Controllers\AntrianController::class, 'store'])->name('antrian.store');
    Route::post('/antrian/{antrian}/batal', [\App\Http\Controllers\AntrianController::class, 'batal'])->name('antrian.batal');
    
    // Admin Routes
    Route::middleware('can:admin')->group(function () {
        Route::get('/admin/antrian', [FrontEndController::class, 'manajemenAntrian'])->name('admin.antrian');
        Route::post('/admin/antrian/reset', [\App\Http\Controllers\AntrianController::class, 'reset'])->name('admin.antrian.reset');
        Route::post('/admin/antrian/{antrian}/status', [\App\Http\Controllers\AntrianController::class, 'updateStatus'])->name('admin.antrian.updateStatus');

        // Layanan CRUD
        Route::resource('admin/layanan', \App\Http\Controllers\LayananController::class)->names([
            'index' => 'admin.layanan.index',
            'create' => 'admin.layanan.create',
            'store' => 'admin.layanan.store',
            'edit' => 'admin.layanan.edit',
            'update' => 'admin.layanan.update',
            'destroy' => 'admin.layanan.destroy',
        ]);

        // Jadwal CRUD
        Route::resource('admin/jadwal', \App\Http\Controllers\JadwalController::class)->names([
            'index' => 'admin.jadwal.index',
            'create' => 'admin.jadwal.create',
            'store' => 'admin.jadwal.store',
            'edit' => 'admin.jadwal.edit',
            'update' => 'admin.jadwal.update',
            'destroy' => 'admin.jadwal.destroy',
        ]);
    });
});
