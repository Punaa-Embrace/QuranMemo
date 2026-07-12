import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/quran_service.dart';
import '../../services/leaderboard_service.dart';

class GamePuzzleAyat extends StatefulWidget {
  const GamePuzzleAyat({Key? key}) : super(key: key);

  @override
  State<GamePuzzleAyat> createState() => _GamePuzzleAyatState();
}

class _GamePuzzleAyatState extends State<GamePuzzleAyat> {
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestion = 0;
  int _score = 0;
  int _totalQuestions = 0;
  bool _isLoading = true;
  bool _isAnswered = false;
  bool _isCorrect = false;
  String _feedbackMessage = '';
  String _detailMessage = '';
  bool _isSubmitting = false;
  String _errorMessage = '';

  List<String> _availableWords = [];
  List<String> _selectedWords = [];
  String _correctAnswer = '';
  String _questionText = '';
  String _surahInfo = '';
  String _surahName = '';
  int _ayatNumber = 0;
  String _fullAyat = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _questions = [];
      _currentQuestion = 0;
      _score = 0;
    });

    try {
      final daftarSurat = await QuranService.getDaftarSurat();
      if (daftarSurat.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Tidak ada data surat';
        });
        return;
      }

      daftarSurat.shuffle();

      List<Map<String, dynamic>> soalList = [];

      for (int i = 0; i < daftarSurat.length && soalList.length < 8; i++) {
        try {
          final surat = daftarSurat[i];
          final detail = await QuranService.getDetailSurat(surat.nomor);
          
          if (detail.ayat.isEmpty) continue;
          
          final random = Random();
          final ayatIndex = random.nextInt(detail.ayat.length);
          final ayat = detail.ayat[ayatIndex];
          
          final arabWords = ayat.teksArab.split(' ');
          final validWords = arabWords.where((word) => word.length > 1).toList();
          
          if (validWords.length < 3) continue;
          
          final wordCount = min(validWords.length, 5);
          final selectedWords = validWords.sublist(0, wordCount);
          
          soalList.add({
            'words': selectedWords,
            'correct': selectedWords.join(' '),
            'fullAyat': ayat.teksArab,
            'surah': surat.nama,
            'surahId': surat.nomor,
            'ayatNumber': ayatIndex + 1,
            'terjemahan': ayat.teksIndonesia ?? 'Terjemahan tidak tersedia',
          });
          
        } catch (e) {
          continue;
        }
      }

      if (soalList.isNotEmpty) {
        setState(() {
          _questions = soalList;
          _totalQuestions = soalList.length;
          _currentQuestion = 0;
          _loadQuestion();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Tidak cukup data untuk game';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat soal: $e';
      });
    }
  }

  void _loadQuestion() {
    if (_questions.isEmpty || _currentQuestion >= _questions.length) return;
    
    final data = _questions[_currentQuestion];
    final words = List<String>.from(data['words']);
    words.shuffle(Random());
    
    setState(() {
      _availableWords = words;
      _selectedWords = [];
      _correctAnswer = data['correct'];
      _questionText = data['terjemahan'];
      _surahName = data['surah'];
      _surahInfo = 'QS. ke-${data['surahId']} ayat ${data['ayatNumber']}';
      _ayatNumber = data['ayatNumber'];
      _fullAyat = data['fullAyat'];
      _isAnswered = false;
      _isCorrect = false;
      _feedbackMessage = '';
      _detailMessage = '';
    });
  }

  void _onWordTap(String word) {
    if (_isAnswered) return;
    
    if (_availableWords.contains(word)) {
      setState(() {
        _availableWords.remove(word);
        _selectedWords.add(word);
      });
    } else if (_selectedWords.contains(word)) {
      setState(() {
        _selectedWords.remove(word);
        _availableWords.add(word);
      });
    }
  }

  void _resetPuzzle() {
    if (_isAnswered) return;
    
    final data = _questions[_currentQuestion];
    final words = List<String>.from(data['words']);
    words.shuffle(Random());
    
    setState(() {
      _availableWords = words;
      _selectedWords = [];
    });
  }

  void _checkAnswer() {
    if (_selectedWords.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Susun terlebih dahulu kata-katanya!'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final userAnswer = _selectedWords.join(' ');
    final isCorrect = userAnswer == _correctAnswer;

    setState(() {
      _isAnswered = true;
      _isCorrect = isCorrect;
      
      if (isCorrect) {
        _score += 10;
        _feedbackMessage = 'BENAR!';
        _detailMessage = 'Selamat! Susunan ayat benar. +10 poin';
      } else {
        _feedbackMessage = 'SUSUNAN KELIRU!';
        _detailMessage = 'Benar: $_correctAnswer';
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestion < _totalQuestions - 1) {
      setState(() {
        _currentQuestion++;
        _loadQuestion();
      });
    } else {
      _submitScoreAndShowResult();
    }
  }

  Future<void> _submitScoreAndShowResult() async {
    setState(() => _isSubmitting = true);

    try {
      final result = await LeaderboardService.tambahPoin(_score);
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showResultDialog(result['success'] == true);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showResultDialog(false);
      }
    }
  }

  void _showResultDialog(bool success) {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Game Selesai!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events, size: 50, color: Colors.amber),
              const SizedBox(height: 10),
              Text(
                'Skor Anda: $_score',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Dari $_totalQuestions soal',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              if (success)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Poin berhasil disimpan!',
                    style: TextStyle(color: Colors.green, fontSize: 12),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'Poin gagal disimpan',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Kembali'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _resetGame();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
              ),
              child: const Text('Main Lagi'),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _isAnswered = false;
      _feedbackMessage = '';
      _detailMessage = '';
      _isSubmitting = false;
      _availableWords = [];
      _selectedWords = [];
      _questions = [];
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    if (_isSubmitting) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Menyimpan skor...'),
            ],
          ),
        ),
      );
    }

    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Mempersiapkan puzzle...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Puzzle Ayat'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 50, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadQuestions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Puzzle Ayat'),
          backgroundColor: AppTheme.primaryColor,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 50, color: Colors.grey),
              SizedBox(height: 16),
              Text('Tidak ada soal tersedia'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Puzzle Ayat'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text('$_score', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
              ],
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'PERTANYAAN ${_currentQuestion + 1} DARI $_totalQuestions',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star, size: 14, color: Colors.amber),
                      const SizedBox(width: 4),
                      Text(
                        '$_score',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            /// Progress Bar
            LinearProgressIndicator(
              value: (_currentQuestion + 1) / _totalQuestions,
              backgroundColor: Colors.grey[200],
              color: AppTheme.primaryColor,
              borderRadius: BorderRadius.circular(10),
              minHeight: 6,
            ),

            const SizedBox(height: 20),

            /// JUDUL
            const Text(
              'SUSUN KEMBALI AYAT INI:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            /// TERJEMAHAN
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.primaryColor.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '"$_questionText"',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '($_surahInfo)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            /// SELECTED WORDS (Kotak Jawaban - Biru)
            Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minHeight: 60),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _selectedWords.isEmpty
                    ? [
                        Center(
                          child: Text(
                            'Tap kata-kata Arab di bawah...',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ]
                    : _selectedWords.map((word) {
                        return GestureDetector(
                          onTap: _isAnswered ? null : () => _onWordTap(word),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              word,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'me_quran',
                              ),
                            ),
                          ),
                        );
                      }).toList(),
              ),
            ),

            const SizedBox(height: 12),

            /// AVAILABLE WORDS (Kepingan - Putih)
            Container(
              padding: const EdgeInsets.all(12),
              constraints: const BoxConstraints(minHeight: 60),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _availableWords.isEmpty
                  ? Center(
                      child: Text(
                        'Semua kata sudah dipilih',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    )
                  : Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableWords.map((word) {
                        return GestureDetector(
                          onTap: _isAnswered ? null : () => _onWordTap(word),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              word,
                              style: const TextStyle(
                                fontSize: 18,
                                fontFamily: 'me_quran',
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
            ),

            const SizedBox(height: 16),

            /// FEEDBACK - FIX
            if (_isAnswered) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isCorrect ? Colors.green : Colors.red,
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isCorrect ? Icons.check_circle : Icons.cancel,
                          color: _isCorrect ? Colors.green : Colors.red,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _feedbackMessage,
                          style: TextStyle(
                            color: _isCorrect ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (!_isCorrect) ...[
                      Text(
                        'Benar: $_correctAnswer',
                        style: TextStyle(
                          color: Colors.grey[800],
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 5),
                      /// JAWABAN KURANG TEPAT - FIX: Border Merah, Background Transparan
                      Container(
                        padding: const EdgeInsets.all(10),
                        ),
                         Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'JAWABAN KURANG TEPAT',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Ejaan asli $_surahName ayat $_ayatNumber: "$_fullAyat"',
                              style: TextStyle(
                                color: Colors.grey[800],
                                fontSize: 13,
                                fontFamily: 'me_quran',
                              ),
                            ),
                          ],
                        ),
                    ],
                    if (_isCorrect) ...[
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Selamat! Susunan ayat benar. +10 poin',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            const Spacer(),

            /// TOMBOL
            if (!_isAnswered) ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _resetPuzzle,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset Kepingan'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.grey[700],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _checkAnswer,
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Periksa Jawaban'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _nextQuestion,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: Text(
                    _currentQuestion < _totalQuestions - 1 
                        ? 'Lanjut Ayat Berikut' 
                        : 'Lihat Hasil',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}