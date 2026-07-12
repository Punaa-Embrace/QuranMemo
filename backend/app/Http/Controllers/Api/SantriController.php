<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\SantriUstad;
use App\Models\SetoranHafalan;
use App\Models\AyatTerakhir;
use App\Models\Leaderboard;
use App\Models\Ustad;
use App\Helpers\FcmHelper;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;

class SantriController extends Controller
{
    // ============================================
    // 1. KIRIM SETORAN HAFALAN
    // ============================================

    public function storeSetoran(Request $request)
    {
        $request->validate([
            'surat' => 'required|string',
            'ayat' => 'required|integer',
            'video' => 'required|file|mimes:mp4,mov,avi|max:102400',
        ]);

        $santri = Auth::user();

        // CEK AYAT TERAKHIR PER SURAT
        $ayatTerakhir = AyatTerakhir::where('santri_id', $santri->id)
            ->where('surat', $request->surat)
            ->orderBy('id', 'desc')
            ->first();

        if ($ayatTerakhir && $request->ayat <= $ayatTerakhir->ayat) {
            return response()->json([
                'success' => false,
                'message' => 'Ayat ini sudah dihafal sebelumnya. Silakan setor ayat ' . ($ayatTerakhir->ayat + 1) . ' ke atas untuk surat ini.'
            ], 400);
        }

        // CEK DUPLIKAT SETORAN (SURAT + AYAT YANG SAMA)
        $existing = SetoranHafalan::whereHas('santriUstad', function ($query) use ($santri) {
            $query->where('santri_id', $santri->id);
        })->where('surat', $request->surat)
          ->where('ayat', $request->ayat)
          ->first();

        if ($existing) {
            if ($existing->status === 'dikirim' || $existing->status === 'feedback') {
                return response()->json([
                    'success' => false,
                    'message' => 'Setoran sedang menunggu feedback ustad.'
                ], 400);
            }

            if ($existing->status === 'revisi') {
                $existing->delete();
            }

            if ($existing->status === 'selesai') {
                return response()->json([
                    'success' => false,
                    'message' => 'Ayat ini sudah selesai dihafal.'
                ], 400);
            }
        }

        // CEK RELASI SANTRI-USTAD
        $santriUstad = SantriUstad::where('santri_id', $santri->id)->first();

        if (!$santriUstad) {
            return response()->json([
                'success' => false,
                'message' => 'Santri belum memiliki ustad pembimbing'
            ], 400);
        }

        // UPLOAD VIDEO
        $fileName = 'video_' . time() . '.mp4';
        $videoPath = $request->file('video')->storeAs('setoran', $fileName, 'public');

        // SIMPAN SETORAN
        $setoran = SetoranHafalan::create([
            'santri_ustad_id' => $santriUstad->id,
            'surat'          => $request->surat,
            'ayat'           => $request->ayat,
            'status'         => 'dikirim',
            'video_path'     => $videoPath,
        ]);

        // Kirim notifikasi FCM ke Ustad
        $ustad = Ustad::find($santriUstad->ustad_id);
        if ($ustad && $ustad->fcm_token) {
            FcmHelper::send(
                $ustad->fcm_token,
                'Setoran Hafalan Baru!',
                "{$santri->nama} mengirim setoran Surah {$request->surat}. Yuk segera direview!",
                ['type' => 'setoran_baru', 'setoran_id' => $setoran->id]
            );
        }

        return response()->json([
            'success' => true,
            'message' => 'Setoran berhasil dikirim',
            'data'    => $setoran
        ], 201);
    }

    // ============================================
    // 2. RIWAYAT SETORAN SANTRI
    // ============================================

    public function getSetoran(Request $request)
    {
        $santri = Auth::user();

        $santriUstad = SantriUstad::where('santri_id', $santri->id)->first();

        if (!$santriUstad) {
            return response()->json([
                'success' => false,
                'message' => 'Santri belum memiliki ustad pembimbing'
            ], 400);
        }

        $setoran = SetoranHafalan::where('santri_ustad_id', $santriUstad->id)
            ->orderBy('id', 'desc')
            ->get();

        return response()->json([
            'success' => true,
            'data' => $setoran
        ]);
    }

