<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Concerns\HasUuids;

class Donasi extends Model
{
    use HasUuids;

    protected $table = 'donasi';

    protected $keyType = 'string';

    public $incrementing = false;

    public $timestamps = true;

    protected $fillable = [
        'orangtua_id',
        'nominal',
        'status',
        'order_id',
        'transaction_id',
        'payment_method',
        'paid_at',
    ];

    protected $casts = [
        'paid_at' => 'datetime',
    ];

    /**
     * Relasi Donasi -> Orang Tua
     */
    public function orangTua()
    {
        return $this->belongsTo(
            Orangtua::class,
            'orangtua_id',
            'id'
        );
    }
}