import 'package:quranmemo/services/api_service.dart';

class DonasiService {
  // ============================================
  // 1. BUAT DONASI
  // ============================================
  static Future<Map<String, dynamic>> createDonasi(int nominal) async {
    try {
      final response = await ApiService.createDonasi(nominal);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal membuat donasi: $e',
      };
    }
  }

  // ============================================
  // 2. RIWAYAT DONASI
  // ============================================
  static Future<Map<String, dynamic>> getRiwayatDonasi() async {
    try {
      final response = await ApiService.getRiwayatDonasi();
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil riwayat donasi: $e',
      };
    }
  }

  // ============================================
  // 3. STATUS DONASI
  // ============================================
  static Future<Map<String, dynamic>> getStatusDonasi(String orderId) async {
    try {
      final response = await ApiService.getStatusDonasi(orderId);
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Gagal mengambil status donasi: $e',
      };
    }
  }
}