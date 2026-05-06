<?php

// app/Models/Layanan.php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Layanan extends Model
{
    protected $table = 'layanans';
    protected $fillable = ['nama', 'durasi', 'ruangan'];
    public function jadwal() { return $this->hasMany(Jadwal::class); }
}