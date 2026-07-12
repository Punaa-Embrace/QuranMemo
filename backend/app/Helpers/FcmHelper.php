<?php

namespace App\Helpers;

use Google\Auth\Credentials\ServiceAccountCredentials;
use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class FcmHelper
{
    // ============================================
    // KIRIM PUSH NOTIFIKASI KE SATU DEVICE (HTTP v1)
    // ============================================
    public static function send(
        string $fcmToken,
        string $title,
        string $body,
        array $data = []
    ): void {
        try {
            $keyFilePath = storage_path('app/firebase-credentials.json');
            
            if (!file_exists($keyFilePath)) {
                Log::error('FCM Error: File credentials ' . $keyFilePath . ' tidak ditemukan.');
                return;
            }

            // Baca file JSON untuk mendapatkan Project ID
            $keyData = json_decode(file_get_contents($keyFilePath), true);
            $projectId = $keyData['project_id'] ?? null;

            if (!$projectId) {
                Log::error('FCM Error: Project ID tidak ditemukan di dalam JSON.');
                return;
            }

            // Generate OAuth 2.0 Token menggunakan google/auth
            $scopes = ['https://www.googleapis.com/auth/firebase.messaging'];
            $credentials = new ServiceAccountCredentials($scopes, $keyFilePath);
            $tokenArray = $credentials->fetchAuthToken();

            if (!isset($tokenArray['access_token'])) {
                Log::error('FCM Error: Gagal mendapatkan Access Token dari Google.');
                return;
            }

            $accessToken = $tokenArray['access_token'];
            $endpoint = "https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send";

            // Pastikan semua value di data payload adalah string (syarat FCM HTTP v1)
            $stringData = [];
            foreach ($data as $key => $value) {
                $stringData[(string) $key] = (string) $value;
            }

            // Kirim request POST ke FCM API v1
            $response = Http::withHeaders([
                'Authorization' => 'Bearer ' . $accessToken,
                'Content-Type'  => 'application/json',
            ])->post($endpoint, [
                'message' => [
                    'token' => $fcmToken,
                    'notification' => [
                        'title' => $title,
                        'body'  => $body,
                    ],
                    'data' => $stringData,
                    'android' => [
                        'notification' => [
                            'sound' => 'default'
                        ]
                    ]
                ],
            ]);

            if (!$response->successful()) {
                Log::error('FCM Error Response: ' . $response->body());
            }
        } catch (\Exception $e) {
            Log::error('FCM Exception: ' . $e->getMessage());
        }
    }
}
