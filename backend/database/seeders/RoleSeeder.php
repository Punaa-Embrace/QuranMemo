<?php

namespace Database\Seeders;

use App\Models\Role;
use Illuminate\Database\Seeder;

class RoleSeeder extends Seeder
{
    public function run(): void
    {
        Role::firstOrCreate(
            ['role_name' => 'admin'],
            ['role_name' => 'admin']
        );

        Role::firstOrCreate(
            ['role_name' => 'ustad'],
            ['role_name' => 'ustad']
        );

        Role::firstOrCreate(
            ['role_name' => 'santri'],
            ['role_name' => 'santri']
        );

        Role::firstOrCreate(
            ['role_name' => 'orangtua'],
            ['role_name' => 'orangtua']
        );
    }
}