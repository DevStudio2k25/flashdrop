import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'shared/theme/app_theme.dart';
import 'features/home/presentation/screens/main_transfer_screen.dart';
import 'core/utils/debug_helper.dart';

void main() {
  // Initialize debug helper for testing
  final debugHelper = DebugHelper();
  debugHelper.setDebugMode(true);
  debugHelper.printDebugBanner();

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
      home: const MainTransferScreen(),
    );
  }
}
