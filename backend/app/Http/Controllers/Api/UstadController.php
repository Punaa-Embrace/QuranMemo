<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SantriUstad;
use App\Models\SetoranHafalan;
use App\Models\AyatTerakhir;
use App\Models\Leaderboard;
use App\Helpers\FcmHelper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class UstadController extends Controller
{
    // ============================================
    // 1. LIHAT SANTRI BINAAN
    // ============================================

    public function getSantriBinaan()
    {
        $ustad = Auth::user();

        $santri = SantriUstad::where('ustad_id', $ustad->id)
            ->with('santri')
            ->get()
            ->pluck('santri');

        return response()->json([
            'success' => true,
            'data' => $santri
        ]);
    }

    // ============================================
    // 2. LIHAT SETORAN SANTRI BINAAN
    // ============================================

    public function getSetoran(Request $request)
    {
        $ustad = Auth::user();

        // Ambil semua santri binaan ustad ini
        $santriIds = SantriUstad::where('ustad_id', $ustad->id)
            ->pluck('santri_id');

        // Ambil semua setoran dari santri binaan
        $setoran = SetoranHafalan::whereHas('santriUstad', function ($query) use ($santriIds) {
            $query->whereIn('santri_id', $santriIds);
        })->orderBy('id', 'desc')->get();

        return response()->json([
            'success' => true,
            'data' => $setoran
        ]);
    }

    // ============================================
    // 3. DETAIL SETORAN + VIDEO
    // ============================================

    public function detailSetoran($id)
    {
        $ustad = Auth::user();

        $setoran = SetoranHafalan::with('santriUstad.santri')
            ->findOrFail($id);

        // Cek apakah setoran ini milik santri binaan ustad ini
        $santriIds = SantriUstad::where('ustad_id', $ustad->id)
            ->pluck('santri_id');

        if (!$santriIds->contains($setoran->santriUstad->santri_id)) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki akses ke setoran ini'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $setoran
        ]);
    }

    // ============================================
    // 4. KASIH FEEDBACK TULISAN
    // ============================================

    public function giveFeedback(Request $request, $id)
    {
        $request->validate([
            'feedback_tulisan' => 'required|string'
        ]);

        $ustad = Auth::user();

        $setoran = SetoranHafalan::with('santriUstad.santri')
            ->findOrFail($id);

        // Cek akses
        $santriIds = SantriUstad::where('ustad_id', $ustad->id)
            ->pluck('santri_id');

        if (!$santriIds->contains($setoran->santriUstad->santri_id)) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki akses ke setoran ini'
            ], 403);
        }

        $setoran->feedback_tulisan = $request->feedback_tulisan;
        $setoran->status = 'feedback'; // Status berubah jadi feedback
        $setoran->save();

        // Kirim notifikasi FCM ke Santri
        $santri = $setoran->santriUstad->santri;
        if ($santri->fcm_token) {
            FcmHelper::send(
                $santri->fcm_token,
                'Ada Feedback dari Ustadmu!',
                "Setoran Surah {$setoran->surat} mendapat catatan dari Ustad. Cek sekarang!",
                ['type' => 'feedback', 'setoran_id' => $setoran->id]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Feedback berhasil dikirim',
            'data' => $setoran
        ]);
    }

    // ============================================
    // 5. UBAH STATUS SETORAN
    // ============================================

    public function updateStatus(Request $request, $id)
    {
        $request->validate([
            'status' => 'required|in:selesai,revisi'
        ]);

        $ustad = Auth::user();

        $setoran = SetoranHafalan::with('santriUstad.santri')
            ->findOrFail($id);

        // Cek akses
        $santriIds = SantriUstad::where('ustad_id', $ustad->id)
            ->pluck('santri_id');

        if (!$santriIds->contains($setoran->santriUstad->santri_id)) {
            return response()->json([
                'success' => false,
                'message' => 'Anda tidak memiliki akses ke setoran ini'
            ], 403);
        }

        $setoran->status = $request->status;
        $setoran->save();

        // Kirim notifikasi FCM ke Santri
        $santri = $setoran->santriUstad->santri;
        if ($santri->fcm_token) {
            if ($request->status === 'selesai') {
                FcmHelper::send(
                    $santri->fcm_token,
                    'Hafalan Dinyatakan Selesai!',
                    "Surah {$setoran->surat} hafalan kamu sudah selesai. Pertahankan!",
                    ['type' => 'status_selesai', 'setoran_id' => $setoran->id]
                );
            } else {
                FcmHelper::send(
                    $santri->fcm_token,
                    'Hafalan Perlu Diperbaiki',
                    "Surah {$setoran->surat} perlu direvisi. Cek feedback dari Ustad ya!",
                    ['type' => 'status_revisi', 'setoran_id' => $setoran->id]
                );
            }
        }

        // Jika status selesai, update ayat_terakhir
        if ($request->status === 'selesai') {
            // Update ayat terakhir
            AyatTerakhir::create([
                'santri_id' => $setoran->santriUstad->santri_id,
                'surat' => $setoran->surat,
                'ayat' => $setoran->ayat,
            ]);

            // Update leaderboard (gamifikasi)
            $totalAyatSelesai = SetoranHafalan::whereHas('santriUstad', function ($query) use ($setoran) {
                $query->where('santri_id', $setoran->santriUstad->santri_id);
            })->where('status', 'selesai')->sum('ayat');

            $nilai = $totalAyatSelesai * 10;

            Leaderboard::updateOrCreate(
                ['santri_id' => $setoran->santriUstad->santri_id],
                ['nilai' => $nilai]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Status berhasil diupdate menjadi ' . $request->status,
            'data' => $setoran
        ]);
    }

    // ============================================
    // 6. UPLOAD VOICE NOTE FEEDBACK 
    // ============================================

    public function uploadVoiceNote(Request $request, $id)
    {
        $request->validate([
            'voice_note' => 'required|file|mimes:mp3,wav,ogg|max:10240' // Max 10 MB
        ]);

        $setoran = SetoranHafalan::findOrFail($id);

        // Upload file
        $voicePath = $request->file('voice_note')->store('feedback_voice', 'public');

        // SIMPAN PATH KE KOLOM feedback_vn_path
        $setoran->feedback_vn_path = $voicePath;
        $setoran->save();

        // Kirim notifikasi FCM ke Santri
        $santri = $setoran->santriUstad->santri;
        if ($santri->fcm_token) {
            FcmHelper::send(
                $santri->fcm_token,
                'Ustad Kirim Voice Note!',
                "Ada pesan suara dari Ustad untuk setoran Surah {$setoran->surat}. Dengarkan sekarang!",
                ['type' => 'voice_note', 'setoran_id' => $setoran->id]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Voice note berhasil diupload',
            'data' => $setoran
        ]);
    }
}