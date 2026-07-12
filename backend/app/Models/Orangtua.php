<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Laravel\Sanctum\HasApiTokens;
use App\Models\Donasi;

class Orangtua extends Model
{
    use HasApiTokens, HasUuids;

    protected $table = 'orangtua';

    protected $keyType = 'string';

    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = [
        'email',
        'nama',
        'password',
        'token',
        'role'
    ];
        protected $hidden = [
        'password',
        'token',
    ];

    public function roleData()
    {
        return $this->belongsTo(Role::class, 'role');
    }

    public function santriOrangtua()
    {
        return $this->hasMany(SantriOrangtua::class, 'orangtua_id');
    }

    public function donasi()
    {
        return $this->hasMany(Donasi::class, 'orangtua_id');
    }
}