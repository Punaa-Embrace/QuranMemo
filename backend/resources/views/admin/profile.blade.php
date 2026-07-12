@extends('layouts.admin')

@section('page-title', 'Pengaturan Profile')
@section('page-subtitle', 'Kelola informasi akun admin Anda')

@section('content')
<div class="flex flex-col items-center">
    
    <!-- Card Profile -->
    <div class="w-full max-w-2xl bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
        
        <!-- Header Card -->
        <div class="gradient-bg px-6 py-8 text-center">
            <div class="relative inline-block">
                <div class="w-24 h-24 bg-white/20 rounded-full flex items-center justify-center mx-auto backdrop-blur-sm border-4 border-white/50">
                    <svg class="w-12 h-12 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                    </svg>
                </div>
                <div class="absolute bottom-0 right-0 w-8 h-8 bg-brand-500 rounded-full border-4 border-white flex items-center justify-center">
                    <svg class="w-4 h-4 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.572L16.732 3.732z"/>
                    </svg>
                </div>
            </div>
            <h2 class="text-xl font-bold text-white mt-4">{{ $admin->nama }}</h2>
            <p class="text-brand-100 text-sm">{{ $admin->email }}</p>
            <span class="inline-block mt-2 px-3 py-1 bg-white/20 text-white text-xs font-medium rounded-full">
                Administrator
            </span>
        </div>

        <!-- Form Body -->
        <div class="p-8">
            <form method="POST" action="{{ route('admin.profile.update') }}" class="space-y-6">
                @csrf
                @method('PUT')

                <!-- Nama -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1.5">
                        <span class="flex items-center">
                            <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                            </svg>
                            Nama Lengkap
                        </span>
                    </label>
                    <input type="text" name="nama" value="{{ old('nama', $admin->nama) }}" 
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-transparent transition"
                           placeholder="Masukkan nama lengkap" required>
                    @error('nama')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Email -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1.5">
                        <span class="flex items-center">
                            <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"/>
                            </svg>
                            Email
                        </span>
                    </label>
                    <input type="email" name="email" value="{{ old('email', $admin->email) }}" 
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-transparent transition"
                           placeholder="Masukkan email" required>
                    @error('email')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Divider -->
                <div class="relative my-2">
                    <div class="absolute inset-0 flex items-center">
                        <div class="w-full border-t border-gray-200"></div>
                    </div>
                    <div class="relative flex justify-center">
                        <span class="bg-white px-4 text-sm text-gray-400">Ubah Password</span>
                    </div>
                </div>

                <!-- Password Baru -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1.5">
                        <span class="flex items-center">
                            <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/>
                            </svg>
                            Password Baru
                        </span>
                    </label>
                    <input type="password" name="password" 
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-transparent transition"
                           placeholder="Kosongkan jika tidak diubah">
                    @error('password')
                        <p class="text-red-500 text-sm mt-1">{{ $message }}</p>
                    @enderror
                </div>

                <!-- Konfirmasi Password -->
                <div>
                    <label class="block text-sm font-semibold text-gray-700 mb-1.5">
                        <span class="flex items-center">
                            <svg class="w-4 h-4 mr-2 text-gray-400" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m5.618-4.016A11.955 11.955 0 0112 2.944a11.955 11.955 0 01-8.618 3.04A12.02 12.02 0 003 9c0 5.591 3.824 10.29 9 11.622 5.176-1.332 9-6.03 9-11.622 0-1.042-.133-2.052-.382-3.016z"/>
                            </svg>
                            Konfirmasi Password
                        </span>
                    </label>
                    <input type="password" name="password_confirmation" 
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-brand-500 focus:border-transparent transition"
                           placeholder="Kosongkan jika tidak diubah">
                </div>

                <!-- Tombol Submit -->
                <div class="flex gap-4 pt-4">
                    <button type="submit" 
                            class="flex-1 gradient-bg hover:opacity-90 text-white py-3 rounded-xl font-semibold transition flex items-center justify-center gap-2">
                        <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 4v5h.582m15.356 2A8.001 8.001 0 004.582 9m0 0H9m11 11v-5h-.581m0 0a8.003 8.003 0 01-15.357-2m15.357 2H15"/>
                        </svg>
                        Simpan Perubahan
                    </button>
                    <a href="{{ route('admin.dashboard') }}" 
                       class="px-6 py-3 bg-gray-100 hover:bg-gray-200 text-gray-700 rounded-xl font-semibold transition text-center">
                        Batal
                    </a>
                </div>
            </form>
        </div>
    </div>

    <!-- Footer Info -->
    <p class="text-xs text-gray-400 mt-6 text-center">
        <svg class="w-4 h-4 inline mr-1 text-gray-300" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z"/>
        </svg>
        Data Anda aman dan tidak akan dibagikan ke pihak lain.
    </p>
</div>
@endsection