<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\LeaderboardController;
use App\Http\Controllers\Api\SantriController;
use App\Http\Controllers\Api\UstadController;
use App\Http\Controllers\Api\OrangtuaController;
use App\Http\Controllers\Api\DonasiController;
use Illuminate\Support\Facades\Route;

// ============================================
// PUBLIC ROUTES (TANPA TOKEN)
// ============================================
Route::post('/', [AuthController::class, 'login']);
Route::post('/login', [AuthController::class, 'login']);

// ============================================
// PROTECTED ROUTES (PAKAI TOKEN)
// ============================================

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/me', [AuthController::class, 'me']);
    Route::put('/me', [AuthController::class, 'updateProfile']);
    Route::put('/me/fcm-token', [AuthController::class, 'updateFcmToken']);
    Route::put('/change-password', [AuthController::class, 'changePassword']);
});

// ============================================
// ROUTE SANTRI
// ============================================

Route::middleware(['auth:sanctum', 'role:santri'])->prefix('santri')->group(function () {
    Route::post('/setoran', [SantriController::class, 'storeSetoran']);
    Route::get('/setoran', [SantriController::class, 'getSetoran']);
    Route::get('/setoran/{id}/stream', [SantriController::class, 'streamVideo']);
    Route::get('/progress', [SantriController::class, 'getProgress']);
    Route::put('/ayat-terakhir', [SantriController::class, 'updateAyatTerakhir']);
    Route::post('/leaderboard', [SantriController::class, 'tambahPoin']); //  TAMBAHKAN
});

// ============================================
// ROUTE USTAD
// ============================================

Route::middleware(['auth:sanctum', 'role:ustad'])->prefix('ustad')->group(function () {
    Route::get('/santri', [UstadController::class, 'getSantriBinaan']);
    Route::get('/setoran', [UstadController::class, 'getSetoran']);
    Route::get('/setoran/{id}', [UstadController::class, 'detailSetoran']);
    Route::post('/setoran/{id}/feedback', [UstadController::class, 'giveFeedback']);
    Route::put('/setoran/{id}/status', [UstadController::class, 'updateStatus']);
    Route::post('/setoran/{id}/voice-note', [UstadController::class, 'uploadVoiceNote']);
});

// ============================================
// ROUTE LEADERBOARD (SEMUA ROLE BISA LIHAT)
// ============================================

Route::middleware('auth:sanctum')->group(function () {
    Route::get('/leaderboard', [LeaderboardController::class, 'index']);
    Route::get('/leaderboard/top', [LeaderboardController::class, 'top']);
});

// SANTRI TAMBAH POIN
Route::middleware(['auth:sanctum', 'role:santri'])->prefix('santri')->group(function () {
    Route::post('/leaderboard', [SantriController::class, 'tambahPoin']);
});

// ============================================
// ROUTE ORANG TUA
// ============================================

Route::middleware(['auth:sanctum', 'role:orangtua'])->prefix('orangtua')->group(function () {
    Route::get('/anak', [OrangtuaController::class, 'getAnak']);
    Route::get('/anak/{id}/progress', [OrangtuaController::class, 'getProgressAnak']);

    Route::post('/donasi', [DonasiController::class, 'create']);
    Route::get('/donasi/riwayat', [DonasiController::class, 'riwayat']);
    Route::get('/donasi/status/{orderId}', [DonasiController::class, 'status']);
});

// ============================================
// MIDTRANS WEBHOOK
// ============================================
Route::post('/midtrans/webhook', [DonasiController::class, 'webhook']);