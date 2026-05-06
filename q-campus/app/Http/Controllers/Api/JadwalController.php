<?php

namespace App\Http\Controllers\Api;

use App\Models\Jadwal;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class JadwalController extends Controller
{
    public function index(Request $request) {
        $query = Jadwal::with('layanan');
        if($request->has('layanan_id')) {
            $query->where('layanan_id', $request->layanan_id);
        }

        return response()->json([
            'status' => true,
            'message' => 'Daftar jadwal berhasil diambil',
            'data' => $query->get()
        ], 200);
    }

    public function show($id) {
        $jadwal = Jadwal::with('layanan')->find($id);
        if (!$jadwal) {
            return response()->json([
                'status' => false,
                'message' => 'Jadwal tidak ditemukan',
                'data' => null
            ], 404);
        }
        return response()->json([
            'status' => true,
            'message' => 'Detail jadwal berhasil diambil',
            'data' => $jadwal
        ], 200);
    }

    public function store(Request $request) {
        if (Auth::user()->role !== 'admin') {
            return response()->json([
                'status' => false, 
                'message' => 'Hanya admin yang dapat menambah jadwal', 
                'data' => null
            ], 403);
        }
        
        $data = $request->validate([
            'layanan_id' => 'required|exists:layanans,id',
            'tanggal' => 'required|date',
            'jam_mulai' => 'required',
            'jam_selesai' => 'required',
            'kuota' => 'required|integer|min:1'
        ]);

        $jadwal = Jadwal::create($data);

        return response()->json([
            'status' => true,
            'message' => 'Jadwal berhasil dibuat',
            'data' => $jadwal
        ], 201);
    }

    public function update(Request $request, $id) {
        if (Auth::user()->role !== 'admin') {
            return response()->json([
                'status' => false, 
                'message' => 'Hanya admin yang dapat memperbarui jadwal', 
                'data' => null
            ], 403);
        }

        $jadwal = Jadwal::findOrFail($id);
        
        $data = $request->validate([
            'layanan_id' => 'required|exists:layanans,id',
            'tanggal' => 'required|date',
            'jam_mulai' => 'required',
            'jam_selesai' => 'required',
            'kuota' => 'required|integer|min:1'
        ]);

        $jadwal->update($data);

        return response()->json([
            'status' => true,
            'message' => 'Jadwal berhasil diperbarui',
            'data' => $jadwal
        ], 200);
    }

    public function destroy($id) {
        if (Auth::user()->role !== 'admin') {
            return response()->json([
                'status' => false, 
                'message' => 'Hanya admin yang dapat menghapus jadwal', 
                'data' => null
            ], 403);
        }

        $jadwal = Jadwal::findOrFail($id);
        $jadwal->delete();

        return response()->json([
            'status' => true,
            'message' => 'Jadwal berhasil dihapus',
            'data' => null
        ], 200);
    }
}
