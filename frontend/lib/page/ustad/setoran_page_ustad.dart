import 'package:flutter/material.dart';
import '../../components/app_layout.dart';

class SetoranPageUstad extends StatelessWidget {
  const SetoranPageUstad({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLayout(
      title: "Setoran Santri",
      child: Center(
        child: Text(
          "Halaman Setoran Santri\n(Coming Soon)",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}