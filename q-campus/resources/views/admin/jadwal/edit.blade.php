@extends('layouts.custom')

@section('title', 'Edit Jadwal - Campus Queue')

@section('content')
<main class="pt-24 pb-12 px-8 max-w-3xl mx-auto">
    <header class="mb-10">
        <a href="{{ route('admin.jadwal.index') }}" class="inline-flex items-center gap-2 text-slate-500 hover:text-primary mb-4 transition-colors font-bold">
            <span class="material-symbols-outlined">arrow_back</span>
            Kembali
        </a>
        <h1 class="font-h1 text-h1 text-on-surface">Edit Jadwal</h1>
        <p class="text-on-surface-variant font-body-lg">Perbarui waktu operasional untuk layanan.</p>
    </header>

    <div class="glass-card p-lg">
        <form action="{{ route('admin.jadwal.update', $jadwal) }}" method="POST">
            @csrf
            @method('PUT')
            <div class="space-y-6">
                <div>
                    <label for="layanan_id" class="block font-bold text-on-surface mb-2">Pilih Layanan</label>
                    <select name="layanan_id" id="layanan_id" class="w-full px-4 py-3 rounded-xl border border-emerald-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all" required>
                        @foreach($layanans as $layanan)
                        <option value="{{ $layanan->id }}" {{ old('layanan_id', $jadwal->layanan_id) == $layanan->id ? 'selected' : '' }}>{{ $layanan->nama }}</option>
                        @endforeach
                    </select>
                    @error('layanan_id') <p class="text-error text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div>
                    <label for="tanggal" class="block font-bold text-on-surface mb-2">Tanggal</label>
                    <input type="date" name="tanggal" id="tanggal" class="w-full px-4 py-3 rounded-xl border border-emerald-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all" required value="{{ old('tanggal', $jadwal->tanggal) }}">
                    @error('tanggal') <p class="text-error text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div class="grid grid-cols-2 gap-4">
                    <div>
                        <label for="jam_mulai" class="block font-bold text-on-surface mb-2">Jam Mulai</label>
                        <input type="time" name="jam_mulai" id="jam_mulai" class="w-full px-4 py-3 rounded-xl border border-emerald-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all" required value="{{ old('jam_mulai', substr($jadwal->jam_mulai, 0, 5)) }}">
                        @error('jam_mulai') <p class="text-error text-xs mt-1">{{ $message }}</p> @enderror
                    </div>
                    <div>
                        <label for="jam_selesai" class="block font-bold text-on-surface mb-2">Jam Selesai</label>
                        <input type="time" name="jam_selesai" id="jam_selesai" class="w-full px-4 py-3 rounded-xl border border-emerald-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all" required value="{{ old('jam_selesai', substr($jadwal->jam_selesai, 0, 5)) }}">
                        @error('jam_selesai') <p class="text-error text-xs mt-1">{{ $message }}</p> @enderror
                    </div>
                </div>

                <div>
                    <label for="kuota" class="block font-bold text-on-surface mb-2">Kuota Antrian</label>
                    <input type="number" name="kuota" id="kuota" class="w-full px-4 py-3 rounded-xl border border-emerald-100 focus:ring-2 focus:ring-primary focus:border-transparent transition-all" placeholder="Contoh: 50" required value="{{ old('kuota', $jadwal->kuota) }}">
                    @error('kuota') <p class="text-error text-xs mt-1">{{ $message }}</p> @enderror
                </div>

                <div class="pt-4">
                    <button type="submit" class="w-full py-4 bg-primary text-on-primary rounded-xl font-bold shadow-lg hover:brightness-110 transition-all flex items-center justify-center gap-2">
                        <span class="material-symbols-outlined">save</span>
                        Perbarui Jadwal
                    </button>
                </div>
            </div>
        </form>
    </div>
</main>
@endsection
