<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SantriOrangtua;
use App\Models\SetoranHafalan;
use App\Models\AyatTerakhir;
use App\Models\Leaderboard;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class OrangtuaController extends Controller
{
    // ============================================
    // 1. LIHAT DAFTAR ANAK (SANTRI)
    // ============================================

    public function getAnak()
    {
        $orangtua = Auth::user();

        $anak = SantriOrangtua::where('orangtua_id', $orangtua->id)
            ->with('santri')
            ->get()
            ->pluck('santri');

        return response()->json([
            'success' => true,
            'data' => $anak
        ]);
    }

    // ============================================
    // 2. LIHAT PROGRESS HAFALAN ANAK
    // ============================================

    public function getProgressAnak($id)
    {
        $orangtua = Auth::user();

        // Cek apakah anak ini terhubung dengan orangtua ini
        $relasi = SantriOrangtua::where('orangtua_id', $orangtua->id)
            ->where('santri_id', $id)
            ->first();

        if (!$relasi) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki akses ke santri ini'
            ], 403);
        }

        // Ambil data progress santri
        $ayatTerakhir = AyatTerakhir::where('santri_id', $id)
            ->orderBy('id', 'desc')
            ->first();

        $totalSetoran = SetoranHafalan::whereHas('santriUstad', function ($query) use ($id) {
            $query->where('santri_id', $id);
        })->count();

        $setoranSelesai = SetoranHafalan::whereHas('santriUstad', function ($query) use ($id) {
            $query->where('santri_id', $id);
        })->where('status', 'selesai')->count();

        $totalAyatSelesai = SetoranHafalan::whereHas('santriUstad', function ($query) use ($id) {
            $query->where('santri_id', $id);
        })->where('status', 'selesai')->sum('ayat');

        $totalAyatTarget = 6236;

        // Ambil leaderboard
        $leaderboard = Leaderboard::where('santri_id', $id)->first();

        return response()->json([
            'success' => true,
            'data' => [
                'santri_id' => $id,
                'ayat_terakhir' => $ayatTerakhir,
                'total_setoran' => $totalSetoran,
                'setoran_selesai' => $setoranSelesai,
                'total_ayat_selesai' => $totalAyatSelesai,
                'total_ayat_target' => $totalAyatTarget,
                'progress_percent' => $totalAyatTarget > 0 ? round(($totalAyatSelesai / $totalAyatTarget) * 100, 2) : 0,
                'leaderboard' => $leaderboard ? $leaderboard->nilai : 0,
            ]
        ]);
    }
}