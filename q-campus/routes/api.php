<?php

use App\Http\Controllers\Api\{AuthController, LayananController, AntrianController, JadwalController};
use Illuminate\Support\Facades\Route;

Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:sanctum')->group(function () {
    // Rute User Management
    Route::get('/user', [AuthController::class, 'index']);      // INI YANG TADI HILANG (Penyebab 404)
    Route::put('/user/{id}', [AuthController::class, 'update']); // Untuk Update Profile
    Route::delete('/user/{id}', [AuthController::class, 'destroy']); // Untuk Hapus User
    
    Route::post('/logout', [AuthController::class, 'logout']);
    
    // Resource lainnya
    Route::apiResource('layanan', LayananController::class);
    Route::apiResource('jadwal', JadwalController::class);
    // Antrian
    Route::get('/antrian/check-status', [AntrianController::class, 'checkStatus']);
    Route::post('/antrian/reset', [AntrianController::class, 'reset']);
    Route::get('/antrian', [AntrianController::class, 'index']);
    Route::post('/antrian', [AntrianController::class, 'store']);
    // Mengizinkan PUT dan PATCH untuk update status antrian
    Route::match(['put', 'patch'], '/antrian/{id}', [AntrianController::class, 'update']);

});
