<?php

namespace App\Http\Controllers;

use App\Models\Jadwal;
use App\Models\Layanan;
use Illuminate\Http\Request;

class JadwalController extends Controller
{
    public function index()
    {
        $jadwals = Jadwal::with('layanan')->get();
        return view('admin.jadwal.index', compact('jadwals'));
    }

    public function create()
    {
        $layanans = Layanan::all();
        return view('admin.jadwal.create', compact('layanans'));
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'layanan_id' => 'required|exists:layanans,id',
            'tanggal' => 'required|date',
            'jam_mulai' => 'required',
            'jam_selesai' => 'required',
            'kuota' => 'required|integer|min:1'
        ]);

        Jadwal::create($data);

        return redirect()->route('admin.jadwal.index')->with('success', 'Jadwal berhasil ditambahkan.');
    }

    public function edit(Jadwal $jadwal)
    {
        $layanans = Layanan::all();
        return view('admin.jadwal.edit', compact('jadwal', 'layanans'));
    }

    public function update(Request $request, Jadwal $jadwal)
    {
        $data = $request->validate([
            'layanan_id' => 'required|exists:layanans,id',
            'tanggal' => 'required|date',
            'jam_mulai' => 'required',
            'jam_selesai' => 'required',
            'kuota' => 'required|integer|min:1'
        ]);

        $jadwal->update($data);

        return redirect()->route('admin.jadwal.index')->with('success', 'Jadwal berhasil diperbarui.');
    }

    public function destroy(Jadwal $jadwal)
    {
        $jadwal->delete();

        return redirect()->route('admin.jadwal.index')->with('success', 'Jadwal berhasil dihapus.');
    }
}
