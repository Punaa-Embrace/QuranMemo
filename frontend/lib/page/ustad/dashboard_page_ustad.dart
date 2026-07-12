import 'package:flutter/material.dart';
import '../../components/app_layout.dart';

class DashboardPageUstad extends StatelessWidget {
  const DashboardPageUstad({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppLayout(
      title: "Dashboard",
      child: Center(
        child: Text(
          "Dashboard Ustad\n(Coming Soon)",
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