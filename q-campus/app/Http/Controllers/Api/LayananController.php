<?php

namespace App\Http\Controllers\Api;

use App\Models\Layanan;
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class LayananController extends Controller
{
    public function index() { 
        return response()->json([
            'status' => true,
            'message' => 'Daftar layanan berhasil diambil',
            'data' => Layanan::all()
        ], 200); 
    }

    public function show($id) {
        $layanan = Layanan::find($id);
        if (!$layanan) {
            return response()->json([
                'status' => false,
                'message' => 'Layanan tidak ditemukan',
                'data' => null
            ], 404);
        }
        return response()->json([
            'status' => true,
            'message' => 'Detail layanan berhasil diambil',
            'data' => $layanan
        ], 200);
    }

    public function store(Request $request) {
        if (Auth::user()->role !== 'admin') {
            return response()->json([
                'status' => false,
                'message' => 'Hanya admin yang dapat menambah layanan',
                'data' => null
            ], 403);
        }

        $data = $request->validate([
            'nama' => 'required|string|max:255', 
            'durasi' => 'required|integer|min:1', 
            'ruangan' => 'required|string|max:255'
        ]);

        $layanan = Layanan::create($data);

        return response()->json([
            'status' => true,
            'message' => 'Layanan berhasil dibuat',
            'data' => $layanan
        ], 201);
    }

    public function update(Request $request, $id) {
        if (Auth::user()->role !== 'admin') {
            return response()->json([
                'status' => false, 
                'message' => 'Hanya admin yang dapat memperbarui layanan', 
                'data' => null
            ], 403);
        }

        $layanan = Layanan::findOrFail($id);
        
        $data = $request->validate([
            'nama' => 'required|string|max:255', 
            'durasi' => 'required|integer|min:1', 
            'ruangan' => 'required|string|max:255'
        ]);

        $layanan->update($data);

        return response()->json([
            'status' => true,
            'message' => 'Layanan berhasil diperbarui',
            'data' => $layanan
        ], 200);
    }

    public function destroy($id) {
        if (Auth::user()->role !== 'admin') {
            return response()->json([
                'status' => false, 
                'message' => 'Hanya admin yang dapat menghapus layanan', 
                'data' => null
            ], 403);
        }

        $layanan = Layanan::findOrFail($id);
        $layanan->delete();

        return response()->json([
            'status' => true,
            'message' => 'Layanan berhasil dihapus',
            'data' => null
        ], 200);
    }
}
