import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/game_service.dart';
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
      final questions = await GameService.generateSambungAyatSoal(
        jumlahSoal: 5,
        forceRefresh: true,
      );
      
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Gagal memuat soal: $e';
      });
    }
  }

  void _checkAnswer(int selectedIndex) {
    if (_isAnswered) return;
    
    setState(() {
      _isAnswered = true;
      _selectedAnswer = selectedIndex;
      
      if (selectedIndex == _questions[_currentQuestion].pilihan.indexOf(
          _questions[_currentQuestion].jawabanBenar)) {
        _score += 10;
      }
    });
    
    Future.delayed(const Duration(seconds: 1), () {
      if (_currentQuestion < _questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _isAnswered = false;
          _selectedAnswer = -1;
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
              const SizedBox(height: 10),
              Text(
                'Soal dibuat Secara acak',
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
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
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Sambung Ayat'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 50, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(_errorMessage),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadQuestions,
                        child: const Text('Coba Lagi'),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      /// Header Score & Progress
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              children: [
                                const Text('Skor', style: TextStyle(fontSize: 12)),
                                Text(
                                  '$_score',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                const Text('Soal', style: TextStyle(fontSize: 12)),
                                Text(
                                  '${_currentQuestion + 1}/${_questions.length}',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
 /// Ayat Card (GANTI INI)
                      AyatCard(
                        teksArab: _questions[_currentQuestion].pertanyaan,
                        terjemahan: _questions[_currentQuestion].terjemahan,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      /// Label pertanyaan 
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Lanjutan ayat di atas adalah...',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      /// Options
                      ...List.generate(_questions[_currentQuestion].pilihan.length, (index) {
                        bool isCorrect = _questions[_currentQuestion].pilihan[index] == 
                                        _questions[_currentQuestion].jawabanBenar;
                        bool isSelected = _selectedAnswer == index;
                        
                        Color? getBgColor() {
                          if (!_isAnswered) return Colors.white;
                          if (isCorrect) return Colors.green;
                          if (isSelected && !isCorrect) return Colors.red;
                          return Colors.white;
                        }
                        
                        Color? getBorderColor() {
                          if (!_isAnswered) return Colors.grey[300];
                          if (isCorrect) return Colors.green;
                          if (isSelected && !isCorrect) return Colors.red;
                          return Colors.grey[300];
                        }
                        
                        return GestureDetector(
                          onTap: () => _checkAnswer(index),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: getBgColor(),
                              borderRadius: BorderRadius.circular(15),
                              border: Border.all(color: getBorderColor()!),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    color: getBorderColor()?.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: getBorderColor()!),
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
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    _questions[_currentQuestion].pilihan[index],
                                    style: const TextStyle(fontFamily: 'me_quran', fontSize: 16),
                                    textAlign: TextAlign.center,
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
                    ],
                  ),
                ),
    );
  }
}