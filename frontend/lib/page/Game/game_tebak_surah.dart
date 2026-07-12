import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/quran_service.dart';
import '../../services/leaderboard_service.dart';
import '../../components/ayat_card.dart';

class GameTebakSurah extends StatefulWidget {
  const GameTebakSurah({Key? key}) : super(key: key);

  @override
  State<GameTebakSurah> createState() => _GameTebakSurahState();
}

class _GameTebakSurahState extends State<GameTebakSurah> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedOption;
  String? _feedbackMessage;
  bool _isAnswered = false;
  bool _isSubmitting = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
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

      final selectedSurat = daftarSurat.take(5).toList();
      List<Map<String, dynamic>> soalList = [];

      for (var surat in selectedSurat) {
        final detail = await QuranService.getDetailSurat(surat.nomor);
        if (detail.ayat.isNotEmpty) {
          final randomAyat = detail.ayat[Random().nextInt(detail.ayat.length)];

          List<String> pilihan = [surat.namaLatin];
          final suratLain = daftarSurat
              .where((s) => s.nomor != surat.nomor)
              .toList();
          suratLain.shuffle();

          for (int i = 0; i < 3 && i < suratLain.length; i++) {
            pilihan.add(suratLain[i].namaLatin);
          }

          while (pilihan.length < 4) {
            final suratTambahan =
                daftarSurat[Random().nextInt(daftarSurat.length)];
            if (!pilihan.contains(suratTambahan.namaLatin)) {
              pilihan.add(suratTambahan.namaLatin);
            }
          }

          pilihan.shuffle();

          soalList.add({
            'ayat': randomAyat.teksArab,
            'terjemahan': randomAyat.teksIndonesia,
            'jawaban': surat.namaLatin,
            'pilihan': pilihan,
          });
        }
      }

      if (soalList.isNotEmpty) {
        setState(() {
          _questions = soalList;
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

  void _selectOption(int optionIndex) {
    if (_isAnswered) return;
    setState(() {
      _selectedOption = optionIndex;
    });
  }

  void _submitAnswer() {
    if (_selectedOption == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih jawaban terlebih dahulu!'),
          duration: Duration(seconds: 1),
        ),
      );
      return;
    }

    setState(() {
      _isAnswered = true;
      final isCorrect =
          _questions[_currentQuestion]['pilihan'][_selectedOption!] ==
          _questions[_currentQuestion]['jawaban'];

      if (isCorrect) {
        _score += 10;
        _feedbackMessage = 'Benar! +10 poin';
      } else {
        _feedbackMessage =
            'Salah! Jawaban: ${_questions[_currentQuestion]['jawaban']}';
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (_currentQuestion < _questions.length - 1) {
          setState(() {
            _currentQuestion++;
            _selectedOption = null;
            _feedbackMessage = null;
            _isAnswered = false;
          });
        } else {
          _submitScoreAndShowResult();
        }
      }
    });
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
      builder: (context) => AlertDialog(
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
              'Dari ${_questions.length} soal',
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
      ),
    );
  }

  void _resetGame() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _selectedOption = null;
      _feedbackMessage = null;
      _isAnswered = false;
      _isSubmitting = false;
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

    final currentData = _questions.isNotEmpty
        ? _questions[_currentQuestion]
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Tebak Surah'),
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
                Text(
                  '$_score',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Membuat soal...'),
                ],
              ),
            )
          : _errorMessage.isNotEmpty
              ? Center(
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
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadQuestions,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                          ),
                          child: const Text('Coba Lagi', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// Progress
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'PERTANYAAN ${_currentQuestion + 1} DARI ${_questions.length}',
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
                        value: (_currentQuestion + 1) / _questions.length,
                        backgroundColor: Colors.grey[200],
                        color: AppTheme.primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        minHeight: 6,
                      ),

                      const SizedBox(height: 20),

                      /// Ayat Card
                      AyatCard(
                        teksArab: currentData!['ayat'],
                        terjemahan: currentData['terjemahan'],
                      ),

                      const SizedBox(height: 24),

                      /// Pertanyaan
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Surah apakah ini?',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Grid Pilihan (4 pilihan: 2x2)
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                              childAspectRatio: 2.2,
                            ),
                        itemCount: currentData['pilihan'].length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedOption == index;
                          final isCorrect = currentData['pilihan'][index] ==
                              currentData['jawaban'];

                          Color getBgColor() {
                            if (!_isAnswered) {
                              return isSelected
                                  ? AppTheme.primaryColor.withOpacity(0.1)
                                  : Colors.white;
                            }
                            if (isCorrect) return Colors.green.withOpacity(0.2);
                            if (isSelected && !isCorrect) return Colors.red.withOpacity(0.2);
                            return Colors.white;
                          }

                          Color getBorderColor() {
                            if (!_isAnswered) {
                              return isSelected
                                  ? AppTheme.primaryColor
                                  : Colors.grey[300]!;
                            }
                            if (isCorrect) return Colors.green;
                            if (isSelected && !isCorrect) return Colors.red;
                            return Colors.grey[300]!;
                          }

                          return GestureDetector(
                            onTap: () => _selectOption(index),
                            child: Container(
                              decoration: BoxDecoration(
                                color: getBgColor(),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: getBorderColor(),
                                  width: isSelected ? 2.5 : 1.5,
                                ),
                                boxShadow: isSelected && !_isAnswered
                                    ? [
                                        BoxShadow(
                                          color: AppTheme.primaryColor.withOpacity(
                                            0.3,
                                          ),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                      ]
                                    : null,
                              ),
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_isAnswered && isCorrect)
                                        const Icon(
                                          Icons.check_circle,
                                          color: Colors.green,
                                          size: 18,
                                        ),
                                      if (_isAnswered &&
                                          isSelected &&
                                          !isCorrect)
                                        const Icon(
                                          Icons.cancel,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                      if (!_isAnswered && isSelected)
                                        Container(
                                          width: 18,
                                          height: 18,
                                          decoration: BoxDecoration(
                                            color: AppTheme.primaryColor,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.check,
                                            color: Colors.white,
                                            size: 12,
                                          ),
                                        ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          currentData['pilihan'][index],
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            fontWeight: isSelected
                                                ? FontWeight.bold
                                                : FontWeight.normal,
                                            color: isSelected
                                                ? AppTheme.primaryColor
                                                : Colors.grey[800],
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      /// Tombol Submit
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isAnswered ? null : _submitAnswer,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            _isAnswered
                                ? 'Menunggu...'
                                : 'Submit Jawaban',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),

                      /// Feedback
                      if (_feedbackMessage != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _feedbackMessage!.contains('Benar')
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _feedbackMessage!.contains('Benar')
                                    ? Colors.green
                                    : Colors.red,
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  _feedbackMessage!.contains('Benar')
                                      ? Icons.check_circle
                                      : Icons.cancel,
                                  color: _feedbackMessage!.contains('Benar')
                                      ? Colors.green
                                      : Colors.red,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _feedbackMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _feedbackMessage!.contains('Benar')
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
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
}