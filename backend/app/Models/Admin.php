<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Laravel\Sanctum\HasApiTokens;


class Admin extends Model
{
    use HasApitokens, HasUuids;

    protected $table = 'admin';

    protected $keyType = 'string';

    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = [
        'nik',
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
}