@extends('layouts.custom')

@section('title', 'Dashboard - Campus Queue')

@section('content')
<main class="pt-24 pb-12 px-8 max-w-7xl mx-auto" x-data="{ selectedDashboardLayanan: null }">
    <!-- Wrap content to apply blur -->
    <div :class="selectedDashboardLayanan ? 'blur-md pointer-events-none transition-all duration-300' : 'transition-all duration-300'">
        <header class="mb-10">
            <h1 class="font-h1 text-h1 text-on-surface mb-2">Selamat datang, <span class="text-primary">{{ Auth::user()->name }}</span>.</h1>
            <p class="text-on-surface-variant font-body-lg">Pantau antrianmu dan kelola keperluan kampus dengan lebih efisien hari ini.</p>
        </header>

        @if($antrianAktif && $antrianAktif->status === 'dipanggil')
        <div class="mb-8 p-5 bg-primary/10 border border-primary/20 rounded-2xl flex items-center justify-between gap-4">
            <div class="flex items-center gap-4">
                <div class="w-12 h-12 bg-primary rounded-xl flex items-center justify-center flex-shrink-0">
                    <span class="material-symbols-outlined text-white text-[28px]">campaign</span>
                </div>
                <div>
                    <h2 class="text-lg font-bold text-primary">Panggilan Antrian</h2>
                    <p class="text-on-surface-variant text-sm">Antrian Anda sedang dipanggil. Silakan menuju ke <span class="font-bold text-on-surface">{{ $antrianAktif->nomor_meja ?? 'Loket 1' }}</span> sekarang.</p>
                </div>
            </div>
            <div class="hidden md:block">
                <span class="px-4 py-2 bg-primary text-on-primary rounded-full text-xs font-bold uppercase tracking-wider">Sedang Dipanggil</span>
            </div>
        </div>
        @endif

    @if(session('success'))
        <div class="mb-6 p-4 bg-emerald-100 text-emerald-800 rounded-xl font-bold border border-emerald-200 flex items-center gap-3">
            <span class="material-symbols-outlined">check_circle</span>
            {{ session('success') }}
        </div>
        @endif

        @if(session('error'))
        <div class="mb-6 p-4 bg-error-container text-on-error-container rounded-xl font-bold border border-error/20 flex items-center gap-3">
            <span class="material-symbols-outlined">error</span>
            {{ session('error') }}
        </div>
        @endif

        <div class="grid grid-cols-1 lg:grid-cols-12 gap-card-gap">
            <section class="lg:col-span-8 flex flex-col gap-card-gap">
                @if($antrianAktif)
                <div class="glass-card p-lg relative overflow-hidden group">
                    <div class="absolute top-0 right-0 w-64 h-64 bg-primary/5 rounded-full -mr-20 -mt-20 blur-3xl group-hover:bg-primary/10 transition-colors"></div>
                    <div class="relative z-10">
                        <div class="flex justify-between items-start mb-base">
                            <span class="inline-flex items-center gap-2 px-4 py-1 bg-secondary-container text-on-secondary-container rounded-full text-label-sm">
                                <span class="material-symbols-outlined text-[16px]" style="font-variation-settings: 'FILL' 1;">confirmation_number</span>
                                Tiket Aktif
                            </span>
                            <div class="text-right">
                                <p class="text-label-sm text-on-surface-variant uppercase tracking-wider">Estimasi Waktu</p>
                                <p class="font-h2 text-h2 text-primary">~{{ $antrianAktif->layanan->durasi ?? '15' }} Menit</p>
                            </div>
                        </div>
                        <div class="flex flex-col md:flex-row items-center gap-10 mt-6">
                            <div class="flex-shrink-0 w-40 h-40 rounded-[40px] bg-primary text-on-primary flex flex-col items-center justify-center shadow-lg shadow-primary/20">
                                <span class="text-[14px] font-bold opacity-80 uppercase tracking-widest">Nomor</span>
                                <span class="text-[56px] font-extrabold leading-none">{{ $antrianAktif->nomor }}</span>
                            </div>
                            <div class="flex-grow grid grid-cols-2 gap-6 w-full">
                                <div class="p-4 rounded-xl bg-surface-container-low border border-outline-variant/30">
                                    <p class="text-label-sm text-on-surface-variant mb-1">Layanan</p>
                                    <p class="font-h2 text-body-lg text-on-surface">{{ $antrianAktif->layanan->nama }}</p>
                                </div>
                                <div class="p-4 rounded-xl bg-surface-container-low border border-outline-variant/30">
                                    <p class="text-label-sm text-on-surface-variant mb-1">Ruangan / Meja</p>
                                    <p class="font-h2 text-body-lg text-on-surface">{{ $antrianAktif->layanan->ruangan }} - {{ $antrianAktif->nomor_meja ?? 'TBA' }}</p>
                                </div>
                                <div class="p-4 rounded-xl bg-surface-container-low border border-outline-variant/30">
                                    <p class="text-label-sm text-on-surface-variant mb-1">Status</p>
                                    <div class="flex items-center gap-2">
                                        <span class="w-2 h-2 rounded-full bg-primary animate-pulse"></span>
                                        <p class="font-h2 text-body-lg text-primary">{{ ucfirst($antrianAktif->status) }}</p>
                                    </div>
                                </div>
                                <div class="p-4 rounded-xl bg-surface-container-low border border-outline-variant/30">
                                    <p class="text-label-sm text-on-surface-variant mb-1">Antrian Di Depan</p>
                                    <p class="font-h2 text-body-lg text-on-surface">{{ $antrianDiDepan }} Orang</p>
                                </div>
                            </div>
                        </div>
                        <div class="mt-8 flex gap-3">
                            <button class="flex-1 py-4 bg-primary text-on-primary rounded-xl font-bold flex items-center justify-center gap-2 hover:brightness-110 transition-all shadow-md active:scale-[0.98]">
                                <span class="material-symbols-outlined">qr_code_2</span>
                                Tampilkan QR Code
                            </button>
                            <form action="{{ route('antrian.batal', $antrianAktif) }}" method="POST" onsubmit="return confirm('Apakah Anda yakin ingin membatalkan antrian ini?')">
                                @csrf
                                <button type="submit" class="px-6 py-4 bg-error-container text-on-error-container rounded-xl font-bold hover:bg-error/10 transition-all active:scale-[0.98]">
                                    <span class="material-symbols-outlined">close</span>
                                </button>
                            </form>
                        </div>
                    </div>
                </div>
                @else
                <div class="glass-card p-lg flex flex-col items-center justify-center text-center py-12">
                    <div class="w-20 h-20 bg-surface-container rounded-full flex items-center justify-center mb-6">
                        <span class="material-symbols-outlined text-[40px] text-outline">confirmation_number</span>
                    </div>
                    <h2 class="font-h2 text-h2 text-on-surface mb-2">Belum Ada Antrian</h2>
                    <p class="text-on-surface-variant mb-8 max-w-md">Anda belum memiliki tiket antrian aktif. Silakan pilih layanan untuk mulai mengantri.</p>
                    <a href="#jadwal-tersedia" class="px-8 py-4 bg-primary text-on-primary rounded-xl font-bold hover:brightness-110 transition-all shadow-lg shadow-primary/20">
                        Ambil Nomor Antrian
                    </a>
                </div>
                @endif

                <div class="glass-card p-lg" id="jadwal-tersedia">
                    <div class="flex items-center justify-between mb-6">
                        <h2 class="font-h2 text-h2 text-on-surface">Jadwal Layanan Tersedia</h2>
                        <a href="{{ route('mahasiswa.layanan.index') }}" class="text-primary font-bold text-label-sm flex items-center gap-1 hover:underline">
                            Lihat Semua <span class="material-symbols-outlined text-[16px]">arrow_forward</span>
                        </a>
                    </div>
                    <div class="grid grid-cols-1 md:grid-cols-3 gap-4">
                        @foreach($jadwals as $layanan)
                        <div @click="selectedDashboardLayanan = {{ $layanan->id }}" class="p-5 rounded-[20px] bg-white border border-emerald-50 hover:shadow-md transition-shadow cursor-pointer group flex flex-col h-full">
                            <div class="w-12 h-12 rounded-2xl bg-secondary-container flex items-center justify-center text-primary mb-4 group-hover:scale-110 transition-transform">
                                <span class="material-symbols-outlined">description</span>
                            </div>
                            <h3 class="font-bold text-on-surface mb-1">{{ $layanan->nama }}</h3>
                            <p class="text-label-sm text-on-surface-variant mb-4">{{ $layanan->ruangan }}</p>
                            
                            <div class="mt-auto pt-4 border-t border-emerald-50/50 flex items-center justify-between">
                                <span class="text-[11px] font-bold text-primary">{{ $layanan->jadwal->count() }} Jadwal Tersedia</span>
                                <div class="w-8 h-8 rounded-full bg-primary/10 text-primary flex items-center justify-center group-hover:bg-primary group-hover:text-white transition-all">
                                    <span class="material-symbols-outlined text-[18px]">add</span>
                                </div>
                            </div>
                        </div>
                        @endforeach
                    </div>
                </div>
            </section>
            <aside class="lg:col-span-4 flex flex-col gap-card-gap">
                <div class="glass-card p-lg flex flex-col gap-6">
                    <h2 class="font-h2 text-h2 text-on-surface">Riwayat Terakhir</h2>
                    <div class="flex flex-col gap-4">
                        @forelse($riwayats as $riwayat)
                        <div class="flex items-center gap-4 p-3 rounded-2xl hover:bg-surface-container-low transition-colors">
                            <div class="w-10 h-10 rounded-xl bg-surface-container flex items-center justify-center text-on-surface-variant">
                                <span class="material-symbols-outlined">history</span>
                            </div>
                            <div class="flex-grow">
                                <p class="font-bold text-on-surface text-body-md">{{ $riwayat->layanan->nama }}</p>
                                <p class="text-label-sm text-on-surface-variant">{{ $riwayat->created_at->format('d M Y') }} • {{ ucfirst($riwayat->status) }}</p>
                            </div>
                        </div>
                        @empty
                        <p class="text-on-surface-variant text-sm text-center">Belum ada riwayat.</p>
                        @endforelse
                    </div>
                    <button class="w-full py-3 border border-emerald-100 text-primary rounded-xl font-bold hover:bg-emerald-50 transition-colors font-body-md">
                        Semua Riwayat
                    </button>
                </div>
                <div class="glass-card p-lg bg-emerald-900 overflow-hidden relative">
                    <div class="absolute -bottom-10 -right-10 w-40 h-40 bg-primary opacity-20 rounded-full blur-2xl"></div>
                    <div class="relative z-10 text-white">
                        <span class="material-symbols-outlined text-[32px] mb-4" style="font-variation-settings: 'FILL' 1;">help</span>
                        <h3 class="font-h2 text-h2 mb-2">Butuh Bantuan?</h3>
                        <p class="text-white/70 text-body-md mb-6">Pusat bantuan kami siap menjawab pertanyaan seputar sistem antrian kampus.</p>
                        <a class="inline-flex items-center gap-2 bg-white text-emerald-900 px-6 py-3 rounded-xl font-bold hover:bg-emerald-50 transition-colors" href="#">
                            Tanya Support
                        </a>
                    </div>
                </div>
            </aside>
        </div>
    </div>

    <!-- Modal Pilihan (Outside blurred container) -->
    <div x-show="selectedDashboardLayanan" 
         x-transition:enter="transition ease-out duration-300"
         x-transition:enter-start="opacity-0 scale-95"
         x-transition:enter-end="opacity-100 scale-100"
         x-transition:leave="transition ease-in duration-200"
         x-transition:leave-start="opacity-100 scale-100"
         x-transition:leave-end="opacity-0 scale-95"
         class="fixed inset-0 z-[60] flex items-center justify-center p-4 bg-black/40 backdrop-blur-md"
         style="display: none;">
        
        <div class="bg-white w-full max-w-2xl rounded-[32px] shadow-2xl overflow-hidden" @click.away="selectedDashboardLayanan = null">
            <div class="p-8 border-b border-emerald-50 flex justify-between items-center">
                <div>
                    <h2 class="font-h2 text-h2 text-on-surface">Pilih Jadwal Antrian</h2>
                    <p class="text-on-surface-variant text-body-md">Silakan tentukan waktu kunjungan Anda.</p>
                </div>
                <button @click="selectedDashboardLayanan = null" class="p-2 hover:bg-surface-container-low rounded-full transition-colors">
                    <span class="material-symbols-outlined">close</span>
                </button>
            </div>
            <div class="p-8 max-h-[60vh] overflow-y-auto">
                @foreach($jadwals as $layanan)
                <div x-show="selectedDashboardLayanan == {{ $layanan->id }}" class="space-y-4">
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
                        <p class="text-on-surface-variant">Belum ada jadwal tersedia.</p>
                    </div>
                    @endforelse
                </div>
                @endforeach
            </div>
        </div>
    </div>
