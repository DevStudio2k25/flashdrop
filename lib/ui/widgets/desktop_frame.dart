import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import '../theme/app_colors.dart';

/// A wrapper for Desktop that provides:
/// 1. Mobile-width constraint (420px)
/// 2. Custom Title Bar (replacing Windows default)
/// 3. Rounded corners
class DesktopFrame extends StatelessWidget {
  final Widget child;

  const DesktopFrame({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          // Optional: Add shadow/border if transparent window allows
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.black.withOpacity(0.2),
            //     blurRadius: 20,
            //     spreadRadius: 5,
            //   ),
            // ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Column(
              children: [
                const _CustomTitleBar(),
                Expanded(
                  child: Container(
                    color: const Color(
                      0xFFF3F4F6,
                    ), // Match HomeScreen background
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: 420, // Mobile-like width
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomTitleBar extends StatelessWidget {
  const _CustomTitleBar();

  @override
  Widget build(BuildContext context) {
    return DragToMoveArea(
      child: Container(
        height: 48, // Compact height
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1),
          ),
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Text(
              'FlashDrop',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            // Minimize
            _WindowButton(
              icon: Icons.minimize,
              onPressed: () => windowManager.minimize(),
            ),
            // Close
            _WindowButton(
              icon: Icons.close,
              onPressed: () => windowManager.close(),
              isClose: true,
            ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _WindowButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final bool isClose;

  const _WindowButton({
    required this.icon,
    required this.onPressed,
    this.isClose = false,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        icon,
        size: 18,
        color: isClose ? AppColors.error : AppColors.textSecondary,
      ),
      onPressed: onPressed,
      splashRadius: 20,
      tooltip: isClose ? 'Close' : 'Minimize',
    );
  }
}
