import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioService {
  // ============================================================================
  // Private Constants
  // ============================================================================
  static const Duration _timeout = Duration(seconds: 30);
  
  // ============================================================================
  // Private Static Instances
  // ============================================================================
  static final AudioPlayer _player = AudioPlayer();
  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: _timeout,
      receiveTimeout: _timeout,
    ),
  );
  
  // ============================================================================
  // Public State
  // ============================================================================
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
  
  // ============================================================================
  // Callbacks
  // ============================================================================
  static void Function(int completedAyat)? onAyatComplete;
  
  // ============================================================================
  // Private Members
  // ============================================================================
  static final List<Function()> _listeners = [];
  
  // ============================================================================
  // Public Methods - Listeners
  // ============================================================================
  static void addListener(Function() listener) => _listeners.add(listener);
  
  static void removeListener(Function() listener) => _listeners.remove(listener);
  
  static void setOnAyatComplete(void Function(int ayat) callback) {
    onAyatComplete = callback;
  }
  
  // ============================================================================
  // Initialization
  // ============================================================================
  static void init() {
    _listenToPlayerState();
    _listenToDuration();
    _listenToPosition();
    _listenToCompletion();
  }
  
  static void _listenToPlayerState() {
    _player.onPlayerStateChanged.listen((state) {
      isPlaying = state == PlayerState.playing;
      
      if (state == PlayerState.stopped) {
        isLoading = false;
        isDownloading = false;
      }
      
      _notifyListeners();
    });
  }
  
  static void _listenToDuration() {
    _player.onDurationChanged.listen((duration) {
      totalDuration = duration;
      _notifyListeners();
    });
  }
  
  static void _listenToPosition() {
    _player.onPositionChanged.listen((position) {
      currentPosition = position;
      _notifyListeners();
    });
  }
  
  static void _listenToCompletion() {
    _player.onPlayerComplete.listen((_) {
      _handleAudioCompletion();
    });
  }
  
  static void _handleAudioCompletion() {
    print("[AudioService] Audio completed - Playing Full: $isPlayingFull");
    
    if (isPlayingFull) {
      stop();
      return;
    }
    
    final completedAyat = currentAyat;
    
    // Reset playing state
    isPlaying = false;
    
    // Trigger auto-next callback
    if (completedAyat != null && onAyatComplete != null) {
      print("Auto-next triggered for ayat: $completedAyat");
      onAyatComplete!(completedAyat);
    }
    
    _notifyListeners();
  }
  
  // ============================================================================
  // Playback Methods
  // ============================================================================
  static Future<void> playAyat({
    required String url,
    required int surahId,
    required int ayat,
    required String qari,
  }) async {
    errorMessage = null;
    
    final audioPath = await _getAyatPath(surahId, ayat, qari);
    final isFileExist = await File(audioPath).exists();
    
    if (!isFileExist) {
      await _downloadWithLoading(url, audioPath, "Ayat $ayat");
    }
    
    await _playAudio(audioPath);
    
    _setPlaybackState(
      isPlayingFull: false,
      currentAyat: ayat,
      currentSurah: surahId,
    );
    
    print("Playing ayat: $ayat");
  }
  
  static Future<void> playFullSurah({
    required String url,
    required int surahId,
    required String qari,
  }) async {
    errorMessage = null;
    
    final audioPath = await _getFullSurahPath(surahId, qari);
    final isFileExist = await File(audioPath).exists();
    
    if (!isFileExist) {
      await _downloadWithLoading(url, audioPath, "Full Surah");
    }
    
    await _playAudio(audioPath);
    
    _setPlaybackState(
      isPlayingFull: true,
      currentAyat: null,
      currentSurah: surahId,
    );
  }
  
  static Future<void> _downloadWithLoading(
    String url,
    String savePath,
    String label,
  ) async {
    isLoading = true;
    isDownloading = true;
    downloadProgress = 0.0;
    _notifyListeners();
    
    try {
      await _downloadFile(url: url, savePath: savePath, label: label);
      isDownloading = false;
      _notifyListeners();
    } catch (e) {
      isLoading = false;
      isDownloading = false;
      errorMessage = "Failed to download $label";
      _notifyListeners();
      throw Exception(errorMessage);
    }
  }
  
  static Future<void> _playAudio(String path) async {
    try {
      await _player.stop();
      await _player.play(DeviceFileSource(path));
      
      isPlaying = true;
      isLoading = false;
      _notifyListeners();
    } catch (e) {
      isLoading = false;
      errorMessage = "Failed to play audio";
      _notifyListeners();
      throw Exception(errorMessage);
    }
  }
  
  static void _setPlaybackState({
    required bool isPlayingFull,
    required int? currentAyat,
    required int? currentSurah,
  }) {
    AudioService.isPlayingFull = isPlayingFull;
    AudioService.currentAyat = currentAyat;
    AudioService.currentSurah = currentSurah;
    _notifyListeners();
  }
  
  // ============================================================================
  // File Management
  // ============================================================================
  static Future<String> _getBasePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
  
  static Future<String> _getAyatPath(int surahId, int ayat, String qari) async {
    final basePath = await _getBasePath();
    return "$basePath/surah_${surahId}_ayat_${ayat}_$qari.mp3";
  }
  
  static Future<String> _getFullSurahPath(int surahId, String qari) async {
    final basePath = await _getBasePath();
    return "$basePath/surah_${surahId}_full_$qari.mp3";
  }
  
  static Future<String> _downloadFile({
    required String url,
    required String savePath,
    required String label,
  }) async {
    final tempPath = "$savePath.tmp";
    final tempFile = File(tempPath);
    
    await _cleanupTempFile(tempFile);
    
    try {
      await _dio.download(
        url,
        tempPath,
        onReceiveProgress: (received, total) {
          if (total > 0) {
            downloadProgress = received / total;
            _notifyListeners();
          }
        },
      );
      
      await tempFile.rename(savePath);
      return savePath;
    } catch (e) {
      await _cleanupTempFile(tempFile);
      throw Exception("Download failed: $e");
    }
  }
  
  static Future<void> _cleanupTempFile(File tempFile) async {
    if (await tempFile.exists()) {
      await tempFile.delete();
    }
  }
  
  // ============================================================================
  // Control Methods
  // ============================================================================
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
    _resetAllState();
    _notifyListeners();
  }
  
  static Future<void> seek(Duration position) async {
    await _player.seek(position);
    _notifyListeners();
  }
  
  static void resetState() => stop();
  
  static void _resetAllState() {
    isPlaying = false;
    isLoading = false;
    isDownloading = false;
    isPlayingFull = false;
    currentAyat = null;
    currentPosition = Duration.zero;
    totalDuration = Duration.zero;
    downloadProgress = 0.0;
    errorMessage = null;
  }
  
  // ============================================================================
  // Helper Methods
  // ============================================================================
  static void _notifyListeners() {
    for (final listener in _listeners) {
      listener();
    }
  }
  
  static String formatDuration(Duration duration) {
    final minutes = _formatNumber(duration.inMinutes.remainder(60));
    final seconds = _formatNumber(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
  
  static String _formatNumber(int number) => number.toString().padLeft(2, '0');
}