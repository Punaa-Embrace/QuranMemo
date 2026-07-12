import 'package:flutter/material.dart';
import '../../services/donasi_service.dart';
import '../../theme/app_theme.dart';
import '../../components/custom_header.dart';
import 'donasi_page.dart';

class RiwayatDonasiPage extends StatefulWidget {
  const RiwayatDonasiPage({Key? key}) : super(key: key);

  @override
  State<RiwayatDonasiPage> createState() => _RiwayatDonasiPageState();
}

class _RiwayatDonasiPageState extends State<RiwayatDonasiPage> {
  List<Map<String, dynamic>> _riwayatDonasi = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRiwayatDonasi();
  }

  Future<void> _fetchRiwayatDonasi() async {
    setState(() => _isLoading = true);

    //  PAKAI DONASI SERVICE
    final response = await DonasiService.getRiwayatDonasi();

    setState(() => _isLoading = false);

    if (response['success'] == true) {
      final List rawData = response['data'];
      setState(() {
        _riwayatDonasi = rawData.map((item) {
          final status = item['status'] ?? 'pending';
          return {
            'id': item['order_id'] ?? '-',
            'order_id': item['order_id'] ?? '-',
            'tanggal': _formatDate(item['created_at']),
            'paid_at': item['paid_at'],
            'nominal': _formatNominal(item['nominal']),
            'nominal_raw': item['nominal'] ?? 0,
            'metode': item['payment_method'] ?? 'Belum dibayar',
            'status': status,
            'icon': _getPaymentIcon(item['payment_method']),
            'color': _getPaymentColor(item['payment_method']),
          };
        }).toList();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response['message'] ?? 'Gagal mengambil riwayat donasi'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatNominal(int? nominal) {
    if (nominal == null) return '0';
    return nominal.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]}.',
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return '-';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day} ${_getMonthName(date.month)} ${date.year}';
    } catch (e) {
      return dateString;
    }
  }

  String _getMonthName(int month) {
    const months = [
      'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
      'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'
    ];
    return months[month - 1];
  }

  IconData _getPaymentIcon(String? method) {
    if (method == null) return Icons.payment;
    if (method.contains('bank') || method.contains('transfer')) {
      return Icons.account_balance;
    } else if (method.contains('qris')) {
      return Icons.qr_code_scanner;
    } else if (method.contains('ewallet') || method.contains('gopay')) {
      return Icons.phone_android;
    }
    return Icons.payment;
  }

  Color _getPaymentColor(String? method) {
    if (method == null) return Colors.grey;
    if (method.contains('bank') || method.contains('transfer')) {
      return const Color(0xFF1E88E5);
    } else if (method.contains('qris')) {
      return const Color(0xFF00A86B);
    } else if (method.contains('ewallet') || method.contains('gopay')) {
      return const Color(0xFF5E35B1);
    }
    return Colors.grey;
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'success':
        return 'Berhasil';
      case 'pending':
        return 'Pending';
      case 'failed':
        return 'Gagal';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

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
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _riwayatDonasi.isEmpty
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
            decoration: const BoxDecoration(
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
              Navigator.pushReplacement(
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
    final bool isPending = item['status'] == 'pending';
    final bool isFailed = item['status'] == 'failed';

    Color statusColor;
    String statusText;
    if (isSuccess) {
      statusColor = Colors.green;
      statusText = 'Berhasil';
    } else if (isPending) {
      statusColor = Colors.orange;
      statusText = 'Pending';
    } else if (isFailed) {
      statusColor = Colors.red;
      statusText = 'Gagal';
    } else {
      statusColor = Colors.grey;
      statusText = item['status'];
    }

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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['metode'] ?? 'Belum dibayar',
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
    final bool isPending = item['status'] == 'pending';
    final bool isFailed = item['status'] == 'failed';

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (isSuccess) {
      statusText = 'Donasi Berhasil';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    } else if (isPending) {
      statusText = 'Menunggu Pembayaran';
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
    } else if (isFailed) {
      statusText = 'Donasi Gagal';
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
    } else {
      statusText = 'Status Tidak Diketahui';
      statusColor = Colors.grey;
      statusIcon = Icons.help;
    }

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
                    color: statusColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    statusIcon,
                    size: 48,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(
                child: Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),

              /// Detail
              _buildDetailRow('Order ID', item['order_id'] ?? '-'),
              const SizedBox(height: 12),
              _buildDetailRow('Tanggal', item['tanggal']),
              const SizedBox(height: 12),
              _buildDetailRow('Nominal', 'Rp ${item['nominal']}'),
              const SizedBox(height: 12),
              _buildDetailRow('Metode Pembayaran', item['metode'] ?? 'Belum dibayar'),
              const SizedBox(height: 12),
              _buildDetailRow('Status', statusText),
              if (item['paid_at'] != null) ...[
                const SizedBox(height: 12),
                _buildDetailRow(
                  'Dibayar Pada',
                  _formatDate(item['paid_at']),
                ),
              ],

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