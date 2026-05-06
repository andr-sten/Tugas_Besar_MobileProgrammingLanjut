@extends('layouts.custom', [
    'hideNav' => true, 
    'hideFooter' => true,
    'bodyClasses' => 'bg-background font-body-md text-on-background min-h-screen flex flex-col items-center justify-center p-6 relative'
])

@section('title', 'Login - Campus Queue')

@section('content')
<!-- Decorative background elements -->
<div class="absolute top-[-10%] left-[-10%] w-[40%] h-[40%] bg-primary-container/20 rounded-full blur-[120px]"></div>
<div class="absolute bottom-[-10%] right-[-10%] w-[35%] h-[35%] bg-secondary-container/30 rounded-full blur-[100px]"></div>

<!-- Main Login Canvas -->
<main class="w-full max-w-[360px] z-10 mt-4 mb-20">
    <div class="glass-card border border-outline-variant/30 rounded-[28px] p-6 shadow-[0_20px_40px_-15px_rgba(0,110,37,0.06)] flex flex-col items-center">
        <!-- Identity Header -->
        <div class="mb-4 text-center">
            <div class="w-10 h-10 bg-primary-container rounded-[14px] flex items-center justify-center mb-3 shadow-sm mx-auto">
                <span class="material-symbols-outlined text-[24px] text-on-primary-container" style="font-variation-settings: 'FILL' 1;">layers</span>
            </div>
            <h1 class="font-h1 text-[24px] text-on-surface mb-0.5 leading-tight">Campus Queue</h1>
            <p class="font-body-md text-[13px] text-on-surface-variant px-2">Masuk untuk mengakses layanan antrian.</p>
        </div>

        <!-- Session Status -->
        @if (session('status'))
            <div class="mb-3 font-medium text-[11px] text-green-600">
                {{ session('status') }}
            </div>
        @endif

        <!-- Login Form -->
        <form method="POST" action="{{ route('login') }}" class="w-full flex flex-col gap-3.5">
            @csrf
            <div class="flex flex-col gap-1">
                <label class="font-label-sm text-[10px] text-on-surface-variant ml-2 uppercase tracking-wider font-bold">Username / ID</label>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-3.5 flex items-center pointer-events-none text-outline">
                        <span class="material-symbols-outlined text-[18px]">person</span>
                    </div>
                    <input name="username" class="font-body-md w-full h-11 pl-11 pr-4 bg-surface-container-low border-none rounded-[14px] focus:ring-2 focus:ring-primary/20 focus:bg-white transition-all outline-none text-sm placeholder:text-outline/60 text-on-surface" placeholder="ID Mahasiswa" type="text" value="{{ old('username') }}" required autofocus />
                </div>
                @error('username')
                    <p class="text-error text-[9px] mt-0.5 ml-2">{{ $message }}</p>
                @enderror
            </div>

            <div class="flex flex-col gap-1">
                <div class="flex justify-between items-center px-2">
                    <label class="font-label-sm text-[10px] text-on-surface-variant uppercase tracking-wider font-bold">Password</label>
                    <a class="font-label-sm text-[10px] font-bold text-primary hover:underline" href="#">Lupa?</a>
                </div>
                <div class="relative group">
                    <div class="absolute inset-y-0 left-3.5 flex items-center pointer-events-none text-outline">
                        <span class="material-symbols-outlined text-[18px]">lock</span>
                    </div>
                    <input name="password" class="font-body-md w-full h-11 pl-11 pr-11 bg-surface-container-low border-none rounded-[14px] focus:ring-2 focus:ring-primary/20 focus:bg-white transition-all outline-none text-sm placeholder:text-outline/60 text-on-surface" placeholder="Password" type="password" required autocomplete="current-password" />
                </div>
                @error('password')
                    <p class="text-error text-[9px] mt-0.5 ml-2">{{ $message }}</p>
                @enderror
            </div>

            <div class="flex items-center px-2 py-0.5">
                <label for="remember_me" class="inline-flex items-center cursor-pointer">
                    <input id="remember_me" type="checkbox" class="rounded border-gray-300 text-primary shadow-sm focus:ring-primary/20 w-3.5 h-3.5" name="remember">
                    <span class="ms-2 font-body-md text-[11px] text-on-surface-variant">Ingat saya</span>
                </label>
            </div>

            <button class="font-body-lg w-full h-11 bg-primary text-on-primary font-bold text-sm rounded-[14px] shadow-lg shadow-primary/20 hover:brightness-110 active:scale-[0.98] transition-all flex items-center justify-center gap-2" type="submit">
                <span>Masuk Sistem</span>
                <span class="material-symbols-outlined text-[18px]">arrow_forward</span>
            </button>
        </form>

        <!-- Footer Links -->
        <div class="mt-5 pt-4 border-t border-outline-variant/20 w-full text-center">
            <p class="font-body-md text-[13px] text-on-surface-variant">
                Belum punya akun? 
                <a class="text-primary font-bold hover:underline ml-1" href="{{ route('register') }}">Daftar</a>
            </p>
        </div>
    </div>

    <!-- Status Badge -->
    <div class="mt-5 flex justify-center">
        <div class="flex items-center gap-2 px-3.5 py-1 bg-secondary-container/30 rounded-full border border-secondary-container/10">
            <div class="w-1.5 h-1.5 rounded-full bg-primary animate-pulse"></div>
            <span class="font-label-sm text-[10px] font-bold text-on-secondary-container uppercase tracking-widest">Server Aktif</span>
        </div>
    </div>
</main>

<footer class="w-full text-center py-6 mt-auto">
    <p class="font-body-md text-[10px] text-slate-400 font-medium">© 2024 Universitas Modern. Sistem Antrian Digital.</p>
</footer>
@endsection
