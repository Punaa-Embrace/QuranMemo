import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/game_service.dart';
import '../../services/leaderboard_service.dart';
import '../../components/ayat_card.dart';

class GameSambungAyat extends StatefulWidget {
  const GameSambungAyat({Key? key}) : super(key: key);

  @override
  State<GameSambungAyat> createState() => _GameSambungAyatState();
}

class _GameSambungAyatState extends State<GameSambungAyat> {
  List<GameQuestion> _questions = [];
  int _currentQuestion = 0;
  int _score = 0;
  bool _isAnswered = false;
  int _selectedAnswer = -1;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isSubmitting = false;
  String _feedbackMessage = '';

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
      _feedbackMessage = '';
    });

    try {
      final questions = await GameService.generateSambungAyatSoal(
        jumlahSoal: 5,
        forceRefresh: true,
      );
      
      if (questions.isNotEmpty) {
        // Filter soal yang ayatnya tidak terlalu panjang
        final filteredQuestions = questions.where((q) {
          final wordCount = q.pertanyaan.split(' ').length;
          // Hanya ambil ayat dengan 5-15 kata
          return wordCount >= 3 && wordCount <= 15;
        }).toList();
        
        // Kalau hasil filter kurang dari 3, pakai semua
        final finalQuestions = filteredQuestions.length >= 3 
            ? filteredQuestions 
            : questions;
        
        setState(() {
          _questions = finalQuestions.take(5).toList();
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

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;
    
    final isCorrect = selectedIndex == _questions[_currentQuestion].pilihan.indexOf(
        _questions[_currentQuestion].jawabanBenar);
    
    setState(() {
      _isAnswered = true;
      _selectedAnswer = selectedIndex;
      _feedbackMessage = isCorrect ? 'Benar! +10 poin' : 'Salah!';
      
      if (isCorrect) {
        _score += 10;
      }
    });
    
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        if (_currentQuestion < _questions.length - 1) {
          setState(() {
            _currentQuestion++;
            _isAnswered = false;
            _selectedAnswer = -1;
            _feedbackMessage = '';
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
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      _currentQuestion = 0;
      _score = 0;
      _isAnswered = false;
      _selectedAnswer = -1;
      _isSubmitting = false;
      _feedbackMessage = '';
      _questions = [];
    });
    _loadQuestions();
  }

  String _truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return text.substring(0, maxLength) + '...';
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

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sambung Ayat'),
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
                  Text('Membuat soal secara acak...'),
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
              : _questions.isEmpty
                  ? const Center(
                      child: Text('Tidak ada soal tersedia'),
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
                          
                          const SizedBox(height: 16),
                          
                          /// Ayat Card - Dengan Scroll jika terlalu panjang
                          Expanded(
                            flex: 2,
                            child: SingleChildScrollView(
                              child: AyatCard(
                                teksArab: _questions[_currentQuestion].pertanyaan,
                                terjemahan: _questions[_currentQuestion].terjemahan,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          /// Label pertanyaan
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.amber.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Lanjutan ayat di atas adalah...',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 12),
                          
                          /// Options - Dengan Scroll
                          Expanded(
                            flex: 3,
                            child: SingleChildScrollView(
                              child: Column(
                                children: List.generate(_questions[_currentQuestion].pilihan.length, (index) {
                                  bool isCorrect = _questions[_currentQuestion].pilihan[index] == 
                                                  _questions[_currentQuestion].jawabanBenar;
                                  bool isSelected = _selectedAnswer == index;
                                  
                                  Color getBgColor() {
                                    if (!_isAnswered) {
                                      return isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.white;
                                    }
                                    if (isCorrect) return Colors.green.withOpacity(0.2);
                                    if (isSelected && !isCorrect) return Colors.red.withOpacity(0.2);
                                    return Colors.white;
                                  }
                                  
                                  Color getBorderColor() {
                                    if (!_isAnswered) {
                                      return isSelected ? AppTheme.primaryColor : Colors.grey[300]!;
                                    }
                                    if (isCorrect) return Colors.green;
                                    if (isSelected && !isCorrect) return Colors.red;
                                    return Colors.grey[300]!;
                                  }
                                  
                                  return GestureDetector(
                                    onTap: () => _checkAnswer(index),
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 10),
                                      padding: const EdgeInsets.all(14),
                                      decoration: BoxDecoration(
                                        color: getBgColor(),
                                        borderRadius: BorderRadius.circular(15),
                                        border: Border.all(
                                          color: getBorderColor(),
                                          width: isSelected || _isAnswered ? 2 : 1.5,
                                        ),
                                        boxShadow: isSelected && !_isAnswered
                                            ? [
                                                BoxShadow(
                                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: 28,
                                            height: 28,
                                            decoration: BoxDecoration(
                                              color: getBorderColor().withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: getBorderColor()),
                                            ),
                                            child: Center(
                                              child: Text(
                                                String.fromCharCode(65 + index),
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: getBorderColor(),
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _questions[_currentQuestion].pilihan[index],
                                              style: const TextStyle(
                                                fontFamily: 'me_quran',
                                                fontSize: 15,
                                                height: 1.5,
                                              ),
                                              textAlign: TextAlign.left,
                                              softWrap: true,
                                            ),
                                          ),
                                          if (_isAnswered && isCorrect)
                                            const Icon(Icons.check_circle, color: Colors.green, size: 20),
                                          if (_isAnswered && isSelected && !isCorrect)
                                            const Icon(Icons.cancel, color: Colors.red, size: 20),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                              ),
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          /// Feedback
                          if (_feedbackMessage.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _feedbackMessage.contains('Benar')
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: _feedbackMessage.contains('Benar')
                                      ? Colors.green
                                      : Colors.red,
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _feedbackMessage.contains('Benar')
                                        ? Icons.check_circle
                                        : Icons.cancel,
                                    color: _feedbackMessage.contains('Benar')
                                        ? Colors.green
                                        : Colors.red,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _feedbackMessage,
                                    style: TextStyle(
                                      color: _feedbackMessage.contains('Benar')
                                          ? Colors.green
                                          : Colors.red,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
    );
  }
}