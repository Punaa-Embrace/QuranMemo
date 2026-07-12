@extends('layouts.admin')

@section('page-title', 'Dashboard')
@section('page-subtitle', 'Ringkasan data dan statistik QuranMemo')

@section('content')
<div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
    <!-- Card Santri -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 card-hover">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-gray-500 text-sm font-medium">Total Santri</p>
                <p class="text-3xl font-bold text-gray-800 mt-1">{{ $totalSantri ?? 0 }}</p>
            </div>
            <div class="w-14 h-14 bg-brand-100 rounded-2xl flex items-center justify-center">
                <svg class="w-7 h-7 text-brand-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                </svg>
            </div>
        </div>
    </div>

    <!-- Card Ustad -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 card-hover">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-gray-500 text-sm font-medium">Total Ustad</p>
                <p class="text-3xl font-bold text-gray-800 mt-1">{{ $totalUstad ?? 0 }}</p>
            </div>
            <div class="w-14 h-14 bg-blue-100 rounded-2xl flex items-center justify-center">
                <svg class="w-7 h-7 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.247 18 16.5 18c-1.746 0-3.332.477-4.5 1.253"/>
                </svg>
            </div>
        </div>
    </div>

    <!-- Card Orang Tua -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 card-hover">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-gray-500 text-sm font-medium">Total Orang Tua</p>
                <p class="text-3xl font-bold text-gray-800 mt-1">{{ $totalOrangtua ?? 0 }}</p>
            </div>
            <div class="w-14 h-14 bg-purple-100 rounded-2xl flex items-center justify-center">
                <svg class="w-7 h-7 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 20h5v-2a3 3 0 00-5.356-1.857M17 20H7m10 0v-2c0-.656-.126-1.283-.356-1.857M7 20H2v-2a3 3 0 015.356-1.857M7 20v-2c0-.656.126-1.283.356-1.857m0 0a5.002 5.002 0 019.288 0M15 7a3 3 0 11-6 0 3 3 0 016 0zm6 3a2 2 0 11-4 0 2 2 0 014 0zM7 10a2 2 0 11-4 0 2 2 0 014 0z"/>
                </svg>
            </div>
        </div>
    </div>

    <!-- Card Total -->
    <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 card-hover">
        <div class="flex items-center justify-between">
            <div>
                <p class="text-gray-500 text-sm font-medium">Total User</p>
                <p class="text-3xl font-bold text-gray-800 mt-1">{{ ($totalSantri ?? 0) + ($totalUstad ?? 0) + ($totalOrangtua ?? 0) }}</p>
            </div>
            <div class="w-14 h-14 bg-indigo-100 rounded-2xl flex items-center justify-center">
                <svg class="w-7 h-7 text-indigo-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                </svg>
            </div>
        </div>
    </div>
</div>

<!-- Recent Activity -->
<div class="bg-white rounded-2xl shadow-sm border border-gray-100 mt-8 p-6">
    <div class="flex items-center justify-between mb-4">
        <h3 class="font-bold text-gray-800 flex items-center">
            <svg class="w-5 h-5 text-brand-600 mr-2" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 8v4l3 3m6-3a9 9 0 11-18 0 9 9 0 0118 0z"/>
            </svg>
            Aktivitas Terbaru
        </h3>
        <span class="text-sm text-gray-400">Hari ini</span>
    </div>
    <div class="space-y-3">
        <div class="flex items-center space-x-3 text-sm text-gray-600 border-b border-gray-50 pb-3">
            <div class="w-8 h-8 bg-brand-100 rounded-full flex items-center justify-center">
                <svg class="w-4 h-4 text-brand-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/>
                </svg>
            </div>
            <span>Admin menambahkan santri baru</span>
            <span class="ml-auto text-xs text-gray-400">10 menit lalu</span>
        </div>
        <div class="flex items-center space-x-3 text-sm text-gray-600 border-b border-gray-50 pb-3">
            <div class="w-8 h-8 bg-blue-100 rounded-full flex items-center justify-center">
                <svg class="w-4 h-4 text-blue-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                </svg>
            </div>
            <span>Ustad baru terdaftar</span>
            <span class="ml-auto text-xs text-gray-400">1 jam lalu</span>
        </div>
        <div class="flex items-center space-x-3 text-sm text-gray-600">
            <div class="w-8 h-8 bg-purple-100 rounded-full flex items-center justify-center">
                <svg class="w-4 h-4 text-purple-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M13.828 10.172a4 4 0 00-5.656 0l-4 4a4 4 0 105.656 5.656l1.102-1.101m-.758-4.899a4 4 0 005.656 0l4-4a4 4 0 00-5.656-5.656l-1.1 1.1"/>
                </svg>
            </div>
            <span>Relasi Santri-Orangtua baru dibuat</span>
            <span class="ml-auto text-xs text-gray-400">3 jam lalu</span>
        </div>
    </div>
</div>
@endsection