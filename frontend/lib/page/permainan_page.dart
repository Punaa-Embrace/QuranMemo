import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../components/custom_header.dart';
import '../page/game/game_tebak_surah.dart';
import '../page/game/game_sambung_ayat.dart';
import '../page/game/game_tempat.dart';
import '../page/game/leaderboard_page.dart';

class PermainanPage extends StatefulWidget {
  const PermainanPage({Key? key}) : super(key: key);

  @override
  State<PermainanPage> createState() => _PermainanPageState();
}

class _PermainanPageState extends State<PermainanPage> {
  // Data dummy leaderboard
  final List<Map<String, dynamic>> _topPlayers = [
    {'rank': 1, 'name': 'Budi Syah Putra', 'score': 1250, 'isMe': true},
    {'rank': 2, 'name': 'Fatra Syahreza', 'score': 980, 'isMe': false},
    {'rank': 3, 'name': 'Denny Riansyah', 'score': 870, 'isMe': false},
    {'rank': 4, 'name': 'Raffi Bayu Andhika', 'score': 760, 'isMe': false},
    {'rank': 5, 'name': 'Eko Prasetyo', 'score': 650, 'isMe': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: "QuranMemo",
              imagePath: "assets/images/self.jpg",
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Header
                    const Row(
                      children: [
                        Icon(Icons.emoji_events, color: Colors.amber, size: 28),
                        SizedBox(width: 8),
                        Text(
                          "Permainan",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    /// Statistik Skor Sementara
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor,
                            AppTheme.primaryColor.withOpacity(0.7),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(Icons.star, "Total Poin", "1,250"),
                          _buildStatItem(
                            Icons.emoji_events,
                            "Game Dimainkan",
                            "12",
                          ),
                          _buildStatItem(Icons.bolt, "Streak", "5"),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// LEADERBOARD (TOP 5) - LANGSUNG DI SINI
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// Header Leaderboard
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.emoji_events,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  "🏆 Top 5 Leaderboard",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Minggu ini",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Divider(height: 0, thickness: 1),

                          /// List Top 5
                          ..._topPlayers.map(
                            (player) => _buildLeaderboardItem(player),
                          ),

                          const Divider(height: 0, thickness: 1),

                          /// Tombol Lihat Semua (jika ingin lihat lengkap)
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            child: TextButton(
                              onPressed: () {
                                // Navigasi ke halaman leaderboard lengkap
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LeaderboardPage(),
                                  ),
                                );
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: AppTheme.primaryColor,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text("Lihat Peringkat Lengkap"),
                                  SizedBox(width: 4),
                                  Icon(Icons.arrow_forward, size: 16),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 8),

                    /// DAFTAR GAME
                    const Text(
                      "Pilih Game",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    const SizedBox(height: 12),

                    /// Game 1: Tebak Surah
                    _buildGameCard(
                      title: "Tebak Surah",
                      desc:
                          "Tebak nama surah dari potongan ayat yang ditampilkan",
                      icon: Icons.quiz,
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameTebakSurah(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    /// Game 2: Sambung Ayat
                    _buildGameCard(
                      title: "Sambung Ayat",
                      desc: "Lanjutkan potongan ayat berikutnya dengan tepat",
                      icon: Icons.auto_stories,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameSambungAyat(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    /// Game 3: Tebak Tempat Turun
                    _buildGameCard(
                      title: "Tebak Tempat Turun",
                      desc: "Tebak surat ini turun di Mekah atau Madinah",
                      icon: Icons.location_on,
                      color: Colors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameTebakTempatTurun(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> player) {
    final isMe = player['isMe'] == true;

    Color? getRankColor(int rank) {
      if (rank == 1) return Colors.amber;
      if (rank == 2) return Colors.grey.shade400;
      if (rank == 3) return Colors.brown.shade300;
      return Colors.grey.shade500;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isMe ? AppTheme.primaryColor.withOpacity(0.05) : null,
      child: Row(
        children: [
          /// Rank dengan medali
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: getRankColor(player['rank']),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: player['rank'] <= 3
                  ? Icon(
                      player['rank'] == 1
                          ? Icons.emoji_events
                          : player['rank'] == 2
                          ? Icons.emoji_events
                          : Icons.emoji_events,
                      color: getRankColor(player['rank']),
                      size: 18,
                    )
                  : Text(
                      '${player['rank']}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: getRankColor(player['rank']),
                        fontSize: 14,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: 12),

          /// Avatar placeholder
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player['name'][0],
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryColor,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// Nama dan badge "Anda"
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      player['name'],
                      style: TextStyle(
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Anda',
                          style: TextStyle(color: Colors.white, fontSize: 8),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.star, size: 10, color: Colors.amber),
                    const SizedBox(width: 4),
                    Text(
                      '${player['score']} poin',
                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// Poin tambahan untuk top 3
          if (player['rank'] <= 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: getRankColor(player['rank']),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${player['rank'] == 1
                    ? 100
                    : player['rank'] == 2
                    ? 50
                    : 25}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: getRankColor(player['rank']),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGameCard({
    required String title,
    required String desc,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.arrow_forward_ios, size: 14, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
