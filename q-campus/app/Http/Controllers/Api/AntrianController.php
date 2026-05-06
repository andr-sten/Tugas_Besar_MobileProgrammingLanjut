<?php

namespace App\Http\Controllers\Api;

use App\Models\{Antrian, Jadwal};
use Illuminate\Http\Request;
use App\Http\Controllers\Controller;
use Illuminate\Support\Facades\Auth;

class AntrianController extends Controller
{
    /**
     * Get active queue status for polling (Mahasiswa)
     */
    public function checkStatus()
    {
        $antrian = Antrian::where('user_id', Auth::id())
            ->whereIn('status', ['menunggu', 'dipanggil'])
            ->first();

        return response()->json([
            'status' => true,
            'message' => 'Status antrian aktif',
            'data' => [
                'status' => $antrian ? $antrian->status : 'none',
                'nomor' => $antrian ? $antrian->nomor : null,
                'nomor_meja' => $antrian ? $antrian->nomor_meja : null,
                'updated_at' => $antrian ? $antrian->updated_at->toDateTimeString() : null,
            ]
        ]);
    }

    public function index() {
        $user = Auth::user();
        $query = Antrian::with(['user', 'layanan', 'jadwal']);

        if ($user->role === 'admin') {
            if ($user->layanan_id) {
                $query->where('layanan_id', $user->layanan_id);
            }
            $data = $query->latest()->get();
        } else {
            $data = $query->where('user_id', $user->id)->latest()->get();

            // Tambahkan info tambahan untuk mahasiswa
            foreach ($data as $antrian) {
                if ($antrian->status === 'menunggu' || $antrian->status === 'dipanggil') {
                    $antrian->antrian_di_depan = Antrian::where('jadwal_id', $antrian->jadwal_id)
                        ->where('status', 'menunggu')
                        ->where('nomor', '<', $antrian->nomor)
                        ->count();
                    
                    $durasi = $antrian->layanan->durasi ?? 10;
                    $antrian->estimasi_waktu = ($antrian->antrian_di_depan + ($antrian->status === 'menunggu' ? 1 : 0)) * $durasi;
                }
            }
        }

        return response()->json([
            'status' => true,
            'message' => 'Data antrian berhasil diambil',
            'data' => $data
        ], 200);
    }

    public function store(Request $request) {
        $request->validate([
            'jadwal_id' => 'required|exists:jadwals,id', 
            'layanan_id' => 'required|exists:layanans,id'
        ]);

        $user = Auth::user();

        // Check for active queue
        $exists = Antrian::where('user_id', $user->id)
            ->where('jadwal_id', $request->jadwal_id)
            ->whereIn('status', ['menunggu', 'dipanggil'])
            ->first();

        if ($exists) {
            return response()->json([
                'status' => false,
                'message' => 'Anda sudah memiliki antrian aktif di jadwal ini',
                'data' => null
            ], 400);
        }

        $jadwal = Jadwal::findOrFail($request->jadwal_id);
        $count = Antrian::where('jadwal_id', $request->jadwal_id)->where('status', '!=', 'batal')->count();
        
        if ($count >= $jadwal->kuota) {
            return response()->json([
                'status' => false,
                'message' => 'Kuota antrian untuk jadwal ini sudah penuh',
                'data' => null
            ], 400);
        }

        $lastNomor = Antrian::where('jadwal_id', $request->jadwal_id)->max('nomor') ?? 0;

        $antrian = Antrian::create([
            'user_id' => $user->id,
            'layanan_id' => $request->layanan_id,
            'jadwal_id' => $request->jadwal_id,
            'nomor' => $lastNomor + 1,
            'status' => 'menunggu'
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Antrian berhasil diambil',
            'data' => $antrian
        ], 201);
    }

    public function update(Request $request, $id) {
        $antrian = Antrian::findOrFail($id);
        $user = Auth::user();

        if ($user->role === 'admin') {
            $request->validate([
                'status' => 'required|in:menunggu,dipanggil,selesai,batal',
                'nomor_meja' => 'nullable|string'
            ]);

            $updateData = ['status' => $request->status];
            if ($request->status === 'dipanggil') {
                $updateData['nomor_meja'] = $request->nomor_meja ?? $user->nomor_meja ?? 'Loket 1';
                
                // Re-call logic
                if ($antrian->status === 'dipanggil') {
                    $antrian->touch();
                }
            }
            
            $antrian->update($updateData);
            $msg = 'Status antrian berhasil diperbarui';
        } else {
            // Mahasiswa can only cancel their own queue
            if ($antrian->user_id !== $user->id) {
                return response()->json([
                    'status' => false, 
                    'message' => 'Akses ditolak', 
                    'data' => null
                ], 403);
            }
            $antrian->update(['status' => 'batal']);
            $msg = 'Antrian berhasil dibatalkan';
        }

        return response()->json([
            'status' => true,
            'message' => $msg,
            'data' => $antrian
        ], 200);
    }

    /**
     * Reset all queues (Admin Only)
     */
    public function reset()
    {
        if (Auth::user()->role !== 'admin') {
            return response()->json([
                'status' => false,
                'message' => 'Akses ditolak',
                'data' => null
            ], 403);
        }

        Antrian::truncate();

        return response()->json([
            'status' => true,
            'message' => 'Seluruh antrian telah dibersihkan',
            'data' => null
        ], 200);
    }
}
