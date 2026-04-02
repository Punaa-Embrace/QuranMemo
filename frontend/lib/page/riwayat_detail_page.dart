import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/setoran_model.dart';
import '../utils/constants.dart';

class RiwayatDetailPage extends StatelessWidget {
  final SetoranModel setoran;

  const RiwayatDetailPage({super.key, required this.setoran});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Color(0xFFF5E2D1),
            border: Border(
              top: BorderSide(color: AppTheme.primaryColor, width: 3),
            ),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// HANDLE
                Center(
                  child: Container(
                    width: 60,
                    height: 6,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),

                /// CARD UTAMA (SURAH)
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: const BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                  child: ListTile(
                    leading: Icon(
                      Icons.check_circle,
                      color: setoran.statusColor,
                      size: 30,
                    ),
                    title: Text(
                      setoran.surah,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: Chip(
                      label: Text(setoran.status),
                      backgroundColor:
                          setoran.statusColor.withOpacity(0.1),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// INFO TANGGAL
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.calendar_today),
                    title: Text(setoran.date),
                    subtitle: Text(setoran.ayat),
                  ),
                ),

                const SizedBox(height: 10),

                /// NILAI USTAD
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        const Text(
                          "Nilai Ustad",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            CircleAvatar(
                              backgroundImage: Constants.getUstadImage(),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(setoran.ustadName ?? "Ust. Ahmad"),
                            ),
                            Text(
                              "Tajwid ${setoran.tajwid ?? '-'}",
                              style: const TextStyle(color: Colors.red),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                /// CATATAN
                if (setoran.catatanUstad != null)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(setoran.catatanUstad!),
                    ),
                  ),

                const SizedBox(height: 20),

                /// VIDEO PLACEHOLDER
                Card(
                  child: Container(
                    height: 150,
                    alignment: Alignment.center,
                    child: const Icon(Icons.videocam, size: 50),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}