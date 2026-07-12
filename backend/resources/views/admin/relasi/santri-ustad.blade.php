@extends('layouts.admin')

@section('content')
<div>
    <h1 class="text-2xl font-bold text-gray-800">Relasi Santri ↔ Ustad</h1>

    <div class="grid grid-cols-1 lg:grid-cols-2 gap-6 mt-4">
        <!-- Form Assign -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h2 class="text-lg font-semibold mb-4">Assign Santri ke Ustad</h2>
            <form method="POST" action="{{ route('admin.relasi.santri-ustad.store') }}">
                @csrf
                <div class="space-y-4">
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Santri</label>
                        <select name="santri_id" class="w-full px-4 py-2 border border-gray-200 rounded-lg" required>
                            <option value="">Pilih Santri</option>
                            @foreach($santri as $s)
                            <option value="{{ $s->id }}">{{ $s->nama }} ({{ $s->nim }})</option>
                            @endforeach
                        </select>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Ustad</label>
                        <select name="ustad_id" class="w-full px-4 py-2 border border-gray-200 rounded-lg" required>
                            <option value="">Pilih Ustad</option>
                            @foreach($ustad as $u)
                            <option value="{{ $u->id }}">{{ $u->nama }}</option>
                            @endforeach
                        </select>
                    </div>
                    <button type="submit" class="w-full bg-brand-600 hover:bg-brand-700 text-white py-2 rounded-lg">Assign</button>
                </div>
            </form>
        </div>

        <!-- Daftar Relasi -->
        <div class="bg-white rounded-xl shadow-sm border border-gray-100 p-6">
            <h2 class="text-lg font-semibold mb-4">Daftar Relasi</h2>
            <div class="space-y-2">
                @forelse($relasi as $r)
                <div class="flex justify-between items-center border-b border-gray-100 py-2">
                    <div>
                        <span class="font-medium">{{ $r->santri->nama }}</span>
                        <span class="text-gray-400 mx-2">→</span>
                        <span>{{ $r->ustad->nama }}</span>
                    </div>
                    <form method="POST" action="{{ route('admin.relasi.santri-ustad.destroy', $r->id) }}" onsubmit="return confirm('Hapus relasi ini?')">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="text-red-500 hover:text-red-700 text-sm">Hapus</button>
                    </form>
                </div>
                @empty
                <p class="text-gray-500 text-sm">Belum ada relasi</p>
                @endforelse
            </div>
        </div>
    </div>
</div>
@endsection