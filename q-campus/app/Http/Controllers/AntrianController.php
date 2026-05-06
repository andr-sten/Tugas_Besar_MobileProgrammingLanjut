<?php

namespace App\Http\Controllers;

use App\Models\Antrian;
use App\Models\Jadwal;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class AntrianController extends Controller
{
    public function store(Request $request)
    {
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
            return back()->with('error', 'Anda sudah memiliki antrian aktif di jadwal ini.');
        }

        $jadwal = Jadwal::findOrFail($request->jadwal_id);
        $count = Antrian::where('jadwal_id', $request->jadwal_id)->where('status', '!=', 'batal')->count();

        if ($count >= $jadwal->kuota) {
            return back()->with('error', 'Kuota antrian untuk jadwal ini sudah penuh.');
        }

        $lastNomor = Antrian::where('jadwal_id', $request->jadwal_id)->max('nomor') ?? 0;

        Antrian::create([
            'user_id' => $user->id,
            'layanan_id' => $request->layanan_id,
            'jadwal_id' => $request->jadwal_id,
            'nomor' => $lastNomor + 1,
            'status' => 'menunggu'
        ]);

        return redirect()->route('dashboard')->with('success', 'Antrian berhasil diambil.');
    }

    public function checkStatus()
    {
        $antrian = Antrian::where('user_id', Auth::id())
            ->whereIn('status', ['menunggu', 'dipanggil'])
            ->first();

        return response()->json([
            'status' => $antrian ? $antrian->status : 'none',
            'nomor' => $antrian ? $antrian->nomor : null,
            'nomor_meja' => $antrian ? $antrian->nomor_meja : null,
            'updated_at' => $antrian ? $antrian->updated_at->toDateTimeString() : null,
        ]);
    }

    public function reset()
    {
        if (Auth::user()->role !== 'admin') {
            abort(403);
        }

        Antrian::truncate(); // Menghapus semua data dan me-reset ID/Auto Increment

        return back()->with('success', 'Seluruh antrian telah dibersihkan.');
    }

    public function updateStatus(Request $request, Antrian $antrian)
    {
        if (Auth::user()->role !== 'admin') {
            abort(403);
        }

        $request->validate([
            'status' => 'required|in:menunggu,dipanggil,selesai,batal',
            'nomor_meja' => 'nullable|string|max:50'
        ]);

        $updateData = ['status' => $request->status];
        if ($request->status === 'dipanggil') {
            $updateData['nomor_meja'] = $request->nomor_meja ?? Auth::user()->nomor_meja ?? 'Loket 1';
            
            // Jika status sudah dipanggil, paksa update timestamp untuk memicu notifikasi ulang
            if ($antrian->status === 'dipanggil') {
                $antrian->touch();
            }
        }

        $antrian->update($updateData);

        return back()->with('success', 'Status antrian berhasil diperbarui.');
    }

    public function batal(Antrian $antrian)
    {
        if ($antrian->user_id !== Auth::id()) {
            abort(403);
        }

        $antrian->update(['status' => 'batal']);

        return back()->with('success', 'Antrian berhasil dibatalkan.');
    }
}
