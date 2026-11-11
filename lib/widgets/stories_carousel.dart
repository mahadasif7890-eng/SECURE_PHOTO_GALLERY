import 'package:flutter/material.dart';
import '../models/media_item.dart';
import 'story_viewer_screen.dart';

class StoriesCarousel extends StatelessWidget {
  final List<MemoryStory> stories;

  const StoriesCarousel({super.key, required this.stories});

  @override
  Widget build(BuildContext context) {
    if (stories.isEmpty) return const SizedBox.shrink();

    final screenSize = MediaQuery.sizeOf(context);
    final isCompactHeight = screenSize.height < 520;
    final isWide = screenSize.width >= 600;
    final isNarrow = screenSize.width < 360;

    final double carouselHeight = isCompactHeight
        ? 142
        : (isWide ? 216 : (isNarrow ? 176 : 200));
    final double cardWidth = isCompactHeight
        ? 100
        : (isWide ? 144 : (isNarrow ? 114 : 130));

    return SizedBox(
      height: carouselHeight,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: isWide ? 6 : 14, vertical: 6),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: stories.length,
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final story = stories[index];
          return _buildStoryCard(context, story, cardWidth);
        },
      ),
    );
  }

  Widget _buildStoryCard(BuildContext context, MemoryStory story, double cardWidth) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                StoryViewerScreen(story: story),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        );
      },
      child: Container(
        width: cardWidth,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Cover Image
              Image.network(
                story.coverUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: story.accentColor.withValues(alpha: 0.6),
                  child: const Center(
                    child: Icon(Icons.auto_awesome, color: Colors.white, size: 36),
                  ),
                ),
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
              ),

              // Bottom Gradient Overlay for text contrast
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 100,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.transparent, Colors.black87],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ),

              // Title Label at bottom (e.g., "Spotlight", "Revisit the moment")
              Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                        height: 1.15,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                            offset: Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
