<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Donasi;
use App\Services\MidtransService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class DonasiController extends Controller
{
    protected MidtransService $midtransService;

    public function __construct(MidtransService $midtransService)
    {
        $this->midtransService = $midtransService;
    }

    /**
     * Membuat transaksi donasi
     */
    public function create(Request $request)
    {
        $request->validate([
            'nominal' => 'required|numeric|min:10000',
        ]);

        $orangTua = Auth::user();

        $orderId = 'DON-' . strtoupper(Str::random(8)) . '-' . time();

        $donasi = Donasi::create([
            'orangtua_id'    => $orangTua->id,
            'nominal'        => $request->nominal,
            'status'         => 'pending',
            'order_id'       => $orderId,
            'transaction_id' => null,
            'payment_method' => null,
            'paid_at'        => null,
        ]);

        $response = $this->midtransService->createTransaction([
            'order_id' => $orderId,
            'nominal'  => $request->nominal,
            'nama'     => $orangTua->nama,
            'email'    => $orangTua->email,
        ]);

        if (!$response['success']) {

            return response()->json([
                'success' => false,
                'message' => $response['message']
            ], 500);

        }

        return response()->json([
            'success' => true,
            'message' => 'Transaksi berhasil dibuat.',
            'data' => [
                'donasi' => $donasi,
                'snap_token' => $response['snap_token'],
            ]
        ]);
    }

    /**
     * Riwayat Donasi
     */
    public function riwayat()
    {
        $orangTua = Auth::user();

        $donasi = Donasi::where('orangtua_id', $orangTua->id)
            ->latest()
            ->get();

        return response()->json([
            'success' => true,
            'data' => $donasi,
        ]);
    }

    /**
     * Status Donasi
     */
    public function status($orderId)
    {
        $donasi = Donasi::where('order_id', $orderId)->firstOrFail();

        // Jika di DB masih pending, coba tarik status asli dari server Midtrans
        // Ini sangat berguna untuk Localhost/Laragon di mana Webhook (Ngrok) sering tidak sampai.
        if ($donasi->status === 'pending') {
            try {
                $statusMidtrans = \Midtrans\Transaction::status($orderId);
                
                $transactionStatus = $statusMidtrans->transaction_status ?? '';

                if (in_array($transactionStatus, ['capture', 'settlement'])) {
                    $donasi->status = 'success';
                    $donasi->paid_at = now();
                    $donasi->save();
                } elseif (in_array($transactionStatus, ['deny', 'expire', 'cancel'])) {
                    $donasi->status = 'failed';
                    $donasi->save();
                }
            } catch (\Exception $e) {
                // Abaikan jika orderId belum terekam penuh di sisi Midtrans
            }
        }

        return response()->json([
            'success' => true,
            'data' => $donasi,
        ]);
    }

    /**
     * Callback Midtrans
     */
    public function webhook(Request $request)
    {
        $payload = $request->all();

        $donasi = Donasi::where('order_id', $payload['order_id'])->first();

        if (!$donasi) {

            return response()->json([
                'success' => false,
                'message' => 'Donasi tidak ditemukan.'
            ], 404);

        }

        switch ($payload['transaction_status']) {

            case 'capture':
            case 'settlement':

                $donasi->status = 'success';
                $donasi->paid_at = now();

                break;

            case 'pending':

                $donasi->status = 'pending';

                break;

            case 'deny':
            case 'expire':
            case 'cancel':

                $donasi->status = 'failed';

                break;
        }

        $donasi->transaction_id = $payload['transaction_id'] ?? null;
        $donasi->payment_method = $payload['payment_type'] ?? null;

        $donasi->save();

        return response()->json([
            'success' => true,
            'message' => 'Webhook berhasil diproses.'
        ]);
    }
}