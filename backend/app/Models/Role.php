<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Role extends Model
{
    use HasUuids;

    protected $table = 'role';

    protected $keyType = 'string';

    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = [
        'role_name'
    ];

    public function santri()
    {
        return $this->hasMany(Santri::class, 'role');
    }

    public function ustad()
    {
        return $this->hasMany(Ustad::class, 'role');
    }

    public function admin()
    {
        return $this->hasMany(Admin::class, 'role');
    }

    public function orangtua()
    {
        return $this->hasMany(Orangtua::class, 'role');
    }
}