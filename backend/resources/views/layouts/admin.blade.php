<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <title>QuranMemo Admin</title>
    
    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>
    <script>
        tailwind.config = {
            theme: {
                extend: {
                    colors: {
                        brand: {
                            50: '#e8f4ec',
                            100: '#c5e3d0',
                            200: '#a3d2b5',
                            300: '#80c299',
                            400: '#4E8F28',
                            500: '#188F48',
                            600: '#137239',
                            700: '#0f562b',
                            800: '#0b391d',
                            900: '#071d0e',
                        },
                        accent: '#F5E2D1'
                    }
                }
            }
        }
    </script>
    
    <!-- Google Font Inter -->
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    
    <style>
        * { font-family: 'Inter', sans-serif; }
        
        .sidebar-link {
            transition: all 0.2s ease;
        }
        .sidebar-link:hover {
            background: #e8f4ec;
            color: #188F48;
        }
        .sidebar-link.active {
            background: #188F48;
            color: white;
            box-shadow: 0 4px 12px rgba(24, 143, 72, 0.3);
        }
        .sidebar-link.active svg {
            stroke: white;
        }
        
        .card-hover {
            transition: all 0.25s ease;
        }
        .card-hover:hover {
            transform: translateY(-4px);
            box-shadow: 0 20px 25px -5px rgba(0,0,0,0.1);
        }
        
        .gradient-bg {
            background: linear-gradient(135deg, #188F48 0%, #4E8F28 100%);
        }
        
        .scrollbar-thin::-webkit-scrollbar {
            width: 6px;
        }
        .scrollbar-thin::-webkit-scrollbar-track {
            background: #f1f1f1;
        }
        .scrollbar-thin::-webkit-scrollbar-thumb {
            background: #188F48;
            border-radius: 10px;
        }
        
        .dropdown-profile {
            transition: all 0.2s ease;
            transform-origin: top right;
        }
        .dropdown-profile.hidden {
            opacity: 0;
            transform: scale(0.95) translateY(-10px);
            pointer-events: none;
        }
        
        .icon-svg {
            width: 20px;
            height: 20px;
            flex-shrink: 0;
        }
    </style>
</head>

<body class="bg-[#f8fafc]">
    <div class="flex h-screen overflow-hidden">

        <!-- ============================================ -->
        <!-- SIDEBAR                                       -->
        <!-- ============================================ -->
        <aside class="w-72 bg-white shadow-xl flex-shrink-0 overflow-y-auto scrollbar-thin z-10">
            <!-- Brand -->
            <div class="p-6 border-b border-gray-100 bg-gradient from-brand-50 to-brand-50">
                <div class="flex items-center space-x-3">
                    <div class="w-12 h-8">
                        <img src="{{ asset('images/QuranNoText.png') }}" class="w-full h-full object-contain" alt="Logo">
                    </div>
                    <div>
                        <h1 class="text-xl font-extrabold text-gray-800">QuranMemo</h1>
                        <p class="text-xs text-gray-500 font-medium">Admin Dashboard</p>
                    </div>
                </div>
            </div>

            <!-- Navigation (Profile dihapus dari sidebar) -->
            <nav class="p-4 space-y-1">
                <a href="{{ route('admin.dashboard') }}" 
                   class="sidebar-link flex items-center space-x-3 px-4 py-3 rounded-xl font-medium text-sm {{ request()->routeIs('admin.dashboard') ? 'active' : 'text-gray-600' }}">
                    <svg class="icon-svg" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2V6zm10 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2V6zM4 16a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2H6a2 2 0 01-2-2v-2zm10 0a2 2 0 012-2h2a2 2 0 012 2v2a2 2 0 01-2 2h-2a2 2 0 01-2-2v-2z"/>
                    </svg>
                    <span>Dashboard</span>
                </a>
                
                <a href="{{ route('admin.users') }}" 
                   class="sidebar-link flex items-center space-x-3 px-4 py-3 rounded-xl font-medium text-sm {{ request()->routeIs('admin.users') ? 'active' : 'text-gray-600' }}">
                    <svg class="icon-svg" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                    </svg>
                    <span>Akun</span>
                </a>
                
                <a href="{{ route('admin.relasi.santri-ustad') }}" 
                   class="sidebar-link flex items-center space-x-3 px-4 py-3 rounded-xl font-medium text-sm {{ request()->routeIs('admin.relasi.santri-ustad') ? 'active' : 'text-gray-600' }}">
                    <svg class="icon-svg" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 13l4 4m0 0l-4 4m4-4h-8"/>
                    </svg>
                    <span>Relasi S-U</span>
                </a>
                
                <a href="{{ route('admin.relasi.santri-orangtua') }}" 
                   class="sidebar-link flex items-center space-x-3 px-4 py-3 rounded-xl font-medium text-sm {{ request()->routeIs('admin.relasi.santri-orangtua') ? 'active' : 'text-gray-600' }}">
                    <svg class="icon-svg" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 4.354a4 4 0 110 5.292M15 21H3v-1a6 6 0 0112 0v1zm0 0h6v-1a6 6 0 00-9-5.197M13 7a4 4 0 11-8 0 4 4 0 018 0z"/>
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 13l4 4m0 0l-4 4m4-4h-8"/>
                    </svg>
                    <span>Relasi S-O</span>
                </a>
            </nav>
        </aside>

        <!-- ============================================ -->
        <!-- MAIN CONTENT                                  -->
        <!-- ============================================ -->
        <main class="flex-1 overflow-y-auto p-8 scrollbar-thin">
            <!-- Top Bar dengan Profile Dropdown -->
            <div x-data="{ profileOpen: false }" class="flex justify-between items-center mb-6 relative">
                <div>   
                    <h2 class="text-2xl font-bold text-gray-800">@yield('page-title', 'Dashboard')</h2>
                    <p class="text-gray-500 text-sm mt-0.5">@yield('page-subtitle', 'Selamat datang di dashboard admin QuranMemo')</p>
                </div>
                
                <!-- Profile Dropdown di Header -->
                <div class="relative">
                    <button @click="profileOpen = !profileOpen" 
                            class="flex items-center space-x-3 bg-white px-4 py-2 rounded-xl shadow-sm border border-gray-100 hover:border-gray-300 transition">
                        <div class="w-9 h-9 gradient-bg rounded-full flex items-center justify-center">
                            <svg class="w-5 h-5 text-white" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                            </svg>
                        </div>
                        <span class="font-medium text-gray-700">{{ session('admin_nama') }}</span>
                        <svg class="w-4 h-4 text-gray-400" :class="{ 'rotate-180': profileOpen }" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7"/>
                        </svg>
                    </button>

                    <!-- Dropdown Profile -->
                    <div x-show="profileOpen" 
                         @click.away="profileOpen = false"
                         class="absolute right-0 mt-2 w-56 bg-white rounded-xl shadow-xl border border-gray-100 overflow-hidden z-20 dropdown-profile"
                         :class="profileOpen ? '' : 'hidden'">
                        <div class="px-4 py-3 border-b border-gray-100 bg-gray-50">
                            <p class="font-medium text-gray-800">{{ session('admin_nama') }}</p>
                            <p class="text-xs text-gray-500">Administrator</p>
                        </div>
                        <a href="{{ route('admin.profile') }}" 
                           class="flex items-center space-x-3 px-4 py-2.5 hover:bg-brand-50 transition text-sm text-gray-700">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
                            </svg>
                            <span>Profile</span>
                        </a>
                        <a href="{{ route('admin.profile') }}" 
                           class="flex items-center space-x-3 px-4 py-2.5 hover:bg-brand-50 transition text-sm text-gray-700 border-t border-gray-100">
                            <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M10.325 4.317c.426-1.756 2.924-1.756 3.35 0a1.724 1.724 0 002.573 1.066c1.543-.94 3.31.826 2.37 2.37a1.724 1.724 0 001.065 2.572c1.756.426 1.756 2.924 0 3.35a1.724 1.724 0 00-1.066 2.573c.94 1.543-.826 3.31-2.37 2.37a1.724 1.724 0 00-2.572 1.065c-.426 1.756-2.924 1.756-3.35 0a1.724 1.724 0 00-2.573-1.066c-1.543.94-3.31-.826-2.37-2.37a1.724 1.724 0 00-1.065-2.572c-1.756-.426-1.756-2.924 0-3.35a1.724 1.724 0 001.066-2.573c-.94-1.543.826-3.31 2.37-2.37.996.608 2.296.07 2.572-1.065z"/>
                                <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M15 12a3 3 0 11-6 0 3 3 0 016 0z"/>
                            </svg>
                            <span>Pengaturan</span>
                        </a>
                        <form method="POST" action="{{ route('admin.logout') }}" class="border-t border-gray-100">
                            @csrf
                            <button type="submit" 
                                    class="w-full flex items-center space-x-3 px-4 py-2.5 hover:bg-red-50 transition text-sm text-red-600">
                                <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M17 16l4-4m0 0l-4-4m4 4H7m6 4v1a3 3 0 01-3 3H6a3 3 0 01-3-3V7a3 3 0 013-3h4a3 3 0 013 3v1"/>
                                </svg>
                                <span>Logout</span>
                            </button>
                        </form>
                    </div>
                </div>
            </div>

            <!-- Flash Messages -->
            @if(session('success'))
                <div class="bg-brand-50 border-l-4 border-brand-500 text-brand-700 px-5 py-4 rounded-xl mb-6 flex items-center">
                    <svg class="w-5 h-5 text-brand-500 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z"/>
                    </svg>
                    {{ session('success') }}
                </div>
            @endif

            @if(session('error'))
                <div class="bg-red-50 border-l-4 border-red-500 text-red-700 px-5 py-4 rounded-xl mb-6 flex items-center">
                    <svg class="w-5 h-5 text-red-500 mr-3" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                    </svg>
                    {{ session('error') }}
                </div>
            @endif

            @yield('content')
        </main>
    </div>

    <!-- Alpine.js -->
    <script defer src="https://cdn.jsdelivr.net/npm/alpinejs@3.x.x/dist/cdn.min.js"></script>
</body>
</html>