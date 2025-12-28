import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';
import 'dart:io';
import 'ui/theme/app_theme.dart';
import 'ui/screens/home_screen.dart';
import 'ui/widgets/desktop_frame.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Windows desktop window
  if (Platform.isWindows) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: const Size(420, 680),
      minimumSize: const Size(420, 680),
      maximumSize: const Size(420, 680),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
      title: 'FlashDrop',
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.setResizable(false);
      await windowManager.show();
      await windowManager.focus();
    });
  }

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
      home: Platform.isWindows
          ? const DesktopFrame(child: HomeScreen())
          : const HomeScreen(),
    );
  }
}
