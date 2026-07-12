import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'custom_header.dart';

class AppLayout extends StatelessWidget {
  final String title;
  final Widget child;

  final String? imagePath;

  final bool showSearch;
  final String hintText;
  final TextEditingController? controller;
  final ValueChanged<String>? onSearchChanged;

  final bool showBackButton;
  final VoidCallback? onBackPressed;

  final EdgeInsetsGeometry padding;
  final bool scrollable;

  const AppLayout({
    super.key,
    required this.title,
    required this.child,

    this.imagePath,

    this.showSearch = false,
    this.hintText = "Cari...",
    this.controller,
    this.onSearchChanged,

    this.showBackButton = false,
    this.onBackPressed,

    this.padding = const EdgeInsets.all(16),
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding,
      child: child,
    );

    if (scrollable) {
      content = SingleChildScrollView(
        child: content,
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            CustomHeader(
              title: title,
              imagePath: imagePath,
              showSearch: showSearch,
              hintText: hintText,
              controller: controller,
              onChanged: onSearchChanged,
              showBackButton: showBackButton,
              onBackPressed: onBackPressed,
            ),

            Expanded(
              child: content,
            ),
          ],
        ),
      ),
    );
  }
}