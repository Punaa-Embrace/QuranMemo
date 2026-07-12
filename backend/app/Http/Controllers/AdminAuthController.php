<?php

namespace App\Http\Controllers;

use App\Models\Admin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminAuthController extends Controller
{
    public function showLogin()
    {
        return view('admin.auth.login');
    }

    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);

        $admin = Admin::where('email', $request->email)->first();

        if (!$admin) {
            return back()->with('error', 'Email tidak ditemukan');
        }

        if (!Hash::check($request->password, $admin->password)) {
            return back()->with('error', 'Password salah');
        }

        session()->put('admin_id', $admin->id);
        session()->put('admin_nama', $admin->nama);

        return redirect()->route('admin.dashboard');
    }

    public function logout()
    {
        session()->forget(['admin_id', 'admin_nama']);
        return redirect()->route('admin.login');
    }
}