@extends('layouts.custom')

@section('title', 'Tambah Layanan - Campus Queue')

@section('content')
<main class="pt-24 pb-12 px-8 max-w-3xl mx-auto">
    <header class="mb-10">
        <a href="{{ route('admin.layanan.index') }}" class="inline-flex items-center gap-2 text-slate-500 hover:text-primary mb-4 transition-colors font-bold">
            <span class="material-symbols-outlined">arrow_back</span>
            Kembali
        </a>
        <h1 class="font-h1 text-h1 text-on-surface">Tambah Layanan Baru</h1>
        <p class="text-on-surface-variant font-body-lg">Isi detail layanan di bawah ini.</p>
    </header>

    <div class="glass-card p-lg">
        <form action="{{ route('admin.layanan.store') }}" method="POST">
            @csrf
            <div class="space-y-6">
                <div>
                    <label for="nama" class="block font-bold text-on-surface mb-2">Nama Layanan</label>
                    <input type="text" name="nama" id="nama" class="w-full px-4 py-3 rounded-xl border border-emerald-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all" placeholder="Contoh: Legalisir Ijazah" required value="{{ old('nama') }}">
                    @error('nama') <p class="text-error text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label for="durasi" class="block font-bold text-on-surface mb-2">Durasi (Menit)</label>
                    <input type="number" name="durasi" id="durasi" class="w-full px-4 py-3 rounded-xl border border-emerald-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all" placeholder="Contoh: 15" required value="{{ old('durasi') }}">
                    @error('durasi') <p class="text-error text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label for="ruangan" class="block font-bold text-on-surface mb-2">Ruangan / Loket</label>
                    <input type="text" name="ruangan" id="ruangan" class="w-full px-4 py-3 rounded-xl border border-emerald-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all" placeholder="Contoh: Rektorat Lt. 1" required value="{{ old('ruangan') }}">
                    @error('ruangan') <p class="text-error text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div class="pt-4">
                    <button type="submit" class="w-full py-4 bg-primary text-on-primary rounded-xl font-bold shadow-lg hover:brightness-110 transition-all flex items-center justify-center gap-2">
                        <span class="material-symbols-outlined">save</span>
                        Simpan Layanan
                    </button>
                </div>
            </div>
        </form>
    </div>
</main>
@endsection
