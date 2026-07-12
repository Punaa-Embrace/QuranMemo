<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class SantriUstad extends Model
{
    use HasUuids;

    protected $table = 'santri_ustad';
    protected $keyType = 'string';
    public $incrementing = false;
    public $timestamps = false;

    protected $fillable = [
        'santri_id',
        'ustad_id'
    ];

    public function santri()
    {
        return $this->belongsTo(Santri::class, 'santri_id');
    }

    public function ustad()
    {
        return $this->belongsTo(Ustad::class, 'ustad_id');
    }

    public function setoranHafalan()
    {
        return $this->hasMany(SetoranHafalan::class, 'santri_ustad_id');
    }
}