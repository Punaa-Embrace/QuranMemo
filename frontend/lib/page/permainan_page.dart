import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_theme.dart';
import '../components/custom_header.dart';
import '../page/game/game_tebak_surah.dart';
import '../page/game/game_sambung_ayat.dart';
import '../page/game/game_puzzle_ayat.dart';
import '../page/game/leaderboard_page.dart';
import '../services/leaderboard_service.dart';

class PermainanPage extends StatefulWidget {
  const PermainanPage({Key? key}) : super(key: key);

  @override
  State<PermainanPage> createState() => _PermainanPageState();
}

class _PermainanPageState extends State<PermainanPage> {
  List<Map<String, dynamic>> _topPlayers = [];
  bool _isLoadingLeaderboard = true;
  int _totalPoin = 0;
  int _totalGame = 0;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadTopPlayers();
    _loadUserStats();
  }

  Future<void> _loadTopPlayers() async {
    setState(() => _isLoadingLeaderboard = true);
    try {
      final response = await LeaderboardService.getTop10();
      if (response['success'] == true) {
        final data = response['data'] as List? ?? [];
        setState(() {
          _topPlayers = data.map((item) {
            final santri = item['santri'] ?? {};
            return {
              'rank': item['rank'] ?? 0,
              'name': santri['nama'] ?? 'Santri',
              'score': item['nilai'] ?? 0,
              'isMe': false,
            };
          }).take(5).toList();
          _isLoadingLeaderboard = false;
        });
      } else {
        setState(() => _isLoadingLeaderboard = false);
      }
    } catch (e) {
      setState(() => _isLoadingLeaderboard = false);
    }
  }

  Future<void> _loadUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Ambil data dari SharedPreferences
      final totalPoin = prefs.getInt('total_poin') ?? 0;
      final totalGame = prefs.getInt('total_game') ?? 0;
      final streak = prefs.getInt('streak') ?? 0;
      
      setState(() {
        _totalPoin = totalPoin;
        _totalGame = totalGame;
        _streak = streak;
      });
    } catch (e) {
      print('Error load stats: $e');
      // Fallback ke 0
      setState(() {
        _totalPoin = 0;
        _totalGame = 0;
        _streak = 0;
      });
    }
  }

  // Fungsi untuk update stats setelah game selesai
  Future<void> updateStats(int poin) async {
    final prefs = await SharedPreferences.getInstance();
    final totalPoin = (prefs.getInt('total_poin') ?? 0) + poin;
    final totalGame = (prefs.getInt('total_game') ?? 0) + 1;
    
    await prefs.setInt('total_poin', totalPoin);
    await prefs.setInt('total_game', totalGame);
    
    setState(() {
      _totalPoin = totalPoin;
      _totalGame = totalGame;
    });
  }

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
                    /// HEADER
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Permainan",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Asah hafalan dengan kuis seru",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// STATISTIK
                    Container(
                      padding: const EdgeInsets.all(20),
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
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(
                            Icons.star,
                            "Total Poin",
                            "$_totalPoin",
                            Colors.amber,
                          ),
                          _buildStatItem(
                            Icons.emoji_events,
                            "Game Dimainkan",
                            "$_totalGame",
                            Colors.white,
                          ),
                          _buildStatItem(
                            Icons.local_fire_department,
                            "Streak",
                            "$_streak",
                            Colors.orange,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// LEADERBOARD
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 15,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.15),
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
                                  "Top 5 Leaderboard",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    "Minggu ini",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey[500],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Divider(height: 0, thickness: 1),
                          _isLoadingLeaderboard
                              ? const Padding(
                                  padding: EdgeInsets.all(32),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : _topPlayers.isEmpty
                                  ? const Padding(
                                      padding: EdgeInsets.all(32),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Icon(
                                              Icons.emoji_events,
                                              size: 48,
                                              color: Colors.grey,
                                            ),
                                            SizedBox(height: 12),
                                            Text(
                                              'Belum ada data leaderboard',
                                              style: TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Column(
                                      children: _topPlayers.map(
                                        (player) => _buildLeaderboardItem(player),
                                      ).toList(),
                                    ),
                          const Divider(height: 0, thickness: 1),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const LeaderboardPage(),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryColor.withOpacity(0.05),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Lihat Peringkat Lengkap",
                                      style: TextStyle(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Icon(
                                      Icons.arrow_forward,
                                      size: 16,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// JUDUL GAME
                    const Text(
                      "Pilih Game",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Tantang dirimu dengan kuis Al-Qur'an",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// GAME 1: SAMBUNG AYAT
                    _buildGameCard(
                      title: "Sambung Ayat",
                      desc: "Lanjutkan potongan ayat berikutnya",
                      imagePath: "assets/images/SambungAyat.png",
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameSambungAyat(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    /// GAME 2: TEBAK SURAH
                    _buildGameCard(
                      title: "Tebak Surah",
                      desc: "Tebak nama surah dari potongan ayat",
                      imagePath: "assets/images/TebakSurah.png",
                      color: Colors.teal,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GameTebakSurah(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),
                
                    /// GAME 3: PUZZLE AYAT
                    _buildGameCard(
                      title: "Puzzle Ayat",
                      desc: "Cocokkan potongan ayat dengan terjemahan",
                      imagePath: "assets/images/PuzzleAyat.png",
                      color: Colors.green,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GamePuzzleAyat(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color iconColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLeaderboardItem(Map<String, dynamic> player) {
    final isMe = player['isMe'] == true;
    final rank = player['rank'] ?? 0;
    final name = player['name'] ?? 'Santri';
    final score = player['score'] ?? 0;

    Color getRankColor() {
      if (rank == 1) return Colors.amber;
      if (rank == 2) return Colors.grey.shade400;
      if (rank == 3) return Colors.brown.shade300;
      return Colors.grey.shade500;
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: isMe ? AppTheme.primaryColor.withOpacity(0.05) : null,
      child: Row(
        children: [
          /// RANK BADGE
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: rank <= 3 ? getRankColor().withOpacity(0.2) : Colors.grey.shade200,
              shape: BoxShape.circle,
              border: rank <= 3 ? Border.all(color: getRankColor(), width: 2) : null,
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
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          
          /// AVATAR
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: getAvatarGradient(),
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: rank == 1 ? [
                BoxShadow(
                  color: Colors.amber.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ] : null,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'S',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          
          /// NAMA & POIN
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
                const SizedBox(height: 2),
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
          
          /// BONUS POIN
          if (rank <= 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: getRankColor().withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: getRankColor().withOpacity(0.3)),
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

  Widget _buildGameCard({
    required String title,
    required String desc,
    required String imagePath,
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
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: color.withOpacity(0.15),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(1),
              decoration: BoxDecoration(
              ),
              child: Image.asset(
                imagePath,
                width: 65,
                height: 65,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 14),
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      height: 1.4,
                    ),
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