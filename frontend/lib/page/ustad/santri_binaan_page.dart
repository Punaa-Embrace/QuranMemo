import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/ustad_service.dart';
import 'santri_detail_page.dart';

class SantriBinaanPage extends StatefulWidget {
  const SantriBinaanPage({super.key});

  @override
  State<SantriBinaanPage> createState() => _SantriBinaanPageState();
}

class _SantriBinaanPageState extends State<SantriBinaanPage> {
  List<Map<String, dynamic>> _daftarSantri = [];
  List<Map<String, dynamic>> _allSetoran = [];
  bool _isLoading = true;
  String _searchText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      final santriRes = await UstadService.getSantriBinaan();
      final setoranRes = await UstadService.getSetoran();

      if (santriRes['success'] == true) {
        final List raw = santriRes['data'] ?? [];
        _daftarSantri = raw.map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s)).toList();
      }

      if (setoranRes['success'] == true) {
        final List raw = setoranRes['data'] ?? [];
        _allSetoran = raw.map<Map<String, dynamic>>((s) => Map<String, dynamic>.from(s)).toList();
      }
    } catch (e) {
      debugPrint('Error fetching santri binaan: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _filteredSantri {
    if (_searchText.isEmpty) return _daftarSantri;
    return _daftarSantri.where((s) {
      final nama = (s['nama'] ?? '').toString().toLowerCase();
      return nama.contains(_searchText.toLowerCase());
    }).toList();
  }

  List<Map<String, dynamic>> _getSetoranForSantri(Map<String, dynamic> santri) {
    final santriId = santri['id'];
    return _allSetoran.where((item) {
      try {
        return item['santri_ustad']?['santri']?['id'] == santriId;
      } catch (_) {
        return false;
      }
    }).toList();
  }

  String _getInitials(String nama) {
    final parts = nama.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildSearchBar(),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _buildContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.groups_rounded, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              const Text(
                'Daftar Santri Binaan',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${_daftarSantri.length} santri terdaftar',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: TextField(
        controller: _searchController,
        onChanged: (val) => setState(() => _searchText = val),
        decoration: InputDecoration(
          hintText: 'Cari nama santri...',
          hintStyle: TextStyle(color: Colors.grey.shade500, fontSize: 14),
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchText.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _searchText = '');
                  },
                )
              : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 1.5),
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    final filtered = _filteredSantri;
    if (filtered.isEmpty) return _buildEmptyState();

    return RefreshIndicator(
      onRefresh: _fetchData,
      color: AppTheme.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        itemCount: filtered.length,
        itemBuilder: (context, index) {
          final santri = filtered[index];
          final setoranList = _getSetoranForSantri(santri);
          return _buildSantriCard(santri, setoranList);
        },
      ),
    );
  }

  Widget _buildSantriCard(Map<String, dynamic> santri, List<Map<String, dynamic>> setoranList) {
    final nama = santri['nama'] ?? 'Santri';
    final nim = santri['nim'] ?? '-';
    final initials = _getInitials(nama.toString());

    final selesai = setoranList.where((s) => s['status'] == 'selesai').length;
    final pending = setoranList.where((s) => s['status'] == 'dikirim').length;
    final total = setoranList.length;
    final progress = total > 0 ? selesai / total : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SantriDetailPage(
                  santri: santri,
                  setoranList: setoranList,
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Avatar with initials
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.secondaryColor,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nama.toString(),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.badge_outlined, size: 13, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                nim.toString(),
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  ],
                ),
                const SizedBox(height: 14),

                // Stats row
                Row(
                  children: [
                    _buildStatBadge(
                      icon: Icons.check_circle_outline,
                      label: 'Selesai',
                      count: selesai,
                      color: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    _buildStatBadge(
                      icon: Icons.hourglass_empty_rounded,
                      label: 'Menunggu',
                      count: pending,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    _buildStatBadge(
                      icon: Icons.list_alt_rounded,
                      label: 'Total',
                      count: total,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progress Hafalan',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${(progress * 100).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 7,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(height: 3),
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.groups_outlined,
              size: 60,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Tidak ada santri ditemukan',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchText.isNotEmpty
                ? 'Coba gunakan kata kunci lain'
                : 'Belum ada santri yang terdaftar',
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
