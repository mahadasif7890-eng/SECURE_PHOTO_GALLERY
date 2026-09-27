import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../widgets/locked_vault_screen.dart';

class CollectionsScreen extends StatelessWidget {
  final List<CollectionAlbum> collections;
  final List<MediaItem> lockedItems;
  final Function(MediaItem) onUnlockItem;

  const CollectionsScreen({
    super.key,
    required this.collections,
    required this.lockedItems,
    required this.onUnlockItem,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Top Horizontal Quick Category Pills (Favorites, Trash, Camera, WhatsApp)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildTopPill(
                          context,
                          icon: Icons.star_border_rounded,
                          label: 'Favorites',
                          onTap: () => _showSnackbar(context, 'Favorites'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTopPill(
                          context,
                          icon: Icons.delete_outline_rounded,
                          label: 'Trash',
                          onTap: () => _showSnackbar(context, 'Trash'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildTopPill(
                          context,
                          imageThumbnail: 'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=150&q=80',
                          label: 'Camera',
                          onTap: () => _showSnackbar(context, 'Camera'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildTopPill(
                          context,
                          imageThumbnail: 'https://images.unsplash.com/photo-1518770660439-4636190af475?auto=format&fit=crop&w=150&q=80',
                          label: 'WhatsApp Im...',
                          onTap: () => _showSnackbar(context, 'WhatsApp Images'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Categorized 2x2 Grid (People, Documents, Places, Camera)
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 18,
                childAspectRatio: 0.88,
              ),
              delegate: SliverChildListDelegate([
                // 1. People 4-in-1 collage
                _buildQuadCollageCard(
                  context,
                  title: 'People',
                  images: [
                    'https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=300&q=80',
                    'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?auto=format&fit=crop&w=300&q=80',
                    'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?auto=format&fit=crop&w=300&q=80',
                    'https://images.unsplash.com/photo-1522071820081-009f0129c71c?auto=format&fit=crop&w=300&q=80',
                  ],
                  isCircularGrid: true,
                ),

                // 2. Documents 4-in-1 collage
                _buildQuadCollageCard(
                  context,
                  title: 'Documents',
                  images: [
                    'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?auto=format&fit=crop&w=300&q=80',
                    'https://images.unsplash.com/photo-1517842645767-c639042777db?auto=format&fit=crop&w=300&q=80',
                    'https://images.unsplash.com/photo-1635070041078-e363dbe005cb?auto=format&fit=crop&w=300&q=80',
                    'https://images.unsplash.com/photo-1589330694653-ded6df03f754?auto=format&fit=crop&w=300&q=80',
                  ],
                  isCircularGrid: false,
                ),

                // 3. Places Map View with circular pin badge
                _buildPlacesMapCard(context),

                // 4. Camera full image card
                _buildCameraCard(context),
              ]),
            ),
          ),

          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
              child: Text(
                'My Albums & Folders',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          ),

          // All Albums Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 14,
                mainAxisSpacing: 16,
                childAspectRatio: 0.82,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final album = collections[index];
                  return _buildAlbumItem(context, album);
                },
                childCount: collections.length,
              ),
            ),
          ),

          // Utilities list section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
              child: Text(
                'Utilities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildUtilityTile(context, Icons.archive_outlined, 'Archive', 'Hidden from timeline view'),
                _buildUtilityTile(context, Icons.cleaning_services_outlined, 'Free up space', 'Remove backed-up photos'),
                _buildUtilityTile(context, Icons.cloud_download_outlined, 'Import from other sources', 'Move photos from iCloud / SD'),
              ]),
            ),
          ),

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildTopPill(
    BuildContext context, {
    IconData? icon,
    String? imageThumbnail,
    required String label,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pillBg = isDark ? const Color(0xFF282A2C) : const Color(0xFFE8EAED);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: Container(
        height: 52,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: pillBg,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Row(
          children: [
            if (icon != null)
              Icon(icon, size: 22, color: isDark ? Colors.white : const Color(0xFF1F1F1F))
            else if (imageThumbnail != null)
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: NetworkImage(imageThumbnail),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14.5,
                  color: isDark ? Colors.white : const Color(0xFF1F1F1F),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuadCollageCard(
    BuildContext context, {
    required String title,
    required List<String> images,
    bool isCircularGrid = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showSnackbar(context, title),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF282A2C) : const Color(0xFFF1F3F4),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: GridView.count(
                  crossAxisCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  children: images.map((url) {
                    if (isCircularGrid) {
                      return Padding(
                        padding: const EdgeInsets.all(3.0),
                        child: ClipOval(
                          child: Image.network(
                            url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                          ),
                        ),
                      );
                    }
                    return Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
          ),
        ],
      ),
    );
  }

  Widget _buildPlacesMapCard(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showSnackbar(context, 'Places Map View'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF282A2C) : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      'https://images.unsplash.com/photo-1524661135-423995f22d0b?auto=format&fit=crop&w=400&q=80',
                      fit: BoxFit.cover,
                    ),
                    Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        padding: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.25),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.network(
                            'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=100&q=80',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Places',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _showSnackbar(context, 'Camera Roll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.network(
                  'https://images.unsplash.com/photo-1610030469983-98e550d6193c?auto=format&fit=crop&w=400&q=80',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Camera',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5),
          ),
          const Text(
            '1,095 items',
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildAlbumItem(BuildContext context, CollectionAlbum album) {
    return GestureDetector(
      onTap: () {
        if (album.isSpecial) {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LockedVaultScreen(
                lockedItems: lockedItems,
                onUnlockItem: onUnlockItem,
              ),
            ),
          );
        } else {
          _showSnackbar(context, album.title);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      album.coverUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey.shade800,
                        child: Icon(album.icon ?? Icons.photo_album, color: Colors.white60, size: 36),
                      ),
                    ),
                    if (album.icon != null)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(album.icon, color: Colors.white, size: 16),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            album.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Text(
            '${album.count} items',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildUtilityTile(BuildContext context, IconData icon, String title, String subtitle) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).dividerColor.withValues(alpha: 0.15)),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF1A73E8)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12.5)),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        onTap: () => _showSnackbar(context, title),
      ),
    );
  }

  void _showSnackbar(BuildContext context, String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Opened "$title"'), duration: const Duration(seconds: 1)),
    );
  }
}
