<?php

namespace App\Http\Controllers\Api;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Http\Controllers\Controller;

class AuthController extends Controller
{
    // 1. Register
    public function register(Request $request) {
        $fields = $request->validate([
            'name' => 'required|string',
            'username' => 'required|string|unique:users,username',
            'password' => 'required|string|confirmed',
            'role' => 'required|in:admin,mahasiswa',
            'prodi' => 'nullable|string',
            'layanan_id' => 'nullable|exists:layanans,id',
            'nomor_meja' => 'nullable|string'
        ]);

        $user = User::create([
            'name' => $fields['name'],
            'username' => $fields['username'],
            'password' => Hash::make($fields['password']),
            'role' => $fields['role'],
            'prodi' => $fields['role'] === 'mahasiswa' ? ($fields['prodi'] ?? null) : null,
            'layanan_id' => $fields['role'] === 'admin' ? ($fields['layanan_id'] ?? null) : null,
            'nomor_meja' => $fields['role'] === 'admin' ? ($fields['nomor_meja'] ?? null) : null
        ]);

        return response()->json([
            'status' => true,
            'message' => 'Registrasi berhasil',
            'data' => ['user' => $user, 'token' => $user->createToken('qtoken')->plainTextToken]
        ], 201);
    }

    // 2. Login
    public function login(Request $request) {
        $fields = $request->validate(['username' => 'required', 'password' => 'required']);
        $user = User::where('username', $fields['username'])->first();
        if(!$user || !Hash::check($fields['password'], $user->password)) {
            return response()->json(['status' => false, 'message' => 'Kredensial salah'], 401);
        }
        return response()->json([
            'status' => true,
            'message' => 'Login berhasil',
            'data' => ['user' => $user, 'token' => $user->createToken('qtoken')->plainTextToken]
        ], 200);
    }

    // 3. Read All Users (Admin Only)
    public function index() {
        if (auth()->user()->role !== 'admin') return response()->json(['status' => false, 'message' => 'Akses ditolak'], 403);
        return response()->json(['status' => true, 'message' => 'Data user berhasil diambil', 'data' => User::all()]);
    }

    // 4. Update User
    public function update(Request $request, $id) {
        $user = User::findOrFail($id);
        if (auth()->user()->role !== 'admin' && auth()->id() !== $user->id) {
            return response()->json(['status' => false, 'message' => 'Akses ditolak'], 403);
        }
        $user->update($request->all());
        return response()->json(['status' => true, 'message' => 'User berhasil diperbarui', 'data' => $user]);
    }

    // 5. Delete User (Admin Only)
    public function destroy($id) {
        if (auth()->user()->role !== 'admin') return response()->json(['status' => false, 'message' => 'Akses ditolak'], 403);
        User::findOrFail($id)->delete();
        return response()->json(['status' => true, 'message' => 'User berhasil dihapus']);
    }
}