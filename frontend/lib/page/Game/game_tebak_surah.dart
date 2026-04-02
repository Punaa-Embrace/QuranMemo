import 'dart:math';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/quran_service.dart';
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

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);

    try {
      final daftarSurat = await QuranService.getDaftarSurat();
      daftarSurat.shuffle();

      // Jumlah soal = 5
      final selectedSurat = daftarSurat.take(5).toList();

      List<Map<String, dynamic>> soalList = [];

      for (var surat in selectedSurat) {
        final detail = await QuranService.getDetailSurat(surat.nomor);
        if (detail.ayat.isNotEmpty) {
          final randomAyat = detail.ayat[Random().nextInt(detail.ayat.length)];

          // Buat pilihan: 1 benar + 3 salah (total 4 pilihan)
          List<String> pilihan = [surat.namaLatin];
          final suratLain = daftarSurat
              .where((s) => s.nomor != surat.nomor)
              .toList();
          suratLain.shuffle();

          // Ambil 3 surat lain untuk pengecoh
          for (int i = 0; i < 3 && i < suratLain.length; i++) {
            pilihan.add(suratLain[i].namaLatin);
          }

          // Jika kurang dari 4 pilihan, tambah dari surat lain lagi
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

      setState(() {
        _questions = soalList;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
        _score += 10; // 10 poin per soal
        _feedbackMessage = 'Benar! $_score poin';
      } else {
        _feedbackMessage =
            'Salah! Jawaban: ${_questions[_currentQuestion]['jawaban']}';
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestion < _questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _selectedOption = null;
          _feedbackMessage = null;
          _isAnswered = false;
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() {
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
            Text(
              '✨ Soal dari EQURAN API',
              style: TextStyle(fontSize: 10, color: Colors.grey[500]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
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
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    final currentData = _questions.isNotEmpty
        ? _questions[_currentQuestion]
        : null;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Match Surah'),
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
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  /// Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_currentQuestion + 1) / _questions.length,
                          backgroundColor: Colors.grey[200],
                          color: AppTheme.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '${_currentQuestion + 1}/${_questions.length}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  /// Ayat Card
                  AyatCard(
                    teksArab: currentData!['ayat'],
                    terjemahan: currentData['terjemahan'],
                  ),

                  const SizedBox(height: 32),

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

                      Color getBgColor() {
                        if (!_isAnswered) {
                          return isSelected
                              ? AppTheme.primaryColor.withOpacity(0.1)
                              : Colors.white;
                        }
                        final isCorrect =
                            currentData['pilihan'][index] ==
                            currentData['jawaban'];
                        if (isCorrect) return Colors.green.withOpacity(0.2);
                        if (isSelected) return Colors.red.withOpacity(0.2);
                        return Colors.white;
                      }

                      Color getBorderColor() {
                        if (!_isAnswered) {
                          return isSelected
                              ? AppTheme.primaryColor
                              : Colors.grey[300]!;
                        }
                        final isCorrect =
                            currentData['pilihan'][index] ==
                            currentData['jawaban'];
                        if (isCorrect) return Colors.green;
                        if (isSelected) return Colors.red;
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
                              width: isSelected ? 2 : 1,
                            ),
                            boxShadow: isSelected && !_isAnswered
                                ? [
                                    BoxShadow(
                                      color: AppTheme.primaryColor.withOpacity(
                                        0.3,
                                      ),
                                      blurRadius: 8,
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
                                  if (_isAnswered &&
                                      currentData['pilihan'][index] ==
                                          currentData['jawaban'])
                                    const Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                  if (_isAnswered &&
                                      isSelected &&
                                      currentData['pilihan'][index] !=
                                          currentData['jawaban'])
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

                  const SizedBox(height: 24),

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
                            ? 'Menunggu soal berikutnya...'
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
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _feedbackMessage!.contains('Benar')
                                  ? Icons.thumb_up
                                  : Icons.thumb_down,
                              color: _feedbackMessage!.contains('Benar')
                                  ? Colors.green
                                  : Colors.red,
                              size: 16,
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
