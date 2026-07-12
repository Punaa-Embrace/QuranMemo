<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class SantriOrangtua extends Model
{
    use HasUuids;

    protected $table = 'santri_orangtua';

    protected $keyType = 'string';

    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = [
        'santri_id',
        'orangtua_id',
    ];

    public function santri()
    {
        return $this->belongsTo(Santri::class, 'santri_id');
    }

    public function orangtua()
    {
        return $this->belongsTo(Orangtua::class, 'orangtua_id');
    }
}