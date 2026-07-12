<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AdminAuthController;
use App\Http\Controllers\AdminController;
use App\Http\Controllers\AdminUserController;
use App\Http\Controllers\AdminRelasiController;
use App\Http\Controllers\AdminProfileController;

// ============================================
// AUTH ADMIN (TANPA MIDDLEWARE)
// ============================================

Route::get('/admin/login', [AdminAuthController::class, 'showLogin'])->name('admin.login');
Route::post('/admin/login', [AdminAuthController::class, 'login'])->name('admin.login.submit'); 

// ============================================
// ADMIN (PAKAI MIDDLEWARE)
// ============================================

Route::middleware(['admin'])->prefix('admin')->name('admin.')->group(function () {

    // DASHBOARD
    Route::get('/dashboard', [AdminController::class, 'dashboard'])->name('dashboard');

    // LOGOUT
    Route::post('/logout', [AdminAuthController::class, 'logout'])->name('logout');

    // ============================================
    // USERS (1 ROUTE UNTUK SEMUA ROLE)
    // ============================================

    Route::get('/users', [AdminUserController::class, 'index'])->name('users');
    Route::post('/users', [AdminUserController::class, 'store'])->name('users.store');
    Route::put('/users/{id}', [AdminUserController::class, 'update'])->name('users.update');
    Route::delete('/users/{id}', [AdminUserController::class, 'destroy'])->name('users.destroy');

    // ============================================
    // RELASI
    // ============================================

    Route::get('/relasi/santri-ustad', [AdminRelasiController::class, 'santriUstad'])->name('relasi.santri-ustad');
    Route::post('/relasi/santri-ustad', [AdminRelasiController::class, 'storeSantriUstad'])->name('relasi.santri-ustad.store');
    Route::delete('/relasi/santri-ustad/{id}', [AdminRelasiController::class, 'destroySantriUstad'])->name('relasi.santri-ustad.destroy');

    Route::get('/relasi/santri-orangtua', [AdminRelasiController::class, 'santriOrangtua'])->name('relasi.santri-orangtua');
    Route::post('/relasi/santri-orangtua', [AdminRelasiController::class, 'storeSantriOrangtua'])->name('relasi.santri-orangtua.store');
    Route::delete('/relasi/santri-orangtua/{id}', [AdminRelasiController::class, 'destroySantriOrangtua'])->name('relasi.santri-orangtua.destroy');

    // ============================================
    // PROFILE
    // ============================================

    Route::get('/profile', [AdminProfileController::class, 'edit'])->name('profile');
    Route::put('/profile', [AdminProfileController::class, 'update'])->name('profile.update');

});