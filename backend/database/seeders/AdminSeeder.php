<?php

namespace Database\Seeders;

use App\Models\Admin;
use App\Models\Role;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class AdminSeeder extends Seeder
{
    public function run(): void
    {
        //PASTIKAN ROLE ADA
        $adminRole = Role::firstOrCreate(
            ['role_name' => 'admin'],
            ['role_name' => 'admin']
        );

        //CEK APAKAH ADMIN SUDAH ADA
        $admin = Admin::where('email', 'admin@quranmemo.com')->first();

        if (!$admin) {
            Admin::create([
                'nik' => 'ADM001',
                'email' => 'admin@quranmemo.com',
                'nama' => 'Super Admin',
                'password' => Hash::make('putsya123'),
                'token' => null,
                'role' => $adminRole->id,
            ]);
        }
    }
}