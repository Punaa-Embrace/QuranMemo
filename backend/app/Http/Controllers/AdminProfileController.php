<?php

namespace App\Http\Controllers;

use App\Models\Admin;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AdminProfileController extends Controller
{
    public function edit()
    {
        $admin = Admin::find(session('admin_id'));
        return view('admin.profile', compact('admin'));
    }

    public function update(Request $request)
    {
        $admin = Admin::find(session('admin_id'));

        $request->validate([
            'nama' => 'required|string|max:255',
            'email' => 'required|email|unique:admin,email,' . $admin->id . ',id',
        ]);

        $data = [
            'nama' => $request->nama,
            'email' => $request->email,
        ];

        if ($request->filled('password')) {
            $request->validate([
                'password' => 'min:6|confirmed',
            ]);
            $data['password'] = Hash::make($request->password);
        }

        $admin->update($data);

        session()->put('admin_nama', $admin->nama);

        return back()->with('success', 'Profile berhasil diupdate');
    }
}