<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Laravel\Sanctum\HasApiTokens;

class Santri extends Model
{
    use HasApiTokens, HasUuids; 

    protected $table = 'santri';
    protected $keyType = 'string';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'nim',
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
        return $this->hasMany(SantriUstad::class, 'santri_id');
    }

    public function santriOrangtua()
    {
        return $this->hasMany(SantriOrangtua::class, 'santri_id');
    }

    public function ayatTerakhir()
    {
        return $this->hasMany(AyatTerakhir::class, 'santri_id');
    }

    public function leaderboard()
    {
        return $this->hasMany(Leaderboard::class, 'santri_id');
    }
}