// import 'package:flutter/material.dart';
// import 'package:video_player/video_player.dart';
// import '../../theme/app_theme.dart';

// class DetailSetoranPageUstad extends StatefulWidget {
//   final Map<String, dynamic> data;

//   const DetailSetoranPageUstad({
//     super.key,
//     required this.data,
//   });

//   @override
//   State<DetailSetoranPageUstad> createState() =>
//       _DetailSetoranPageUstadState();
// }

// class _DetailSetoranPageUstadState extends State<DetailSetoranPageUstad> {
//   late VideoPlayerController _controller;
//   bool _showControls = true;
//   final TextEditingController feedbackController =
//       TextEditingController();
  

//   String status = "Pending";

//   @override
//   void initState() {
//     super.initState();

//     status = widget.data["status"];

//     // VIDEO LOCAL / ASSET / FILE PATH
//     _controller = VideoPlayerController.asset(
//       'assets/videos/sample.mp4',
//     )..initialize().then((_) {
//         setState(() {});
//       });
//   }

//   Color _getColor(String status) {
//     switch (status) {
//       case "Diterima":
//         return Colors.green;
//       case "Ditolak":
//         return Colors.red;
//       default:
//         return Colors.orange;
//     }
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     feedbackController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final data = widget.data;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Detail Setoran"),
//         backgroundColor: AppTheme.primaryColor,
//       ),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
            
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     data["nama"] ?? "-",
//                     style: const TextStyle(
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Text(
//                     data["surah"] ?? "-",
//                     style: TextStyle(
//                       color: Colors.grey.shade600,
//                     ),
//                   ),
//                   const SizedBox(height: 10),
//                   Text(
//                     data["tanggal"] ?? "-",
//                     style: TextStyle(
//                       color: Colors.grey.shade500,
//                       fontSize: 12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// =========================
//             /// VIDEO PLAYER
//             /// =========================
//             Container(
//               margin: const EdgeInsets.only(top: 16),
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 children: [

//                   const Align(
//                     alignment: Alignment.centerLeft,
//                     child: Text(
//                       "Video Setoran",
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 12),

//                   ClipRRect(
//                     borderRadius: BorderRadius.circular(12),
//                     child: AspectRatio(
//                       aspectRatio: _controller.value.aspectRatio,
//                       child: Stack(
//                         alignment: Alignment.center,
//                         children: [

//                           VideoPlayer(_controller),

//                           GestureDetector(
//                             onTap: () {
//                               setState(() {
//                                 _controller.value.isPlaying
//                                     ? _controller.pause()
//                                     : _controller.play();
//                               });
//                             },
//                             child: AnimatedContainer(
//                               duration: const Duration(milliseconds: 200),
//                               decoration: BoxDecoration(
//                                 color: Colors.black38,
//                                 shape: BoxShape.circle,
//                               ),
//                               padding: const EdgeInsets.all(14),
//                               child: Icon(
//                                 _controller.value.isPlaying
//                                     ? Icons.pause
//                                     : Icons.play_arrow,
//                                 size: 40,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   VideoProgressIndicator(
//                     _controller,
//                     allowScrubbing: true,
//                     colors: VideoProgressColors(
//                       playedColor: AppTheme.primaryColor,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// =========================
//             /// STATUS
//             /// =========================
//             Container(
//               margin: const EdgeInsets.only(top: 16),
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Row(
//                 children: [
//                   Icon(
//                     Icons.info_outline,
//                     color: _getColor(status),
//                   ),
//                   const SizedBox(width: 10),
//                   Text(
//                     "Status:",
//                     style: const TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                   const SizedBox(width: 10),
//                   Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 10,
//                       vertical: 4,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _getColor(status).withOpacity(0.15),
//                       borderRadius: BorderRadius.circular(20),
//                     ),
//                     child: Text(
//                       status,
//                       style: TextStyle(
//                         color: _getColor(status),
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             /// =========================
//             /// FEEDBACK
//             /// =========================
//             Container(
//               margin: const EdgeInsets.only(top: 16),
//               padding: const EdgeInsets.all(14),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(16),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [

//                   const Text(
//                     "Feedback Ustad",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                     ),
//                   ),

//                   const SizedBox(height: 10),

//                   TextField(
//                     controller: feedbackController,
//                     maxLines: 4,
//                     decoration: InputDecoration(
//                       hintText: "Tulis catatan untuk santri...",
//                       filled: true,
//                       fillColor: Colors.grey.shade100,
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(12),
//                         borderSide: BorderSide.none,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 20),

//             /// =========================
//             /// ACTION
//             /// =========================
//             Container(
//               margin: const EdgeInsets.only(top: 20),
//               child: Row(
//                 children: [

//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         setState(() {
//                           status = "Diterima";
//                         });
//                       },
//                       icon: const Icon(Icons.check),
//                       label: const Text("Terima"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         padding: const EdgeInsets.all(14),
//                       ),
//                     ),
//                   ),

//                   const SizedBox(width: 12),

//                   Expanded(
//                     child: ElevatedButton.icon(
//                       onPressed: () {
//                         setState(() {
//                           status = "Ditolak";
//                         });
//                       },
//                       icon: const Icon(Icons.close),
//                       label: const Text("Tolak"),
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.red,
//                         padding: const EdgeInsets.all(14),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_theme.dart';

class DetailSetoranPageUstad extends StatefulWidget {
  final Map<String, dynamic> data;

  const DetailSetoranPageUstad({
    super.key,
    required this.data,
  });

  @override
  State<DetailSetoranPageUstad> createState() =>
      _DetailSetoranPageUstadState();
}

class _DetailSetoranPageUstadState extends State<DetailSetoranPageUstad> {

  late VideoPlayerController _controller;
  final TextEditingController feedbackController =
      TextEditingController();

  bool _showControls = false; 
  String status = "Pending";

  @override
  void initState() {
    super.initState();

    status = widget.data["status"] ?? "Pending";

    _initVideo();
  }

  Future<void> _initVideo() async {
    _controller = VideoPlayerController.asset(
      'assets/videos/sample.mp4',
    );

    // DB Connect Use this
    // _controller = VideoPlayerController.networkUrl(
    //   Uri.parse(videoUrl),
    // );


    await _controller.initialize();

    _controller.setVolume(1.0);

    _controller.addListener(() {
      if (mounted) setState(() {});
    });

    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    feedbackController.dispose();
    super.dispose();
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }

  Color _statusColor(String s) {
    switch (s) {
      case "Diterima":
        return Colors.green;
      case "Ditolak":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  void _togglePlay() {
    setState(() {
      _controller.value.isPlaying
          ? _controller.pause()
          : _controller.play();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Detail Setoran"),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// =========================
                  /// NAME + STATUS ROW
                  /// =========================
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      
                      /// NAME
                      Expanded(
                        child: Text(
                          widget.data["nama"] ?? "",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      /// STATUS CHIP
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: _statusColor(status).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: _statusColor(status),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  /// =========================
                  /// SURAH
                  /// =========================
                  Text(
                    "Surah: ${widget.data["surah"] ?? ""}",
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// =========================
            /// VIDEO CARD 
            /// =========================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Video Setoran",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  if (!_controller.value.isInitialized)
                    const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _showControls = !_showControls;
                        });
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [

                          /// VIDEO
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                          ),

                          /// TAP TO PLAY/PAUSE (HIDE WHEN PLAYING)
                          AnimatedOpacity(
                            duration: const Duration(milliseconds: 200),
                            opacity: (_controller.value.isPlaying && !_showControls)
                                ? 0
                                : 1,
                            child: GestureDetector(
                              onTap: _togglePlay,
                              child: Container(
                                decoration: const BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                ),
                                padding: const EdgeInsets.all(14),
                                child: Icon(
                                  _controller.value.isPlaying
                                      ? Icons.pause
                                      : Icons.play_arrow,
                                  size: 40,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          /// TIME INDICATOR
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                "${_format(_controller.value.position)} / ${_format(_controller.value.duration)}",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 10),

                  /// =========================
                  /// VIDEO PROGRESS BAR (REPLAY CONTROL)
                  /// =========================
                  if (_controller.value.isInitialized)
                    VideoProgressIndicator(
                      _controller,
                      allowScrubbing: true,
                      colors: VideoProgressColors(
                        playedColor: AppTheme.primaryColor,
                        backgroundColor: Colors.grey.shade300,
                        bufferedColor: Colors.grey.shade400,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// =========================
            /// FEEDBACK 
            /// =========================
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Feedback Ustad",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  TextField(
                    controller: feedbackController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Tulis catatan evaluasi...",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// =========================
            /// ACTION BUTTON
            /// =========================
            Row(
              children: [

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(() => status = "Diterima");
                    },
                    child: const Text("Terima"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      setState(() => status = "Ditolak");
                    },
                    child: const Text("Tolak"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}