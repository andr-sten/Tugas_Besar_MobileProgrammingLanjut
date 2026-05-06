@extends('layouts.custom')

@section('title', 'Manajemen Antrian - Campus Queue')

@section('content')
<main class="pt-24 pb-12 px-8 max-w-7xl mx-auto">
    <header class="mb-10">
        <h1 class="font-h1 text-h1 text-on-surface mb-2">Manajemen Antrian</h1>
        <p class="text-on-surface-variant font-body-lg">Kelola status antrian dan panggil mahasiswa sesuai urutan.</p>
    </header>

    <div class="glass-card p-lg">
        <div class="flex flex-col md:flex-row gap-4 mb-8 justify-between items-center">
            <div class="relative w-full md:w-80">
                <span class="material-symbols-outlined absolute left-4 top-1/2 -translate-y-1/2 text-outline">search</span>
                <input type="text" placeholder="Cari nomor atau nama..." class="w-full pl-12 pr-4 py-3 bg-surface-container-low border-none rounded-xl focus:ring-2 focus:ring-primary/20 outline-none">
            </div>
            <div class="flex flex-wrap gap-2 items-center">
                <a href="{{ route('admin.antrian') }}" class="px-4 py-2 {{ !request('status') ? 'bg-primary text-on-primary shadow-md' : 'bg-surface-container-low text-on-surface-variant hover:bg-emerald-50' }} rounded-lg font-bold text-sm transition-all">Semua</a>
                <a href="{{ route('admin.antrian', ['status' => 'menunggu']) }}" class="px-4 py-2 {{ request('status') === 'menunggu' ? 'bg-amber-500 text-white shadow-md' : 'bg-surface-container-low text-on-surface-variant hover:bg-amber-50' }} rounded-lg font-bold text-sm transition-all">Menunggu</a>
                <a href="{{ route('admin.antrian', ['status' => 'dipanggil']) }}" class="px-4 py-2 {{ request('status') === 'dipanggil' ? 'bg-blue-600 text-white shadow-md' : 'bg-surface-container-low text-on-surface-variant hover:bg-blue-50' }} rounded-lg font-bold text-sm transition-all">Dipanggil</a>
                <a href="{{ route('admin.antrian', ['status' => 'selesai']) }}" class="px-4 py-2 {{ request('status') === 'selesai' ? 'bg-emerald-600 text-white shadow-md' : 'bg-surface-container-low text-on-surface-variant hover:bg-emerald-50' }} rounded-lg font-bold text-sm transition-all">Selesai</a>
                
                <div class="h-8 w-px bg-emerald-100 mx-2"></div>
                
                <form action="{{ route('admin.antrian.reset') }}" method="POST" onsubmit="return confirm('PENTING: Seluruh data antrian akan dihapus permanen. Tindakan ini tidak dapat dibatalkan. Apakah Anda yakin?')">
                    @csrf
                    <button type="submit" class="px-4 py-2 bg-error text-on-primary rounded-lg font-bold text-sm hover:brightness-110 transition-all flex items-center gap-2">
                        <span class="material-symbols-outlined text-sm">delete_sweep</span>
                        Reset Antrian
                    </button>
                </form>
            </div>
        </div>

        @if(session('success'))
        <div class="mb-6 p-4 bg-emerald-100 text-emerald-800 rounded-xl font-bold border border-emerald-200 flex items-center gap-3">
            <span class="material-symbols-outlined">check_circle</span>
            {{ session('success') }}
        </div>
        @endif

        <div class="overflow-x-auto">
            <table class="w-full">
                <thead>
                    <tr class="text-left text-label-sm text-on-surface-variant border-b border-emerald-50">
                        <th class="pb-4 font-bold">WAKTU</th>
                        <th class="pb-4 font-bold">NOMOR</th>
                        <th class="pb-4 font-bold">MAHASISWA</th>
                        <th class="pb-4 font-bold">LAYANAN</th>
                        <th class="pb-4 font-bold">STATUS</th>
                        <th class="pb-4 font-bold text-right">AKSI</th>
                    </tr>
                </thead>
                <tbody class="divide-y divide-emerald-50/50">
                    @foreach($antrians as $antrian)
                    <tr class="group hover:bg-surface-container-low transition-colors">
                        <td class="py-5 text-sm text-on-surface-variant">{{ $antrian->created_at->format('H:i') }}</td>
                        <td class="py-5 font-bold text-primary">{{ $antrian->nomor }}</td>
                        <td class="py-5">
                            <p class="font-bold">{{ $antrian->user->name }}</p>
                            <p class="text-xs text-on-surface-variant">{{ $antrian->user->username }}</p>
                        </td>
                        <td class="py-5">{{ $antrian->layanan->nama }}</td>
                        <td class="py-5">
                            @php
                                $statusClass = match($antrian->status) {
                                    'menunggu' => 'bg-amber-100 text-amber-700',
                                    'dipanggil' => 'bg-blue-100 text-blue-700',
                                    'selesai' => 'bg-emerald-100 text-emerald-700',
                                    default => 'bg-gray-100 text-gray-700'
                                };
                            @endphp
                            <span class="px-3 py-1 {{ $statusClass }} rounded-full text-[11px] font-bold">{{ ucfirst($antrian->status) }}</span>
                        </td>
                        <td class="py-5 text-right">
                            <div class="flex justify-end gap-2">
                                @if($antrian->status === 'menunggu')
                                <form action="{{ route('admin.antrian.updateStatus', $antrian) }}" method="POST">
                                    @csrf
                                    <input type="hidden" name="status" value="dipanggil">
                                    <button type="submit" class="p-2 bg-primary text-on-primary rounded-lg hover:brightness-110 transition-all flex items-center gap-1 text-xs px-3">
                                        <span class="material-symbols-outlined text-sm">campaign</span> Panggil
                                    </button>
                                </form>
                                @elseif($antrian->status === 'dipanggil')
                                <div class="flex gap-2">
                                    <form action="{{ route('admin.antrian.updateStatus', $antrian) }}" method="POST">
                                        @csrf
                                        <input type="hidden" name="status" value="dipanggil">
                                        <button type="submit" class="p-2 bg-amber-500 text-on-primary rounded-lg hover:brightness-110 transition-all flex items-center gap-1 text-xs px-3">
                                            <span class="material-symbols-outlined text-sm">campaign</span> Panggil Lagi
                                        </button>
                                    </form>
                                    <form action="{{ route('admin.antrian.updateStatus', $antrian) }}" method="POST">
                                        @csrf
                                        <input type="hidden" name="status" value="selesai">
                                        <button type="submit" class="p-2 bg-emerald-600 text-on-primary rounded-lg hover:brightness-110 transition-all flex items-center gap-1 text-xs px-3">
                                            <span class="material-symbols-outlined text-sm">check</span> Selesai
                                        </button>
                                    </form>
                                </div>
                                @endif
                                <div class="relative inline-block text-left" x-data="{ open: false }">
                                    <button @click="open = !open" class="p-2 border border-emerald-100 text-on-surface-variant rounded-lg hover:bg-white transition-all">
                                        <span class="material-symbols-outlined text-sm">more_vert</span>
                                    </button>
                                    <div x-show="open" @click.away="open = false" class="origin-top-right absolute right-0 mt-2 w-48 rounded-md shadow-lg bg-white ring-1 ring-black ring-opacity-5 z-50">
                                        <div class="py-1">
                                            @if($antrian->status !== 'batal')
                                            <form action="{{ route('admin.antrian.updateStatus', $antrian) }}" method="POST">
                                                @csrf
                                                <input type="hidden" name="status" value="batal">
                                                <button type="submit" class="block px-4 py-2 text-sm text-error hover:bg-error-container/20 w-full text-left">Batalkan Antrian</button>
                                            </form>
                                            @endif
                                            @if($antrian->status !== 'menunggu')
                                            <form action="{{ route('admin.antrian.updateStatus', $antrian) }}" method="POST">
                                                @csrf
                                                <input type="hidden" name="status" value="menunggu">
                                                <button type="submit" class="block px-4 py-2 text-sm text-amber-600 hover:bg-amber-50 w-full text-left">Reset ke Menunggu</button>
                                            </form>
                                            @endif
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </td>
                    </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    </div>
</main>
@endsection
