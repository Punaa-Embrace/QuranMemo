<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Laravel\Sanctum\HasApiTokens;

class Ustad extends Model
{
    use HasApiTokens, HasUuids;

    protected $table = 'ustad';

    protected $keyType = 'string';

    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = [
        'nik',
        'email',
        'nama',
        'password',
        'token',
        'role',
        'fcm_token',
    ];

        protected $hidden = [
        'password',
        'token',
    ];

    public function roleData()
    {
        return $this->belongsTo(Role::class, 'role');
    }

    public function santriUstad()
    {
        return $this->hasMany(SantriUstad::class, 'ustad_id');
    }
}