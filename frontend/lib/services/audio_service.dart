import 'dart:io';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  static final AudioPlayer _player = AudioPlayer();
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
    ),
  );

  // ==================== STATE ====================
  static bool isPlaying = false;
  static bool isLoading = false;
  static bool isDownloading = false;
  static double downloadProgress = 0.0;
  static bool isPlayingFull = false;
  static int? currentAyat;
  static int? currentSurah;
  static Duration currentPosition = Duration.zero;
  static Duration totalDuration = Duration.zero;
  static String? errorMessage;
  
  // 🔥 Callback untuk auto-next (mengirimkan ayat yang baru selesai)
  static void Function(int completedAyat)? onAyatComplete;
  
  static final List<Function()> _listeners = [];
  
  static void addListener(Function() listener) {
    _listeners.add(listener);
  }
  
  static void removeListener(Function() listener) {
    _listeners.remove(listener);
  }
  
  static void _notifyListeners() {
    for (var listener in _listeners) {
      listener();
    }
  }
  
  static void setOnAyatComplete(void Function(int ayat) callback) {
    onAyatComplete = callback;
  }
  
  // ==================== INIT ====================
  static void init() {
    _player.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      if (state == PlayerState.stopped) {
        isLoading = false;
        isDownloading = false;
      }
      _notifyListeners();
    });
    
    _player.onDurationChanged.listen((d) {
      totalDuration = d;
      _notifyListeners();
    });
    
    _player.onPositionChanged.listen((p) {
      currentPosition = p;
      _notifyListeners();
    });
    
    // 🔥🔥🔥 AUTO-NEXT CORE LOGIC 🔥🔥🔥
    _player.onPlayerComplete.listen((_) {
      print("🎵 [AudioService] ===== AUDIO SELESAI =====");
      print("🎵 isPlayingFull: $isPlayingFull");
      print("🎵 currentAyat sebelum reset: $currentAyat");
      print("🎵 currentSurah: $currentSurah");
      
      if (isPlayingFull) {
        print("🎵 Full surat selesai, stop");
        stop();
        return;
      }
      
      // Simpan data sebelum direset
      final completedAyat = currentAyat;
      final completedSurah = currentSurah;
      
      // Reset playing state
      isPlaying = false;
      
      // 🔥 Panggil callback untuk auto-next
      if (completedAyat != null && onAyatComplete != null) {
        print("🎵 Memanggil auto-next callback untuk ayat $completedAyat");
        onAyatComplete!(completedAyat);
      } else {
        print("❌ Tidak ada callback atau completedAyat null");
      }
      
      _notifyListeners();
    });
  }
  
  // ==================== PLAY AYAT ====================
  static Future<void> playAyat({
    required String url,
    required int surahId,
    required int ayat,
    required String qari,
  }) async {
    errorMessage = null;
    
    final path = await getAudioPath(surahId, ayat, qari);
    final isFileExist = await File(path).existsSync();
    
    print("🎵 playAyat dipanggil: surah=$surahId, ayat=$ayat, fileExist=$isFileExist");
    
    if (!isFileExist) {
      isLoading = true;
      isDownloading = true;
      downloadProgress = 0.0;
      _notifyListeners();
      
      try {
        await _downloadFile(url: url, savePath: path, label: "Ayat $ayat");
        isDownloading = false;
        _notifyListeners();
      } catch (e) {
        isLoading = false;
        isDownloading = false;
        errorMessage = "Gagal download ayat $ayat";
        _notifyListeners();
        throw Exception(errorMessage);
      }
    }
    
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      
      isPlayingFull = false;
      currentAyat = ayat;
      currentSurah = surahId;
      isPlaying = true;
      isLoading = false;
      
      print("✅ Play ayat $ayat dimulai");
      _notifyListeners();
      
    } catch (e) {
      isLoading = false;
      errorMessage = "Gagal memutar audio";
      _notifyListeners();
      throw Exception(errorMessage);
    }
  }
  
  // ==================== PLAY FULL SURAT ====================
  static Future<void> playFullSurah({
    required String url,
    required int surahId,
    required String qari,
  }) async {
    errorMessage = null;
    final path = await getFullSurahPath(surahId, qari);
    final isFileExist = await File(path).existsSync();
    
    if (!isFileExist) {
      isLoading = true;
      isDownloading = true;
      downloadProgress = 0.0;
      isPlayingFull = true;
      _notifyListeners();
      
      try {
        await _downloadFile(url: url, savePath: path, label: "Full Surat");
        isDownloading = false;
        _notifyListeners();
      } catch (e) {
        isLoading = false;
        isDownloading = false;
        isPlayingFull = false;
        errorMessage = "Gagal download full surat";
        _notifyListeners();
        throw Exception(errorMessage);
      }
    }
    
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      
      isPlayingFull = true;
      currentAyat = null;
      isPlaying = true;
      isLoading = false;
      _notifyListeners();
      
    } catch (e) {
      isLoading = false;
      isPlayingFull = false;
      errorMessage = "Gagal memutar full surat";
      _notifyListeners();
      throw Exception(errorMessage);
    }
  }
  
  // ==================== FILE PATH ====================
  static Future<String> _getBasePath() async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }
  
  static Future<String> getAudioPath(int surahId, int ayat, String qari) async {
    final base = await _getBasePath();
    return "$base/surah_${surahId}_ayat_${ayat}_$qari.mp3";
  }
  
  static Future<String> getFullSurahPath(int surahId, String qari) async {
    final base = await _getBasePath();
    return "$base/surah_${surahId}_full_$qari.mp3";
  }
  
  // ==================== DOWNLOAD ====================
  static Future<String> _downloadFile({
    required String url,
    required String savePath,
    required String label,
  }) async {
    final tmpPath = "$savePath.tmp";
    final tmpFile = File(tmpPath);
    if (await tmpFile.exists()) {
      await tmpFile.delete();
    }
    
    try {
      await _dio.download(
        url,
        tmpPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            downloadProgress = received / total;
            _notifyListeners();
          }
        },
      );
      
      await File(tmpPath).rename(savePath);
      return savePath;
    } catch (e) {
      if (await File(tmpPath).exists()) {
        await File(tmpPath).delete();
      }
      throw Exception("Download gagal: $e");
    }
  }
  
  // ==================== CONTROL ====================
  static Future<void> pause() async {
    await _player.pause();
    _notifyListeners();
  }
  
  static Future<void> resume() async {
    await _player.resume();
    _notifyListeners();
  }
  
  static Future<void> stop() async {
    await _player.stop();
    isPlaying = false;
    isLoading = false;
    isDownloading = false;
    isPlayingFull = false;
    currentAyat = null;
    currentPosition = Duration.zero;
    totalDuration = Duration.zero;
    downloadProgress = 0.0;
    errorMessage = null;
    _notifyListeners();
  }
  
  static Future<void> seek(Duration position) async {
    await _player.seek(position);
    _notifyListeners();
  }
  
  static void resetState() {
    stop();
  }
  
  static String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}