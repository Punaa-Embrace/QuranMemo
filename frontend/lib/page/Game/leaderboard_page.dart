import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class LeaderboardPage extends StatelessWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Data dummy leaderboard lengkap 
    final List<Map<String, dynamic>> allLeaderboard = [
      {'rank': 1, 'name': 'Budi Syah Putra', 'score': 1250, 'avatar': 'A', 'isMe': true},
      {'rank': 2, 'name': 'Fatra Syahreza', 'score': 980, 'avatar': 'B', 'isMe': false},
      {'rank': 3, 'name': 'Denny Riansyah', 'score': 870, 'avatar': 'C', 'isMe': false},
      {'rank': 4, 'name': 'Raffi Bayu Andhika', 'score': 760, 'avatar': 'D', 'isMe': false},
      {'rank': 5, 'name': 'Eko Prasetyo', 'score': 650, 'avatar': 'E', 'isMe': false},
      {'rank': 6, 'name': 'Fajar Nugroho', 'score': 540, 'avatar': 'F', 'isMe': false},
      {'rank': 7, 'name': 'Gita Sari', 'score': 430, 'avatar': 'G', 'isMe': false},
      {'rank': 8, 'name': 'Hendra Wijaya', 'score': 320, 'avatar': 'H', 'isMe': false},
      {'rank': 9, 'name': 'Indah Permata', 'score': 210, 'avatar': 'I', 'isMe': false},
      {'rank': 10, 'name': 'Joko Susilo', 'score': 100, 'avatar': 'J', 'isMe': false},
      {'rank': 11, 'name': 'Kartika Sari', 'score': 95, 'avatar': 'K', 'isMe': false},
      {'rank': 12, 'name': 'Lukman Hakim', 'score': 80, 'avatar': 'L', 'isMe': false},
      {'rank': 13, 'name': 'Maya Sari', 'score': 70, 'avatar': 'M', 'isMe': false},
      {'rank': 14, 'name': 'Nugroho', 'score': 60, 'avatar': 'N', 'isMe': false},
      {'rank': 15, 'name': 'Oktaviani', 'score': 50, 'avatar': 'O', 'isMe': false},
    ];

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // PERBAIKAN: Jangan pakai CustomHeader, pakai AppBar biasa
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
                    onTap: () {
                      Navigator.pop(context);
                    },
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
                ],
              ),
            ),
            
            /// Header Peringkat Top 3 (Medali)
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
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildMedal(2, Colors.grey.shade400, "🥈"),
                  _buildMedal(1, Colors.amber, "🥇"),
                  _buildMedal(3, Colors.brown.shade300, "🥉"),
                ],
              ),
            ),
            
            /// Statistik
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStatistik("Total Pemain", "128"),
                  _buildStatistik("Total Poin", "8,450"),
                  _buildStatistik("Rata-rata", "66"),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            /// List Leaderboard
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: allLeaderboard.length,
                itemBuilder: (context, index) {
                  final item = allLeaderboard[index];
                  return _buildLeaderboardItem(
                    rank: item['rank'],
                    name: item['name'],
                    score: item['score'],
                    avatar: item['avatar'],
                    isMe: item['isMe'],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMedal(int rank, Color color, String emoji) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 40),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          rank == 1 ? 'Juara 1' : rank == 2 ? 'Juara 2' : 'Juara 3',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
  
  Widget _buildStatistik(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey[600]),
        ),
      ],
    );
  }
  
  Widget _buildLeaderboardItem({
    required int rank,
    required String name,
    required int score,
    required String avatar,
    required bool isMe,
  }) {
    Color? getRankColor() {
      if (rank == 1) return Colors.amber;
      if (rank == 2) return Colors.grey.shade400;
      if (rank == 3) return Colors.brown.shade300;
      return null;
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isMe ? Border.all(color: AppTheme.primaryColor) : null,
      ),
      child: Row(
        children: [
          /// Rank
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: getRankColor()?.withOpacity(0.2) ?? Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: rank <= 3
                  ? Icon(
                      Icons.emoji_events,
                      color: getRankColor(),
                      size: 22,
                    )
                  : Text(
                      '$rank',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: getRankColor() ?? Colors.grey.shade600,
                      ),
                    ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          /// Avatar
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                avatar,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          /// Name & Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Anda',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star, size: 12, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '$score poin',
                      style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          /// Trophy or Bonus
          if (rank <= 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: getRankColor()?.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                rank == 1 ? '+100' : rank == 2 ? '+50' : '+25',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: getRankColor(),
                ),
              ),
            ),
        ],
      ),
    );
  }
}