<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login Admin - QuranMemo</title>
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
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        * { font-family: 'Inter', sans-serif; }
        .gradient-bg { background: linear-gradient(135deg, #188F48 0%, #4E8F28 100%); }
    </style>
</head>
<body class="min-h-screen flex items-center justify-center px-4 bg-[#f8fafc]">
    <div class="w-full max-w-md bg-white rounded-2xl shadow-2xl p-8">
        <!-- Logo -->
        <div class="text-center mb-8">
            <div class="w-20 h-20 gradient-bg rounded-2xl flex items-center justify-center mx-auto mb-4 shadow-lg shadow-[#188F48]/30">
                <img src="{{ asset('images/QuranNoText.png') }}" class="w-14 h-14 object-contain" alt="Logo">
            </div>
            <h1 class="text-2xl font-extrabold text-gray-800">QuranMemo Admin</h1>
            <p class="text-gray-500 text-sm mt-1">Masuk ke dashboard manajemen</p>
        </div>

        @if(session('error'))
            <div class="bg-red-50 border border-red-200 text-red-600 px-4 py-3 rounded-xl mb-6 text-sm flex items-center">
                <svg class="w-5 h-5 mr-2 text-red-500" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                    <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M12 9v2m0 4h.01m-6.938 4h13.856c1.54 0 2.502-1.667 1.732-3L13.732 4c-.77-1.333-2.694-1.333-3.464 0L3.34 16c-.77 1.333.192 3 1.732 3z"/>
                </svg>
                {{ session('error') }}
            </div>
        @endif

        <form method="POST" action="{{ route('admin.login.submit') }}">
            @csrf
            <div class="space-y-4">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                    <input type="email" name="email" value="{{ old('email') }}"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#188F48] focus:border-transparent transition"
                           placeholder="nama@quran.com" required>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Password</label>
                    <input type="password" name="password"
                           class="w-full px-4 py-3 border border-gray-200 rounded-xl focus:outline-none focus:ring-2 focus:ring-[#188F48] focus:border-transparent transition"
                           placeholder="••••••••" required>
                </div>
                <button type="submit" 
                        class="w-full gradient-bg hover:opacity-90 text-white py-3 rounded-xl font-semibold transition">
                    Masuk
                </button>
            </div>
        </form>

        <p class="text-center text-xs text-gray-400 mt-6">QuranMemo - Sistem Manajemen Hafalan Quran</p>
    </div>
</body>
</html>