<?php

namespace App\Services;

use Midtrans\Config;
use Midtrans\Snap;

class MidtransService
{
    public function __construct()
    {
        Config::$serverKey = config('midtrans.server_key');
        Config::$clientKey = config('midtrans.client_key');
        Config::$isProduction = config('midtrans.is_production');
        Config::$isSanitized = config('midtrans.is_sanitized');
        Config::$is3ds = config('midtrans.is_3ds');
    }

    /**
     * Membuat transaksi Midtrans Snap
     */
    public function createTransaction(array $data)
    {
        $params = [

            'transaction_details' => [
                'order_id'     => $data['order_id'],
                'gross_amount' => $data['nominal'],
            ],

            'customer_details' => [
                'first_name' => $data['nama'],
                'email'      => $data['email'],
            ],

        ];

        try {

            $snapToken = Snap::getSnapToken($params);

            return [
                'success'    => true,
                'snap_token' => $snapToken,
            ];

        } catch (\Exception $e) {

            return [
                'success' => false,
                'message' => $e->getMessage(),
            ];

        }
    }
}