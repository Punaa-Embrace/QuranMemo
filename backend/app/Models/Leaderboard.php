<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Leaderboard extends Model
{
    use HasUuids;

    protected $table = 'leaderboard';

    protected $keyType = 'string';

    public $incrementing = false;

    public $timestamps = false;

    protected $fillable = [
        'santri_id',
        'nilai'
    ];

    public function santri()
    {
        return $this->belongsTo(Santri::class, 'santri_id');
    }
}