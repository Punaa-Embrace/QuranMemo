import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/quran_service.dart';

class GameTebakTempatTurun extends StatefulWidget {
  const GameTebakTempatTurun({Key? key}) : super(key: key);

  @override
  State<GameTebakTempatTurun> createState() => _GameTebakTempatTurunState();
}

class _GameTebakTempatTurunState extends State<GameTebakTempatTurun> {
  List<Map<String, dynamic>> _questions = [];
  bool _isLoading = true;
  int _currentQuestion = 0;
  int _score = 0;
  int? _selectedOption;
  bool _isAnswered = false;
  String? _feedbackMessage;
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
      daftarSurat.shuffle();
      
      final selectedSurat = daftarSurat.take(5).toList();
      List<Map<String, dynamic>> soalList = [];

      for (var surat in selectedSurat) {
        final isMakkiyah = surat.tempatTurun.toLowerCase() == 'mekah';
        
        soalList.add({
          'namaSurat': surat.namaLatin,
          'namaArab': surat.nama,
          'arti': surat.arti,
          'jawaban': isMakkiyah ? 'Makkiyah' : 'Madaniyah',
          'tempatTurun': surat.tempatTurun,
        });
      }

      setState(() {
        _questions = soalList;
        _isLoading = false;
      });
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
      final isCorrect = _selectedOption == 0 
          ? _questions[_currentQuestion]['jawaban'] == 'Makkiyah'
          : _questions[_currentQuestion]['jawaban'] == 'Madaniyah';
      
      if (isCorrect) {
        _score += 10;
        _feedbackMessage = 'Benar! $_score poin';
      } else {
        _feedbackMessage = 'Salah! Jawaban: ${_questions[_currentQuestion]['jawaban']}';
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
      _selectedOption = null;
      _feedbackMessage = null;
      _isAnswered = false;
    });
    _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Tebak Tempat Turun'),
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
                Text('$_score', style: const TextStyle(fontWeight: FontWeight.bold)),
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
                  Text('Memuat soal...'),
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
                      
                      /// Card Info Surat
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppTheme.primaryColor, AppTheme.primaryColor.withOpacity(0.8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Text(
                              _questions[_currentQuestion]['namaArab'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 32,
                                fontFamily: 'me_quran',
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _questions[_currentQuestion]['namaSurat'],
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _questions[_currentQuestion]['arti'],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      /// Pertanyaan
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Surat ini termasuk golongan...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.amber,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      /// 2 Pilihan
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectOption(0),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: _selectedOption == 0
                                      ? (_isAnswered && _selectedOption == 0 && _questions[_currentQuestion]['jawaban'] == 'Makkiyah'
                                          ? Colors.green.withOpacity(0.2)
                                          : _isAnswered && _selectedOption == 0 && _questions[_currentQuestion]['jawaban'] != 'Makkiyah'
                                              ? Colors.red.withOpacity(0.2)
                                              : AppTheme.primaryColor.withOpacity(0.1))
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedOption == 0
                                        ? AppTheme.primaryColor
                                        : Colors.grey[300]!,
                                    width: _selectedOption == 0 ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.location_on, size: 28, color: Colors.green),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Makkiyah',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Turun di Mekah',
                                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          
                          const SizedBox(width: 16),
                          
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _selectOption(1),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                decoration: BoxDecoration(
                                  color: _selectedOption == 1
                                      ? (_isAnswered && _selectedOption == 1 && _questions[_currentQuestion]['jawaban'] == 'Madaniyah'
                                          ? Colors.green.withOpacity(0.2)
                                          : _isAnswered && _selectedOption == 1 && _questions[_currentQuestion]['jawaban'] != 'Madaniyah'
                                              ? Colors.red.withOpacity(0.2)
                                              : AppTheme.primaryColor.withOpacity(0.1))
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: _selectedOption == 1
                                        ? AppTheme.primaryColor
                                        : Colors.grey[300]!,
                                    width: _selectedOption == 1 ? 2 : 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(Icons.location_city, size: 28, color: Colors.blue),
                                    const SizedBox(height: 8),
                                    const Text(
                                      'Madaniyah',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      'Turun di Madinah',
                                      style: TextStyle(fontSize: 10, color: Colors.grey[600]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
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
                            _isAnswered ? 'Menunggu soal berikutnya...' : 'Submit Jawaban',
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
                                  _feedbackMessage!.contains('Benar') ? Icons.thumb_up : Icons.thumb_down,
                                  color: _feedbackMessage!.contains('Benar') ? Colors.green : Colors.red,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _feedbackMessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: _feedbackMessage!.contains('Benar') ? Colors.green : Colors.red,
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