<?php

// app/Models/Antrian.php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;

class Antrian extends Model
{
    protected $table = 'antrians';
    protected $fillable = ['user_id', 'layanan_id', 'jadwal_id', 'nomor', 'status', 'nomor_meja'];
    public function user() { return $this->belongsTo(User::class); }
    public function layanan() { return $this->belongsTo(Layanan::class); }
    public function jadwal() { return $this->belongsTo(Jadwal::class); }
}