import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

class KeyboardShortcutsService {
  static Map<LogicalKeySet, VoidCallback> getShortcuts({
    VoidCallback? onOpenFiles,
    VoidCallback? onCancel,
    VoidCallback? onRefresh,
  }) {
    return {
      // Ctrl+O - Open files
      if (onOpenFiles != null)
        LogicalKeySet(LogicalKeyboardKey.control, LogicalKeyboardKey.keyO):
            onOpenFiles,
      // Esc - Cancel
      if (onCancel != null) LogicalKeySet(LogicalKeyboardKey.escape): onCancel,
      // F5 - Refresh
      if (onRefresh != null) LogicalKeySet(LogicalKeyboardKey.f5): onRefresh,
    };
  }
}