</main>
@endsection

@section('scripts')
<script>
    function showNotification(nomor, loket) {
        if ("Notification" in window && Notification.permission === "granted") {
            new Notification("Panggilan Antrian!", {
                body: `Nomor ${nomor} ke ${loket || 'Loket 1'}`,
                icon: '/favicon.ico',
                tag: 'antrian-panggilan'
            });
            try {
                new Audio('https://assets.mixkit.co/active_storage/sfx/2869/2869-preview.mp3').play();
            } catch (e) {}
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        let lastStatus = "{{ $antrianAktif ? $antrianAktif->status : 'none' }}";
        let lastUpdatedAt = "{{ $antrianAktif ? $antrianAktif->updated_at->toDateTimeString() : '' }}";

        setInterval(function() {
            fetch("{{ route('antrian.checkStatus') }}")
                .then(response => response.json())
                .then(data => {
                    // Panggil notifikasi jika:
                    // 1. Status baru berubah menjadi 'dipanggil'
                    // 2. ATAU Status tetap 'dipanggil' tapi timestamp updated_at berubah (admin klik Panggil Lagi)
                    if (data.status === 'dipanggil') {
                        if (lastStatus !== 'dipanggil' || (data.updated_at && data.updated_at !== lastUpdatedAt)) {
                            showNotification(data.nomor, data.nomor_me_meja || data.nomor_meja);
                            
                            if (Notification.permission !== "granted") {
                                alert("Panggilan: Nomor " + data.nomor + " ke " + (data.nomor_meja || 'Loket 1'));
                            }
                            
                            // Jika ini perubahan status pertama kali, refresh halaman untuk update UI
                            if (lastStatus !== 'dipanggil') {
                                setTimeout(() => window.location.reload(), 3000);
                            }
                        }
                    }

                    if (data.status === 'none' && (lastStatus === 'menunggu' || lastStatus === 'dipanggil')) {
                        window.location.reload();
                    }
                    
                    lastStatus = data.status;
                    lastUpdatedAt = data.updated_at;
                });
        }, 5000);
    });
</script>
@endsection
