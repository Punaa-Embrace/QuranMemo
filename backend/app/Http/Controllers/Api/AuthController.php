<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Santri;
use App\Models\Ustad;
use App\Models\Admin;
use App\Models\Orangtua;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    public function login(Request $request)
{
    try {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        $user = $this->findUserByEmail($request->email);

        if (!$user) {
            throw ValidationException::withMessages([
                'email' => ['Email tidak terdaftar.'],
            ]);
        }

        if (!Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'password' => ['Password salah.'],
            ]);
        }

        // Hapus token lama
        $user->tokens()->delete();

        // Buat token baru
        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login berhasil',
            'data' => [
                'user' => [
                    'id' => $user->id,
                    'nama' => $user->nama,
                    'email' => $user->email,
                    'role' => $user->roleData->role_name ?? 'unknown',
                    'nik' => $user->nik ?? null,
                    'nim' => $user->nim ?? null,
                ],
                'token' => $token,
                'token_type' => 'Bearer',
            ]
        ]);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage(),
            'line' => $e->getLine(),
            'file' => $e->getFile()
        ], 500);
    }
}

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logout berhasil'
        ]);
    }

    public function me(Request $request)
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'data' => [
                'id' => $user->id,
                'nama' => $user->nama,
                'email' => $user->email,
                'role' => $user->roleData->role_name ?? 'unknown',
                'nik' => $user->nik ?? null,
                'nim' => $user->nim ?? null,
            ]
        ]);
    }

    public function updateProfile(Request $request)
{
    $request->validate([
        'nama' => 'required|string|max:255',
        'email' => 'required|email|unique:santri,email,' . $request->user()->id . ',id|unique:ustad,email,' . $request->user()->id . ',id|unique:admin,email,' . $request->user()->id . ',id|unique:orangtua,email,' . $request->user()->id . ',id',
    ]);

    $user = $request->user();
    $user->nama = $request->nama;
    $user->email = $request->email;
    $user->save();

    return response()->json([
        'success' => true,
        'message' => 'Profile berhasil diupdate',
        'data' => [
            'id' => $user->id,
            'nama' => $user->nama,
            'email' => $user->email,
            'role' => $user->roleData->role_name ?? 'unknown',
        ]
    ]);
}

    private function findUserByEmail($email)
    {
        $admin = Admin::where('email', $email)->first();
        if ($admin)
            return $admin;

        $ustad = Ustad::where('email', $email)->first();
        if ($ustad)
            return $ustad;

        $santri = Santri::where('email', $email)->first();
        if ($santri)
            return $santri;

        $orangtua = Orangtua::where('email', $email)->first();
        if ($orangtua)
            return $orangtua;

        return null;
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required|string',
            'new_password' => 'required|string|min:6',
            'new_password_confirmation' => 'required|same:new_password',
        ]);

        $user = $request->user();

        if (!Hash::check($request->old_password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Password lama salah'
            ], 400);
        }

        $user->password = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password berhasil diubah'
        ]);
    }

    // ============================================
    // UPDATE FCM TOKEN
    // ============================================
    public function updateFcmToken(Request $request)
    {
        $request->validate([
            'fcm_token' => 'required|string',
        ]);

        $user = $request->user();
        $user->fcm_token = $request->fcm_token;
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'FCM token berhasil disimpan',
        ]);
    }
}