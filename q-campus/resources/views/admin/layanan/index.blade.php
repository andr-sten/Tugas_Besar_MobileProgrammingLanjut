@extends('layouts.custom')

@section('title', 'Kelola Layanan - Campus Queue')

@section('content')
<main class="pt-24 pb-12 px-8 max-w-7xl mx-auto">
    <header class="mb-10 flex justify-between items-end">
        <div>
            <h1 class="font-h1 text-h1 text-on-surface mb-2">Kelola Layanan</h1>
            <p class="text-on-surface-variant font-body-lg">Tambah, ubah, atau hapus kategori layanan administrasi.</p>
        </div>
        <a href="{{ route('admin.layanan.create') }}" class="px-6 py-3 bg-primary text-on-primary rounded-xl font-bold flex items-center gap-2 shadow-lg hover:brightness-110 transition-all">
            <span class="material-symbols-outlined">add</span>
            Tambah Layanan
        </a>
    </header>

    @if(session('success'))
    <div class="mb-6 p-4 bg-emerald-100 text-emerald-800 rounded-xl font-bold border border-emerald-200">
        {{ session('success') }}
    </div>
    @endif

    <div class="glass-card p-lg overflow-hidden">
        <div class="overflow-x-auto">
            <table class="w-full">
                <thead>
                    <tr class="text-left text-label-sm text-on-surface-variant border-b border-emerald-50">
                        <th class="pb-4 font-bold">ID</th>
                        <th class="pb-4 font-bold">NAMA LAYANAN</th>
                        <th class="pb-4 font-bold">DURASI (MENIT)</th>
                        <th class="pb-4 font-bold">RUANGAN</th>
                        <th class="pb-4 font-bold text-right">AKSI</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-emerald-50/50">
                    @forelse($layanans as $layanan)
                    <tr class="group hover:bg-surface-container-low transition-colors">
                        <td class="py-5 font-bold text-slate-500">#{{ $layanan->id }}</td>
                        <td class="py-5">
                            <p class="font-bold text-on-surface">{{ $layanan->nama }}</p>
                        </td>
                        <td class="py-5">
                            <span class="flex items-center gap-2">
                                <span class="material-symbols-outlined text-sm text-slate-400">schedule</span>
                                {{ $layanan->durasi }} Menit
                            </span>
                        </td>
                        <td class="py-5">
                            <span class="flex items-center gap-2">
                                <span class="material-symbols-outlined text-sm text-slate-400">meeting_room</span>
                                {{ $layanan->ruangan }}
                            </span>
                        </td>
                        <td class="py-5 text-right">
                            <div class="flex justify-end gap-2">
                                <a href="{{ route('admin.layanan.edit', $layanan) }}" class="p-2 text-primary hover:bg-primary-container/20 rounded-lg transition-all">
                                    <span class="material-symbols-outlined">edit</span>
                                </a>
                                <form action="{{ route('admin.layanan.destroy', $layanan) }}" method="POST" class="inline" onsubmit="return confirm('Apakah Anda yakin ingin menghapus layanan ini?')">
                                    @csrf
                                    @method('DELETE')
                                    <button type="submit" class="p-2 text-error hover:bg-error-container/20 rounded-lg transition-all">
                                        <span class="material-symbols-outlined">delete</span>
                                    </button>
                                </form>
                            </div>
                        </td>
                    </tr>
                    @empty
                    <tr>
                        <td colspan="5" class="py-10 text-center text-on-surface-variant">Belum ada data layanan.</td>
                    </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
</main>
@endsection
