<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class SetoranHafalan extends Model
{
    use HasUuids;

    protected $table = 'setoran_hafalan';

    protected $keyType = 'string';

    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = [
        'santri_ustad_id',
        'surat',
        'ayat',
        'status',
        'feedback_tulisan',
        'feedback_vn_path',
        'video_path',
    ];

    public function santriUstad()
    {
        return $this->belongsTo(SantriUstad::class, 'santri_ustad_id');
    }
}