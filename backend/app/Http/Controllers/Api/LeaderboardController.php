<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Leaderboard;
use Illuminate\Http\Request;

class LeaderboardController extends Controller
{
    // ============================================
    // 1. LIHAT SEMUA PERINGKAT
    // ============================================

    public function index()
    {
        $leaderboard = Leaderboard::with('santri')
            ->orderBy('nilai', 'desc')
            ->get()
            ->map(function ($item, $index) {
                return [
                    'rank' => $index + 1,
                    'santri' => [
                        'id' => $item->santri->id,
                        'nama' => $item->santri->nama,
                        'nim' => $item->santri->nim,
                        'email' => $item->santri->email,
                    ],
                    'nilai' => $item->nilai,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $leaderboard
        ]);
    }

    // ============================================
    // 2. TOP 10 SANTRI
    // ============================================

    public function top()
    {
        $leaderboard = Leaderboard::with('santri')
            ->orderBy('nilai', 'desc')
            ->limit(10)
            ->get()
            ->map(function ($item, $index) {
                return [
                    'rank' => $index + 1,
                    'santri' => [
                        'id' => $item->santri->id,
                        'nama' => $item->santri->nama,
                        'nim' => $item->santri->nim,
                    ],
                    'nilai' => $item->nilai,
                ];
            });

        return response()->json([
            'success' => true,
            'data' => $leaderboard
        ]);
    }
}