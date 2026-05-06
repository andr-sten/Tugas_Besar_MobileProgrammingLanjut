<?php

// app/Models/Jadwal.php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Jadwal extends Model
{
    protected $table = 'jadwals';
    protected $fillable = ['layanan_id', 'tanggal', 'jam_mulai', 'jam_selesai', 'kuota'];
    public function layanan() { return $this->belongsTo(Layanan::class); }
    public function antrian() { return $this->hasMany(Antrian::class); }
}