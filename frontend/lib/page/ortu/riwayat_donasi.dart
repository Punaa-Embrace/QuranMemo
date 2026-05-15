import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../components/custom_header.dart';
import 'donasi_page.dart'; // 🔥 TAMBAHKAN untuk navigasi donasi

class RiwayatDonasiPage extends StatelessWidget {
  const RiwayatDonasiPage({Key? key}) : super(key: key);

  final List<Map<String, dynamic>> _riwayatDonasi = const [
    {
      'id': 'TRX1703123456789',
      'tanggal': '20 April 2026',
      'nominal': '50.000',
      'metode': 'Bank Transfer',
      'status': 'success',
      'icon': Icons.account_balance,
      'color': Color(0xFF1E88E5),
    },
    {
      'id': 'TRX1703123456790',
      'tanggal': '15 Maret 2026',
      'nominal': '25.000',
      'metode': 'QRIS',
      'status': 'success',
      'icon': Icons.qr_code_scanner,
      'color': Color(0xFF00A86B),
    },
    {
      'id': 'TRX1703123456791',
      'tanggal': '10 Februari 2026',
      'nominal': '100.000',
      'metode': 'E-Wallet',
      'status': 'success',
      'icon': Icons.phone_android,
      'color': Color(0xFF5E35B1),
    },
    {
      'id': 'TRX1703123456792',
      'tanggal': '5 Januari 2026',
      'nominal': '10.000',
      'metode': 'Bank Transfer',
      'status': 'success',
      'icon': Icons.account_balance,
      'color': Color(0xFF1E88E5),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E2D1),
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "Riwayat Donasi",
              imagePath: "assets/images/self.jpg",
              showAvatar: true,
              showSearch: false,
              showBackButton: true,
              isParent: true,
            ),
            Expanded(
              child: _riwayatDonasi.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _riwayatDonasi.length,
                      itemBuilder: (context, index) {
                        final item = _riwayatDonasi[index];
                        return _buildRiwayatCard(context, item);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Belum ada riwayat donasi',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Yuk donasi sekarang untuk mendukung QuranMemo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DonasiPage()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Donasi Sekarang'),
          ),
        ],
      ),
    );
  }

  Widget _buildRiwayatCard(BuildContext context, Map<String, dynamic> item) {
    final bool isSuccess = item['status'] == 'success';
    
    return GestureDetector(
      onTap: () {
        _showDetailDonasi(context, item);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            /// Icon metode pembayaran
            Container(
              width: 55,
              height: 55,
              decoration: BoxDecoration(
                color: (item['color'] as Color).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Icon(item['icon'], color: item['color'], size: 28),
              ),
            ),
            const SizedBox(width: 16),
            
            /// Detail donasi
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Rp ${item['nominal']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isSuccess 
                              ? Colors.green.withOpacity(0.1)
                              : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          isSuccess ? 'Berhasil' : 'Pending',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: isSuccess ? Colors.green : Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['metode'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['tanggal'],
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),
            
            /// Arrow icon (opsional, sebagai indikator bisa diklik)
            Icon(
              Icons.chevron_right,
              size: 24,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailDonasi(BuildContext context, Map<String, dynamic> item) {
    final bool isSuccess = item['status'] == 'success';
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Center(
                child: Container(
                  width: 50,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSuccess 
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isSuccess ? Icons.check_circle : Icons.pending,
                    size: 48,
                    color: isSuccess ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  isSuccess ? 'Donasi Berhasil' : 'Donasi Pending',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isSuccess ? Colors.green : Colors.orange,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              
              /// Detail
              _buildDetailRow('Kode Transaksi', item['id']),
              const SizedBox(height: 12),
              _buildDetailRow('Tanggal', item['tanggal']),
              const SizedBox(height: 12),
              _buildDetailRow('Nominal', 'Rp ${item['nominal']}'),
              const SizedBox(height: 12),
              _buildDetailRow('Metode Pembayaran', item['metode']),
              const SizedBox(height: 12),
              _buildDetailRow('Status', isSuccess ? 'Berhasil' : 'Pending'),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Tutup'),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}