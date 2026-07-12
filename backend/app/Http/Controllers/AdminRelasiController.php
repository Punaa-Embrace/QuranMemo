<?php

namespace App\Http\Controllers;

use App\Models\Santri;
use App\Models\Ustad;
use App\Models\Orangtua;
use App\Models\SantriUstad;
use App\Models\SantriOrangtua;
use Illuminate\Http\Request;

class AdminRelasiController extends Controller
{
    // ============================================
    // RELASI SANTRI - USTAD
    // ============================================

    public function santriUstad()
    {
        $relasi = SantriUstad::with(['santri', 'ustad'])->get();
        $santri = Santri::all();
        $ustad = Ustad::all();

        return view('admin.relasi.santri-ustad', compact('relasi', 'santri', 'ustad'));
    }

    public function storeSantriUstad(Request $request)
    {
        $request->validate([
            'santri_id' => 'required|exists:santri,id',
            'ustad_id' => 'required|exists:ustad,id',
        ]);

        $exists = SantriUstad::where('santri_id', $request->santri_id)
            ->where('ustad_id', $request->ustad_id)
            ->exists();

        if ($exists) {
            return back()->with('error', 'Relasi sudah ada');
        }

        SantriUstad::create([
            'santri_id' => $request->santri_id,
            'ustad_id' => $request->ustad_id,
        ]);

        return back()->with('success', 'Relasi Santri-Ustad berhasil ditambahkan');
    }

    public function destroySantriUstad($id)
    {
        $relasi = SantriUstad::findOrFail($id);
        $relasi->delete();

        return back()->with('success', 'Relasi Santri-Ustad berhasil dihapus');
    }

    // ============================================
    // RELASI SANTRI - ORANGTUA
    // ============================================

    public function santriOrangtua()
    {
        $relasi = SantriOrangtua::with(['santri', 'orangtua'])->get();
        $santri = Santri::all();
        $orangtua = Orangtua::all();

        return view('admin.relasi.santri-orangtua', compact('relasi', 'santri', 'orangtua'));
    }

    public function storeSantriOrangtua(Request $request)
    {
        $request->validate([
            'santri_id' => 'required|exists:santri,id',
            'orangtua_id' => 'required|exists:orangtua,id',
        ]);

        $exists = SantriOrangtua::where('santri_id', $request->santri_id)
            ->where('orangtua_id', $request->orangtua_id)
            ->exists();

        if ($exists) {
            return back()->with('error', 'Relasi sudah ada');
        }

        SantriOrangtua::create([
            'santri_id' => $request->santri_id,
            'orangtua_id' => $request->orangtua_id,
        ]);

        return back()->with('success', 'Relasi Santri-Orangtua berhasil ditambahkan');
    }

    public function destroySantriOrangtua($id)
    {
        $relasi = SantriOrangtua::findOrFail($id);
        $relasi->delete();

        return back()->with('success', 'Relasi Santri-Orangtua berhasil dihapus');
    }
}