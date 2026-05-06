@extends('layouts.custom')

@section('title', 'Pilih Layanan - Campus Queue')

@section('content')
<main class="pt-24 pb-12 px-8 max-w-7xl mx-auto" x-data="{ selectedLayanan: null }">
    <!-- Wrap content to apply blur -->
    <div :class="selectedLayanan ? 'blur-md pointer-events-none transition-all duration-300' : 'transition-all duration-300'">
        <header class="mb-10">
            <h1 class="font-h1 text-h1 text-on-surface mb-2">Pilih Layanan</h1>
            <p class="text-on-surface-variant font-body-lg">Silakan pilih jenis layanan dan jadwal yang tersedia.</p>
        </header>

        @if(session('error'))
        <div class="mb-6 p-4 bg-error-container text-on-error-container rounded-xl font-bold border border-error/20">
            {{ session('error') }}
        </div>
        @endif

        <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-card-gap">
            @foreach($layanans as $layanan)
            <div class="glass-card p-lg flex flex-col hover:shadow-xl transition-all border border-emerald-50 hover:border-primary/20 group">
                <div class="w-14 h-14 bg-secondary-container rounded-2xl flex items-center justify-center text-primary mb-6 group-hover:scale-110 transition-transform">
                    <span class="material-symbols-outlined text-[32px]">description</span>
                </div>
                <h3 class="font-h2 text-h2 text-on-surface mb-2">{{ $layanan->nama }}</h3>
                <p class="text-on-surface-variant mb-6 flex-grow">{{ $layanan->deskripsi ?? 'Layanan administrasi kampus di gedung ' . $layanan->ruangan }}</p>
                
                <div class="flex items-center gap-4 mb-6 text-label-sm text-on-surface-variant">
                    <div class="flex items-center gap-1">
                        <span class="material-symbols-outlined text-[18px]">schedule</span>
                        <span>~{{ $layanan->durasi }} Menit</span>
                    </div>
                    <div class="flex items-center gap-1">
                        <span class="material-symbols-outlined text-[18px]">location_on</span>
                        <span>{{ $layanan->ruangan }}</span>
                    </div>
                </div>

                @if($layanan->jadwal->isNotEmpty())
                <div class="p-3 rounded-xl bg-surface-container-low mb-8 border border-outline-variant/20">
                    <p class="text-[10px] font-bold text-primary uppercase tracking-wider mb-1">Jadwal Terdekat</p>
                    <div class="flex items-center justify-between">
                        <p class="text-sm font-bold text-on-surface">{{ \Carbon\Carbon::parse($layanan->jadwal->first()->tanggal)->translatedFormat('d M Y') }}</p>
                        <p class="text-sm text-primary font-bold">{{ substr($layanan->jadwal->first()->jam_mulai, 0, 5) }} - {{ substr($layanan->jadwal->first()->jam_selesai, 0, 5) }}</p>
                    </div>
                </div>
                @else
                <div class="p-3 rounded-xl bg-surface-container-low mb-8 border border-outline-variant/20 opacity-60">
                    <p class="text-xs text-on-surface-variant text-center italic">Tidak ada jadwal tersedia</p>
                </div>
                @endif

                <button @click="selectedLayanan = {{ $layanan->id }}" class="w-full py-4 bg-primary text-on-primary rounded-xl font-bold flex items-center justify-center gap-2 hover:brightness-110 transition-all shadow-md active:scale-[0.98]">
                    <span>Ambil Antrian</span>
                    <span class="material-symbols-outlined">confirmation_number</span>
                </button>
            </div>
            @endforeach
        </div>
    </div>

    <!-- Modal Pilih Jadwal -->
    <div x-show="selectedLayanan" 
         x-transition:enter="transition ease-out duration-300"
         x-transition:enter-start="opacity-0 scale-95"
         x-transition:enter-end="opacity-100 scale-100"
         x-transition:leave="transition ease-in duration-200"
         x-transition:leave-start="opacity-100 scale-100"
         x-transition:leave-end="opacity-0 scale-95"
         class="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/40 backdrop-blur-md"
         style="display: none;">
        
        <div class="bg-white w-full max-w-2xl rounded-[32px] shadow-2xl overflow-hidden" @click.away="selectedLayanan = null">
            <div class="p-8 border-b border-emerald-50 flex justify-between items-center">
                <div>
                    <h2 class="font-h2 text-h2 text-on-surface">Pilih Jadwal Tersedia</h2>
                    <p class="text-on-surface-variant text-body-md">Silakan tentukan waktu kunjungan Anda.</p>
                </div>
                <button @click="selectedLayanan = null" class="p-2 hover:bg-surface-container-low rounded-full transition-colors">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            <div class="p-8 max-h-[60vh] overflow-y-auto">
                @foreach($layanans as $layanan)
                <div x-show="selectedLayanan == {{ $layanan->id }}" class="space-y-4">
                    <p class="font-bold text-primary mb-4">{{ $layanan->nama }}</p>
                    @forelse($layanan->jadwal as $jadwal)
                    <form action="{{ route('antrian.store') }}" method="POST" class="p-4 rounded-2xl border border-emerald-50 hover:border-primary hover:bg-emerald-50/30 transition-all group relative">
                        @csrf
                        <input type="hidden" name="layanan_id" value="{{ $layanan->id }}">
                        <input type="hidden" name="jadwal_id" value="{{ $jadwal->id }}">
                        <div class="flex items-center justify-between">
                            <div class="flex items-center gap-4">
                                <div class="w-12 h-12 rounded-xl bg-white border border-emerald-100 flex flex-col items-center justify-center shadow-sm">
                                    <span class="text-[10px] font-bold text-slate-400 uppercase">{{ \Carbon\Carbon::parse($jadwal->tanggal)->translatedFormat('M') }}</span>
                                    <span class="text-lg font-bold text-on-surface leading-none">{{ \Carbon\Carbon::parse($jadwal->tanggal)->translatedFormat('d') }}</span>
                                </div>
                                <div>
                                    <p class="font-bold text-on-surface">{{ \Carbon\Carbon::parse($jadwal->tanggal)->translatedFormat('l, d F Y') }}</p>
                                    <p class="text-sm text-on-surface-variant">{{ substr($jadwal->jam_mulai, 0, 5) }} - {{ substr($jadwal->jam_selesai, 0, 5) }} WIB</p>
                                </div>
                            </div>
                            <div class="text-right">
                                <p class="text-xs font-bold text-primary mb-2">Kuota: {{ $jadwal->kuota }}</p>
                                <button type="submit" class="px-6 py-2 bg-primary text-on-primary rounded-lg font-bold text-sm hover:brightness-110 transition-all">
                                    Ambil
                                </button>
                            </div>
                        </div>
                    </form>
                    @empty
                    <div class="text-center py-10">
                        <span class="material-symbols-outlined text-[48px] text-slate-300 mb-4">event_busy</span>
                        <p class="text-on-surface-variant">Belum ada jadwal tersedia untuk layanan ini.</p>
                    </div>
                    @endforelse
                </div>
                @endforeach
            </div>
        </div>
    </div>
</main>
@endsection
