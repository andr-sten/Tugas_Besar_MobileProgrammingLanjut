<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rules;

class CustomAuthController extends Controller
{
    public function showLogin()
    {
        return view('auth.login-custom');
    }

    public function login(Request $request)
    {
        $credentials = $request->validate([
            'username' => ['required', 'string'],
            'password' => ['required'],
        ]);

        if (Auth::attempt($credentials, $request->boolean('remember'))) {
            $request->session()->regenerate();
            return redirect()->intended(route('dashboard'));
        }

        return back()->withErrors([
            'username' => 'The provided credentials do not match our records.',
        ])->onlyInput('username');
    }

    public function showRegister()
    {
        // Jika sudah login dan bukan admin, lempar ke dashboard
        if (Auth::check() && Auth::user()->role !== 'admin') {
            return redirect()->route('dashboard');
        }
        return view('auth.register-custom');
    }

    public function register(Request $request)
    {
        $rules = [
            'name' => ['required', 'string', 'max:255'],
            'username' => ['required', 'string', 'max:255', 'unique:users'],
            'password' => ['required', 'confirmed', Rules\Password::defaults()],
        ];

        // Cek apakah yang mendaftarkan adalah admin
        $isAdminAction = Auth::check() && Auth::user()->role === 'admin';

        if ($request->role === 'admin' && $isAdminAction) {
            $rules['nomor_meja'] = ['required', 'string', 'max:255'];
        } else {
            $rules['prodi'] = ['required', 'string', 'max:255'];
        }

        $request->validate($rules);

        $role = ($request->role === 'admin' && $isAdminAction) ? 'admin' : 'mahasiswa';

        $user = User::create([
            'name' => $request->name,
            'username' => $request->username,
            'prodi' => $request->prodi,
            'nomor_meja' => $request->nomor_meja,
            'role' => $role,
            'password' => Hash::make($request->password),
        ]);

        // Jika tidak sedang login, maka login sebagai user baru (pendaftaran mahasiswa umum)
        if (!Auth::check()) {
            Auth::login($user);
            return redirect(route('dashboard'));
        }

        // Jika admin yang mendaftarkan, tetap di dashboard admin
        return redirect(route('dashboard'))->with('success', 'User ' . $role . ' baru berhasil ditambahkan.');
    }

    public function logout(Request $request)
    {
        Auth::logout();
        $request->session()->invalidate();
        $request->session()->regenerateToken();
        return redirect('/');
    }
}
