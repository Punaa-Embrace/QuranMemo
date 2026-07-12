<?php

namespace App\Http\Controllers;

use App\Models\Santri;
use App\Models\Ustad;
use App\Models\Orangtua;
use App\Models\Role;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class AdminUserController extends Controller
{
    private function getModel($role)
    {
        return match ($role) {
            'santri' => new Santri(),
            'ustad' => new Ustad(),
            'orangtua' => new Orangtua(),
            default => new Santri(),
        };
    }

    private function getFields($role)
    {
        return match ($role) {
            'santri' => ['nim', 'nama', 'email'],
            'ustad' => ['nik', 'nama', 'email'],
            'orangtua' => ['nama', 'email'],
            default => ['nim', 'nama', 'email'],
        };
    }

    public function index(Request $request)
{
    $role = $request->query('role', 'all');

    // 1. Kumpulkan semua data dari setiap role
    $santriData = Santri::with('roleData')->get()->map(function($item) {
        return (object) [
            'id' => $item->id,
            'nim' => $item->nim ?? '-',
            'nik' => '-',
            'nama' => $item->nama,
            'email' => $item->email,
            'role_display' => 'santri',
            'role_key' => 'santri',
            'unique_field' => $item->nim,
            'unique_label' => 'NIM',
            'original' => $item,
        ];
    });

    $ustadData = Ustad::with('roleData')->get()->map(function($item) {
        return (object) [
            'id' => $item->id,
            'nim' => '-',
            'nik' => $item->nik ?? '-',
            'nama' => $item->nama,
            'email' => $item->email,
            'role_display' => 'ustad',
            'role_key' => 'ustad',
            'unique_field' => $item->nik,
            'unique_label' => 'NIK',
            'original' => $item,
        ];
    });

    $orangtuaData = Orangtua::with('roleData')->get()->map(function($item) {
        return (object) [
            'id' => $item->id,
            'nim' => '-',
            'nik' => '-',
            'nama' => $item->nama,
            'email' => $item->email,
            'role_display' => 'orangtua',
            'role_key' => 'orangtua',
            'unique_field' => '-',
            'unique_label' => '-',
            'original' => $item,
        ];
    });

    // 2. Gabungkan semua data
    $allData = $santriData->concat($ustadData)->concat($orangtuaData);

    // 3. Tentukan data dan fields berdasarkan filter
    if ($role === 'all') {
        $data = $allData->sortBy('nama');
        $fields = ['nama', 'email']; // Field yang ditampilkan untuk semua role
        $total = [
            'all' => Santri::count() + Ustad::count() + Orangtua::count(),
            'santri' => Santri::count(),
            'ustad' => Ustad::count(),
            'orangtua' => Orangtua::count(),
        ];
    } else {
        // Filter berdasarkan role tertentu
        $model = $this->getModel($role);
        $data = $model->with('roleData')->get();
        $fields = $this->getFields($role);
        $total = [
            'all' => Santri::count() + Ustad::count() + Orangtua::count(),
            'santri' => Santri::count(),
            'ustad' => Ustad::count(),
            'orangtua' => Orangtua::count(),
        ];
    }

    $roles = [
        'all' => 'Semua Role',
        'santri' => 'Santri',
        'ustad' => 'Ustad',
        'orangtua' => 'Orang Tua',
    ];

    return view('admin.users', compact('role', 'data', 'fields', 'total', 'roles'));
}

    public function store(Request $request)
    {
        $role = $request->input('role', 'santri');

        $model = $this->getModel($role);
        $fields = $this->getFields($role);

        $rules = [];
        foreach ($fields as $field) {
            if ($field === 'email') {
                $rules[$field] = 'required|email|unique:' . $model->getTable() . ',email';
            } elseif ($field === 'nim' || $field === 'nik') {
                $rules[$field] = 'required|string|unique:' . $model->getTable() . ',' . $field;
            } else {
                $rules[$field] = 'required|string';
            }
        }

        $request->validate($rules);

        $roleId = Role::where('role_name', $role)->first()->id;

        $data = $request->only($fields);
        $data['password'] = Hash::make('password123');
        $data['token'] = Str::random(60);
        $data['role'] = $roleId;

        $model->create($data);

        return redirect()
            ->route('admin.users', ['role' => $role])
            ->with('success', ucfirst($role) . ' berhasil ditambahkan');
    }

    public function update(Request $request, $id)
    {
        $role = $request->input('role', 'santri');

        $model = $this->getModel($role);
        $user = $model->findOrFail($id);

        $request->validate([
            'nama' => 'required|string',
            'email' => 'required|email|unique:' . $model->getTable() . ',email,' . $id . ',id',
        ]);

        $user->update($request->only(['nama', 'email']));

        return redirect()
            ->route('admin.users', ['role' => $role])
            ->with('success', ucfirst($role) . ' berhasil diupdate');
    }

    public function destroy(Request $request, $id)
    {
        $role = $request->query('role', 'santri');

        $model = $this->getModel($role);
        $user = $model->findOrFail($id);
        $user->delete();

        return redirect()
            ->route('admin.users', ['role' => $role])
            ->with('success', ucfirst($role) . ' berhasil dihapus');
    }
}