    // ============================================
    // 3. PROGRESS HAFALAN
    // ============================================

    public function getProgress(Request $request)
    {
        $santri = Auth::user();

        $ayatTerakhir = AyatTerakhir::where('santri_id', $santri->id)
            ->orderBy('id', 'desc')
            ->first();

        // AMBIL SEMUA AYAT TERAKHIR PER SURAT
        $allAyatTerakhir = AyatTerakhir::where('santri_id', $santri->id)
            ->orderBy('surat', 'asc')
            ->orderBy('ayat', 'desc')
            ->get()
            ->groupBy('surat')
            ->map(function ($group) {
                return $group->first();
            });

        $totalSetoran = SetoranHafalan::whereHas('santriUstad', function ($query) use ($santri) {
            $query->where('santri_id', $santri->id);
        })->count();

        $setoranSelesai = SetoranHafalan::whereHas('santriUstad', function ($query) use ($santri) {
            $query->where('santri_id', $santri->id);
        })->where('status', 'selesai')->count();

        // TOTAL AYAT SELESAI (SEMUA SURAT)
        $totalAyatSelesai = SetoranHafalan::whereHas('santriUstad', function ($query) use ($santri) {
            $query->where('santri_id', $santri->id);
        })->where('status', 'selesai')->sum('ayat');

        $totalAyatTarget = 6236;

        return response()->json([
            'success' => true,
            'data' => [
                'ayat_terakhir' => $ayatTerakhir,
                'all_ayat_terakhir' => $allAyatTerakhir,
                'total_setoran' => $totalSetoran,
                'setoran_selesai' => $setoranSelesai,
                'total_ayat_selesai' => $totalAyatSelesai,
                'total_ayat_target' => $totalAyatTarget,
                'progress_percent' => $totalAyatTarget > 0 ? round(($totalAyatSelesai / $totalAyatTarget) * 100, 2) : 0,
            ]
        ]);
    }

    // ============================================
    // 4. UPDATE AYAT TERAKHIR
    // ============================================

    public function updateAyatTerakhir(Request $request)
    {
        $request->validate([
            'surat' => 'required|string',
            'ayat' => 'required|integer',
        ]);

        $santri = Auth::user();

        // CEK APAKAH SUDAH ADA AYAT TERAKHIR UNTUK SURAT INI
        $existing = AyatTerakhir::where('santri_id', $santri->id)
            ->where('surat', $request->surat)
            ->first();

        if ($existing) {
            if ($request->ayat > $existing->ayat) {
                $existing->update(['ayat' => $request->ayat]);
            }
            $ayatTerakhir = $existing;
        } else {
            $ayatTerakhir = AyatTerakhir::create([
                'santri_id' => $santri->id,
                'surat' => $request->surat,
                'ayat' => $request->ayat,
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Ayat terakhir berhasil diupdate',
            'data' => $ayatTerakhir
        ]);
    }

    // ============================================
    // 5. TAMBAH POIN LEADERBOARD (GAMIFIKASI)
    // ============================================

    public function tambahPoin(Request $request)
    {
        $request->validate([
            'poin' => 'required|integer|min:1'
        ]);

        $santri = Auth::user();

        $leaderboard = Leaderboard::where('santri_id', $santri->id)->first();

        if ($leaderboard) {
            $leaderboard->nilai += $request->poin;
            $leaderboard->save();
        } else {
            $leaderboard = Leaderboard::create([
                'santri_id' => $santri->id,
                'nilai' => $request->poin
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Poin berhasil ditambahkan',
            'data' => $leaderboard
        ]);
    }

    // ============================================
    // 6. STREAM VIDEO SETORAN (SUPPORT RANGE REQUEST)
    // ============================================

    public function streamVideo(Request $request, $id)
    {
        $setoran = SetoranHafalan::findOrFail($id);

        // Pastikan yang akses adalah santri yang bersangkutan
        $santri = Auth::user();
        $santriUstad = SantriUstad::where('santri_id', $santri->id)->first();

        if (!$santriUstad || $setoran->santri_ustad_id !== $santriUstad->id) {
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

        // Handle Range Request
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
            $chunkSize = 1024 * 64; // 64KB per chunk
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