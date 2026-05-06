@extends('layouts.custom', [
    'hideNav' => true, 
    'hideFooter' => true,
    'bodyClasses' => 'bg-background font-body-md text-on-background min-h-screen flex flex-col items-center justify-center p-6 relative overflow-hidden'
])

@section('title', 'Daftar Akun - Campus Queue')

@section('content')
<!-- Decorative background elements -->
<div class="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary-container/20 rounded-full blur-[120px]"></div>
<div class="absolute bottom-[-10%] right-[-10%] w-[35%] h-[35%] bg-secondary-container/30 rounded-full blur-[100px]"></div>

<!-- Main Register Canvas -->
<main class="w-full max-w-[420px] z-10">
    <div class="glass-card border border-outline-variant/30 rounded-[32px] p-8 shadow-[0_30px_60px_-15px_rgba(0,110,37,0.08)] flex flex-col items-center">
        <!-- Identity Header -->
        <div class="mb-5 text-center">
            <div class="w-10 h-10 bg-primary-container rounded-[14px] flex items-center justify-center mb-3 shadow-sm mx-auto">
                <span class="material-symbols-outlined text-[20px] text-on-primary-container" style="font-variation-settings: 'FILL' 1;">{{ request('role') === 'admin' ? 'admin_panel_settings' : 'person_add' }}</span>
            </div>
            <h1 class="font-h1 text-[22px] text-on-surface mb-1 leading-tight">{{ request('role') === 'admin' ? 'Tambah Admin' : 'Daftar Akun' }}</h1>
            <p class="text-[12px] text-on-surface-variant px-6">Lengkapi data diri Anda di bawah ini.</p>
        </div>

        <!-- Register Form -->
        <form method="POST" action="{{ route('register') }}" class="w-full flex flex-col gap-2.5">
            @csrf
            
            @if(Auth::check() && Auth::user()->role === 'admin')
                <input type="hidden" name="role" value="{{ request('role', 'mahasiswa') }}">
            @endif

            <div class="grid grid-cols-2 gap-3">
                <div class="flex flex-col gap-1">
                    <label class="text-[10px] text-on-surface-variant ml-2 uppercase tracking-wider font-bold">Nama Lengkap</label>
                    <input name="name" class="w-full h-10 px-4 bg-surface-container-low border-none rounded-[12px] focus:ring-2 focus:ring-primary/20 text-xs outline-none" placeholder="Nama" type="text" value="{{ old('name') }}" required autofocus />
                    @error('name') <p class="text-error text-[9px] mt-0.5 ml-2">{{ $message }}</p> @enderror
                </div>

                <div class="flex flex-col gap-1">
                    <label class="text-[10px] text-on-surface-variant ml-2 uppercase tracking-wider font-bold">NIM / ID</label>
                    <input name="username" class="w-full h-10 px-4 bg-surface-container-low border-none rounded-[12px] focus:ring-2 focus:ring-primary/20 text-xs outline-none" placeholder="ID" type="text" value="{{ old('username') }}" required />
                    @error('username') <p class="text-error text-[9px] mt-0.5 ml-2">{{ $message }}</p> @enderror
                </div>
            </div>

            @if(request('role') !== 'admin')
            <div class="flex flex-col gap-1">
                <label class="text-[10px] text-on-surface-variant ml-2 uppercase tracking-wider font-bold">Program Studi</label>
                <input name="prodi" class="w-full h-10 px-4 bg-surface-container-low border-none rounded-[12px] focus:ring-2 focus:ring-primary/20 text-xs outline-none" placeholder="Contoh: Teknik Informatika" type="text" value="{{ old('prodi') }}" required />
                @error('prodi') <p class="text-error text-[9px] mt-0.5 ml-2">{{ $message }}</p> @enderror
            </div>
            @else
            <div class="flex flex-col gap-1">
                <label class="text-[10px] text-on-surface-variant ml-2 uppercase tracking-wider font-bold">Nomor Meja / Loket</label>
                <input name="nomor_meja" class="w-full h-10 px-4 bg-surface-container-low border-none rounded-[12px] focus:ring-2 focus:ring-primary/20 text-xs outline-none" placeholder="Contoh: Meja 1" type="text" value="{{ old('nomor_meja') }}" required />
                @error('nomor_meja') <p class="text-error text-[9px] mt-0.5 ml-2">{{ $message }}</p> @enderror
            </div>
            @endif

            <div class="grid grid-cols-2 gap-3">
                <div class="flex flex-col gap-1">
                    <label class="text-[10px] text-on-surface-variant ml-2 uppercase tracking-wider font-bold">Password</label>
                    <input name="password" class="w-full h-10 px-4 bg-surface-container-low border-none rounded-[12px] focus:ring-2 focus:ring-primary/20 text-xs outline-none" placeholder="Min 8 Karakter" type="password" required />
                    @error('password') <p class="text-error text-[9px] mt-0.5 ml-2">{{ $message }}</p> @enderror
                </div>

                <div class="flex flex-col gap-1">
                    <label class="text-[10px] text-on-surface-variant ml-2 uppercase tracking-wider font-bold">Konfirmasi</label>
                    <input name="password_confirmation" class="w-full h-10 px-4 bg-surface-container-low border-none rounded-[12px] focus:ring-2 focus:ring-primary/20 text-xs outline-none" placeholder="Ulangi" type="password" required />
                </div>
            </div>

            <button class="w-full h-11 bg-primary text-on-primary font-bold text-sm rounded-[14px] shadow-lg shadow-primary/20 hover:brightness-110 active:scale-[0.98] transition-all flex items-center justify-center gap-2 mt-3" type="submit">
                <span>Daftar Akun</span>
                <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
            </button>
        </form>

        <!-- Footer Links -->
        <div class="mt-6 pt-5 border-t border-outline-variant/20 w-full text-center">
            @if(Auth::check() && Auth::user()->role === 'admin')
                <a class="text-primary text-[12px] font-bold hover:underline transition-all" href="{{ route('dashboard') }}">Kembali ke Dashboard</a>
            @else
                <p class="text-[12px] text-on-surface-variant">
                    Sudah punya akun? 
                    <a class="text-primary font-bold hover:underline ml-1" href="{{ route('login') }}">Masuk</a>
                </p>
            @endif
        </div>
    </div>
</main>

<footer class="fixed bottom-6 w-full text-center">
    <p class="text-[10px] text-slate-400 font-medium">© 2024 Universitas Modern. Sistem Antrian Digital.</p>
</footer>
@endsection
