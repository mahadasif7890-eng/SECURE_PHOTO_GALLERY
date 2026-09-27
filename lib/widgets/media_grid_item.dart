import 'package:flutter/material.dart';
import '../models/media_item.dart';

class MediaGridItem extends StatelessWidget {
  final MediaItem item;
  final bool isSelected;
  final bool isSelectionMode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const MediaGridItem({
    super.key,
    required this.item,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          border: isSelected ? Border.all(color: const Color(0xFF1A73E8), width: 3.5) : null,
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Thumbnail Image
            Hero(
              tag: 'media_${item.id}',
              child: Image.network(
                item.url,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: item.placeholderColor ?? Colors.grey.shade800,
                  child: Icon(
                    item.isVideo ? Icons.videocam : Icons.image,
                    color: Colors.white60,
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: item.placeholderColor?.withValues(alpha: 0.3) ?? Colors.grey.shade300,
                    child: const Center(
                      child: SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Video Duration Indicator Overlay (e.g. 0:24, 01:32)
            if (item.isVideo && item.duration != null)
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.75),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.duration!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(width: 3),
                      const Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.white,
                        size: 13,
                      ),
                    ],
                  ),
                ),
              ),

            // Selection Mode Checkbox Badge
            if (isSelectionMode)
              Positioned(
                top: 6,
                left: 6,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1A73E8) : Colors.black45,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : null,
                ),
              ),

            // Favorite Star Indicator
            if (item.isFavorite && !isSelectionMode)
              const Positioned(
                top: 4,
                right: 4,
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                  size: 18,
                  shadows: [
                    Shadow(color: Colors.black54, blurRadius: 4),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
