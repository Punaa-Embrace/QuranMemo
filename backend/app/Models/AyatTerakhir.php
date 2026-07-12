<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class AyatTerakhir extends Model
{
    use HasUuids;

    protected $table = 'ayat_terakhir';

    protected $keyType = 'string';

    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = [
        'santri_id',
        'surat',
        'ayat',
    ];

    public function santri()
    {
        return $this->belongsTo(Santri::class, 'santri_id');
    }
}