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

        // Ambil semua setoran dari santri binaan, sertakan relasi santri
        $setoran = SetoranHafalan::with('santriUstad.santri')
            ->whereHas('santriUstad', function ($query) use ($santriIds) {
                $query->whereIn('santri_id', $santriIds);
            })->orderBy('id', 'desc')->get();

        return response()->json([
            'success' => true,
            'data'    => $setoran
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

        // Ambil roadmap/riwayat revisi untuk surah dan ayat ini
        $roadmap = SetoranHafalan::where('santri_ustad_id', $setoran->santri_ustad_id)
            ->where('surat', $setoran->surat)
            ->where('ayat', $setoran->ayat)
            ->orderBy('id', 'asc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $setoran,
            'roadmap' => $roadmap
        ]);
    }

    // ============================================
    // 4. BUAT TUGAS SETORAN UNTUK SANTRI
    // ============================================

    public function createTugas(Request $request)
    {
        $request->validate([
            'santri_id' => 'required|exists:santri,id',
            'surat'     => 'required|string',
            'ayat'      => 'required|integer',
        ]);

        $ustad = Auth::user();

        // Cek relasi santri-ustad
        $santriUstad = SantriUstad::where('ustad_id', $ustad->id)
            ->where('santri_id', $request->santri_id)
            ->first();

        if (!$santriUstad) {
            return response()->json([
                'success' => false,
                'message' => 'Santri ini bukan binaan Anda'
            ], 403);
        }

        // ============================================================
        // CEK AYAT TERAKHIR — Jika ayat yang ditugaskan <= ayat yang
        // sudah selesai pada surah yang sama, berarti sudah pernah
        // diselesaikan. Ustad harus memberi tugas ayat berikutnya.
        // ============================================================
        $ayatTerakhir = AyatTerakhir::where('santri_id', $request->santri_id)
            ->where('surat', $request->surat)
            ->orderBy('ayat', 'desc')
            ->first();

        if ($ayatTerakhir && $request->ayat <= $ayatTerakhir->ayat) {
            return response()->json([
                'success' => false,
                'message' => "Surah {$request->surat} sudah diselesaikan sampai ayat {$ayatTerakhir->ayat}. Berikan tugas mulai ayat " . ($ayatTerakhir->ayat + 1) . " ke atas."
            ], 400);
        }

        // Cek apakah tugas yang sama sudah ada dan masih aktif
        $existing = SetoranHafalan::where('santri_ustad_id', $santriUstad->id)
            ->where('surat', $request->surat)
            ->where('ayat', $request->ayat)
            ->whereIn('status', ['tugas', 'dikirim', 'feedback'])
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Tugas untuk surah dan ayat ini sudah ada dan belum selesai'
            ], 400);
        }

        // Buat tugas — status 'tugas' artinya menunggu santri menyetorkan video
        $setoran = SetoranHafalan::create([
            'santri_ustad_id' => $santriUstad->id,
            'surat'           => $request->surat,
            'ayat'            => $request->ayat,
            'status'          => 'tugas',
        ]);

        // Kirim notifikasi FCM ke Santri
        $santriModel = \App\Models\Santri::find($request->santri_id);
        if ($santriModel && $santriModel->fcm_token) {
            FcmHelper::send(
                $santriModel->fcm_token,
                'Ada Tugas Hafalan Baru!',
                "Ustad memberi tugas: Surah {$request->surat} Ayat {$request->ayat}. Yuk segera setor!",
                ['type' => 'tugas_baru', 'setoran_id' => $setoran->id]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Tugas berhasil diberikan',
            'data'    => $setoran
        ]);
    }

    // ============================================
    // 5. KASIH FEEDBACK TULISAN
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
            'voice_note' => 'required|file|mimetypes:audio/ogg,audio/mp4,audio/x-m4a,audio/aac,audio/mpeg,audio/wav|max:10240'
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
    // ============================================
    // 7. STREAM VIDEO SETORAN (SUPPORT RANGE REQUEST)
    // ============================================

    public function streamVideo(Request $request, $id)
    {
        $ustad = Auth::user();
        $setoran = SetoranHafalan::with('santriUstad')->findOrFail($id);

        $santriIds = SantriUstad::where('ustad_id', $ustad->id)->pluck('santri_id');
        if (!$santriIds->contains($setoran->santriUstad->santri_id)) {
            return response()->json(['message' => 'Unauthorized'], 403);
        }

        $videoPath = storage_path('app/public/' . $setoran->video_path);

        if (!file_exists($videoPath)) {
            return response()->json(['message' => 'Video tidak ditemukan'], 404);
        }

        $size     = filesize($videoPath);
        $mimeType = mime_content_type($videoPath) ?: 'video/mp4';
        $start    = 0;
        $end      = $size - 1;
        $status   = 200;
        $headers  = [
            'Content-Type'              => $mimeType,
            'Accept-Ranges'             => 'bytes',
            'Content-Disposition'       => 'inline',
            'Cache-Control'             => 'no-cache',
        ];

        if ($request->hasHeader('Range')) {
            $range = $request->header('Range');
            preg_match('/bytes=(\d*)-(\d*)/', $range, $matches);

            $start = intval($matches[1] ?? 0);
            $end   = intval($matches[2] ?? 0) ?: $end;

            if ($start > $end || $start >= $size || $end >= $size) {
                return response('', 416, ['Content-Range' => "bytes */$size"]);
            }

            $status = 206;
            $headers['Content-Range'] = "bytes $start-$end/$size";
        }

        $length = $end - $start + 1;
        $headers['Content-Length'] = $length;

        $stream = fopen($videoPath, 'rb');
        fseek($stream, $start);

        return response()->stream(function () use ($stream, $length) {
            $remaining = $length;
            $chunkSize = 1024 * 64; 
            while ($remaining > 0 && !feof($stream)) {
                $read = min($chunkSize, $remaining);
                echo fread($stream, $read);
                $remaining -= $read;
                flush();
            }
            fclose($stream);
        }, $status, $headers);
    }
}