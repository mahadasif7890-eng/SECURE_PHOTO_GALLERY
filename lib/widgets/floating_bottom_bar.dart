import 'package:flutter/material.dart';

class FloatingBottomBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;
  final VoidCallback onSearchLensTap;

  const FloatingBottomBar({
    super.key,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onSearchLensTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Theme-matched colors (Google Photos Material 3 style)
    final barBgColor = isDark ? const Color(0xFF252729) : Colors.white;
    final barBorderColor = isDark ? const Color(0xFF383A3D) : const Color(0xFFE8EAED);
    final shadowColor = isDark ? Colors.black.withValues(alpha: 0.4) : Colors.black.withValues(alpha: 0.10);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Main Floating Pill
            Expanded(
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 5),
                decoration: BoxDecoration(
                  color: barBgColor,
                  borderRadius: BorderRadius.circular(32),
                  border: Border.all(color: barBorderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildPillTab(
                      context: context,
                      index: 0,
                      icon: Icons.photo_size_select_actual_rounded,
                      label: 'Photos',
                    ),
                    _buildPillTab(
                      context: context,
                      index: 1,
                      icon: Icons.photo_library_outlined,
                      label: 'Collections',
                    ),
                    _buildPillTab(
                      context: context,
                      index: 2,
                      icon: Icons.lock_outline_rounded,
                      label: 'Locked',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Google Lens / Visual Search Floating Button
            GestureDetector(
              onTap: onSearchLensTap,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: barBgColor,
                  shape: BoxShape.circle,
                  border: Border.all(color: barBorderColor, width: 1.2),
                  boxShadow: [
                    BoxShadow(
                      color: shadowColor,
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.search_rounded,
                  color: isDark ? const Color(0xFF8AB4F8) : const Color(0xFF1A73E8),
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillTab({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSelected = currentIndex == index;

    // Active pill background and foreground
    final activeBgColor = isDark ? const Color(0xFF004A77) : const Color(0xFFD3E3FD);
    final activeFgColor = isDark ? const Color(0xFFC2E7FF) : const Color(0xFF041E49);
    final inactiveFgColor = isDark ? const Color(0xFFC4C7C5) : const Color(0xFF444746);

    return Expanded(
      child: GestureDetector(
        onTap: () => onTabSelected(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 2),
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? activeBgColor : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? activeFgColor : inactiveFgColor,
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: isSelected ? activeFgColor : inactiveFgColor,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
