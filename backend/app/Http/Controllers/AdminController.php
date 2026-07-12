<?php

namespace App\Http\Controllers;

use App\Models\Santri;
use App\Models\Ustad;
use App\Models\Orangtua;

class AdminController extends Controller
{
    public function dashboard()
    {
        $totalSantri = Santri::count();
        $totalUstad = Ustad::count();
        $totalOrangtua = Orangtua::count();

        return view('admin.dashboard', compact(
            'totalSantri',
            'totalUstad',
            'totalOrangtua'
        ));
    }
}