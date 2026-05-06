<?php

namespace App\Http\Controllers;

use App\Models\Antrian;
use App\Models\Jadwal;
use App\Models\Layanan;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class FrontEndController extends Controller
{
    public function index()
    {
        if (Auth::check()) {
            return redirect()->route('dashboard');
        }
        return view('auth.login-custom');
    }

    public function dashboard()
    {
        $user = Auth::user();
        if ($user->role === 'admin') {
            $stats = [
                'total' => Antrian::whereIn('status', ['menunggu', 'dipanggil'])->count(),
                'menunggu' => Antrian::where('status', 'menunggu')->count(),
                'dipanggil' => Antrian::where('status', 'dipanggil')->count(),
                'selesai' => Antrian::where('status', 'selesai')->count(),
            ];
            $antrians = Antrian::whereIn('status', ['menunggu', 'dipanggil'])
                ->with(['user', 'layanan'])
                ->latest()
                ->take(5)
                ->get();
            return view('admin.dashboard', compact('stats', 'antrians'));
        }

        // For Mahasiswa
        $antrianAktif = Antrian::where('user_id', $user->id)
            ->whereIn('status', ['menunggu', 'dipanggil'])
            ->with(['layanan', 'jadwal'])
            ->first();

        $antrianDiDepan = 0;
        if ($antrianAktif && $antrianAktif->status === 'menunggu') {
            $antrianDiDepan = Antrian::where('jadwal_id', $antrianAktif->jadwal_id)
                ->where('nomor', '<', $antrianAktif->nomor)
                ->where('status', 'menunggu')
                ->count();
        }

        $jadwals = Layanan::whereHas('jadwal', function($query) {
            $query->where('tanggal', '>=', now()->toDateString());
        })->with(['jadwal' => function($query) {
            $query->where('tanggal', '>=', now()->toDateString())
                  ->orderBy('tanggal', 'asc')
                  ->orderBy('jam_mulai', 'asc');
        }])->take(3)->get();

        $riwayats = Antrian::where('user_id', $user->id)
            ->whereIn('status', ['selesai', 'batal'])
            ->with('layanan')
            ->latest()
            ->take(3)
            ->get();

        return view('mahasiswa.dashboard', compact('user', 'antrianAktif', 'jadwals', 'riwayats', 'antrianDiDepan'));
    }

    public function pilihLayanan()
    {
        $layanans = Layanan::with(['jadwal' => function($query) {
            $query->where('tanggal', '>=', now()->toDateString())
                  ->orderBy('tanggal', 'asc')
                  ->orderBy('jam_mulai', 'asc');
        }])->get();
        return view('mahasiswa.pilih-layanan', compact('layanans'));
    }

    public function manajemenAntrian(Request $request)
    {
        if (Auth::user()->role !== 'admin') {
            abort(403);
        }

        $query = Antrian::with(['user', 'layanan', 'jadwal']);

        if ($request->has('status') && in_array($request->status, ['menunggu', 'dipanggil', 'selesai', 'batal'])) {
            $query->where('status', $request->status);
        }

        $antrians = $query->latest()->get();
        return view('admin.manajemen-antrian', compact('antrians'));
    }

    public function registerForm()
    {
        return view('auth.register-custom');
    }
}
