import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/theme/app_theme.dart';
import 'ui/screens/home_screen.dart';

void main() {
  runApp(const ProviderScope(child: FlashDropApp()));
}

class FlashDropApp extends StatelessWidget {
  const FlashDropApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlashDrop',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomeScreen(),
    );
  }
}
