<?php

// app/Models/User.php
namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens; // WAJIB ADA

class User extends Authenticatable
{
    use HasApiTokens, Notifiable;

    protected $fillable = ['name', 'username', 'password', 'prodi', 'role', 'layanan_id', 'nomor_meja'];

    protected $hidden = ['password', 'remember_token'];

    public function layanan_admin() { 
        return $this->belongsTo(Layanan::class, 'layanan_id'); 
    }
}