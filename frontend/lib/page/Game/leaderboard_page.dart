import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/leaderboard_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<dynamic> _leaderboard = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await LeaderboardService.getLeaderboard();
      
      if (response['success'] == true) {
        setState(() {
          _leaderboard = response['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = response['message'] ?? 'Gagal memuat leaderboard';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Terjadi kesalahan: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.primaryColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    "Leaderboard Lengkap",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_leaderboard.length} Santri',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // LOADING / ERROR / LIST
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage.isNotEmpty
                      ? _buildErrorWidget()
                      : _leaderboard.isEmpty
                          ? _buildEmptyWidget()
                          : _buildLeaderboardList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              _errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadLeaderboard,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.emoji_events, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Belum ada data leaderboard',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              'Mainkan game untuk mendapatkan poin!',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardList() {
    // TOP 3
    final top3 = _leaderboard.take(3).toList();

    return Column(
      children: [
        // MEDALS - TOP 3
        if (top3.length >= 3)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.amber.shade700, Colors.amber.shade900],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildMedal(2, Colors.grey.shade400, Icons.emoji_events, top3[1]),
                _buildMedal(1, Colors.amber, Icons.emoji_events, top3[0]),
                _buildMedal(3, Colors.brown.shade300, Icons.emoji_events, top3[2]),
              ],
            ),
          ),

        // LIST
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _leaderboard.length,
            itemBuilder: (context, index) {
              final item = _leaderboard[index];
              final santri = item['santri'] ?? {};
              return _buildLeaderboardItem(
                rank: item['rank'] ?? index + 1,
                name: santri['nama'] ?? 'Santri',
                score: item['nilai'] ?? 0,
                isMe: false,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMedal(int rank, Color color, IconData icon, dynamic data) {
    final santri = data['santri'] ?? {};
    final name = santri['nama'] ?? 'Santri';
    final score = data['nilai'] ?? 0;

    Color getRankColor() {
      if (rank == 1) return Colors.amber;
      if (rank == 2) return Colors.grey.shade400;
      if (rank == 3) return Colors.brown.shade300;
      return Colors.grey;
    }

    String getRankText() {
      if (rank == 1) return 'Juara 1';
      if (rank == 2) return 'Juara 2';
      if (rank == 3) return 'Juara 3';
      return '';
    }

    List<Color> getAvatarGradient() {
      if (rank == 1) return [Colors.amber.shade300, Colors.amber.shade700];
      if (rank == 2) return [Colors.grey.shade300, Colors.grey.shade600];
      if (rank == 3) return [Colors.brown.shade300, Colors.brown.shade600];
      return [AppTheme.primaryColor, AppTheme.primaryColor];
    }

    return Column(
      children: [
        // Avatar dengan gradient
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: getAvatarGradient(),
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: getRankColor().withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'S',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 28,
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        // Nama
        Text(
          name.length > 8 ? name.substring(0, 6) + '..' : name,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        // Rank
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            getRankText(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Score
        Text(
          '$score pts',
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int score,
    required bool isMe,
  }) {
    Color? getRankColor() {
      if (rank == 1) return Colors.amber;
      if (rank == 2) return Colors.grey.shade400;
      if (rank == 3) return Colors.brown.shade300;
      return null;
    }

    Color getRankTextColor() {
      if (rank == 1) return Colors.amber.shade700;
      if (rank == 2) return Colors.grey.shade700;
      if (rank == 3) return Colors.brown.shade700;
      return Colors.grey.shade600;
    }

    List<Color> getAvatarGradient() {
      if (rank == 1) return [Colors.amber.shade300, Colors.amber.shade700];
      if (rank == 2) return [Colors.grey.shade300, Colors.grey.shade600];
      if (rank == 3) return [Colors.brown.shade300, Colors.brown.shade600];
      return [AppTheme.primaryColor, AppTheme.primaryColor];
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: AppTheme.primaryColor, width: 2) : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rank
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: getRankColor()?.withOpacity(0.2) ?? Colors.grey.shade100,
              shape: BoxShape.circle,
              border: getRankColor() != null ? Border.all(color: getRankColor()!, width: 2) : null,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      Icons.emoji_events,
                      color: getRankColor(),
                      size: 20,
                    )
                  : Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: getRankTextColor(),
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Avatar
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: getAvatarGradient(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          // Nama & Poin
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.w500,
                        fontSize: 14,
                        color: rank == 1 ? Colors.amber.shade700 : null,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Anda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                    if (rank == 1 && !isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.amber.shade300),
                        ),
                        child: Text(
                          'Juara',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber.shade700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      size: 12,
                      color: rank == 1 ? Colors.amber : Colors.amber.shade200,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$score poin',
                      style: TextStyle(
                        fontSize: 11,
                        color: rank == 1 ? Colors.amber.shade700 : Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Bonus Poin
          if (rank <= 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: getRankColor()?.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: getRankColor()?.withOpacity(0.3) ?? Colors.transparent),
              ),
              child: Text(
                rank == 1 ? '+100' : rank == 2 ? '+50' : '+25',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: getRankTextColor(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}