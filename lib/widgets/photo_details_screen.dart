import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/media_item.dart';

class PhotoDetailsScreen extends StatefulWidget {
  final List<MediaItem> mediaList;
  final int initialIndex;
  final Function(MediaItem)? onLockItem;
  final Function(MediaItem)? onDeleteItem;

  const PhotoDetailsScreen({
    super.key,
    required this.mediaList,
    required this.initialIndex,
    this.onLockItem,
    this.onDeleteItem,
  });

  @override
  State<PhotoDetailsScreen> createState() => _PhotoDetailsScreenState();
}

class _PhotoDetailsScreenState extends State<PhotoDetailsScreen> {
  late PageController _pageController;
  late int _currentIndex;
  bool _showUi = true;
  bool _isPlayingVideo = false;
  late List<MediaItem> _items;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _items = List.from(widget.mediaList);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _toggleUi() {
    setState(() {
      _showUi = !_showUi;
    });
  }

  void _toggleFavorite() {
    setState(() {
      final current = _items[_currentIndex];
      _items[_currentIndex] = current.copyWith(isFavorite: !current.isFavorite);
    });
  }

  @override
  Widget build(BuildContext context) {
    final item = _items[_currentIndex];

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Main PageView with InteractiveViewer for zoom
          PageView.builder(
            controller: _pageController,
            itemCount: _items.length,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
                _isPlayingVideo = false;
              });
            },
            itemBuilder: (context, index) {
              final media = _items[index];
              return GestureDetector(
                onTap: _toggleUi,
                child: Center(
                  child: Hero(
                    tag: 'media_${media.id}',
                    child: InteractiveViewer(
                      minScale: 0.8,
                      maxScale: 4.0,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Image.network(
                            media.url,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Container(
                              color: media.placeholderColor ?? Colors.grey.shade900,
                              width: double.infinity,
                              height: 300,
                              child: const Center(
                                child: Icon(Icons.image_not_supported, color: Colors.white54, size: 60),
                              ),
                            ),
                          ),
                          if (media.isVideo)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _isPlayingVideo = !_isPlayingVideo;
                                });
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black45,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.white, width: 2),
                                ),
                                padding: const EdgeInsets.all(16),
                                child: Icon(
                                  _isPlayingVideo ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 48,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          // Top App Bar
          if (_showUi)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 4, bottom: 8),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black87, Colors.transparent],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            DateFormat('d MMMM yyyy').format(item.dateTime),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            DateFormat('h:mm a').format(item.dateTime),
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        item.isFavorite ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: item.isFavorite ? Colors.amber : Colors.white,
                      ),
                      onPressed: _toggleFavorite,
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
                      onPressed: () => _showInfoBottomSheet(context, item),
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      onPressed: () => _showMoreMenu(context, item),
                    ),
                  ],
                ),
              ),
            ),

          // Bottom Action Bar (Share, Edit, Google Lens, Move to Locked, Delete)
          if (_showUi)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom + 12, top: 12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black87],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildActionButton(Icons.share_outlined, 'Share', () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Sharing "${item.title}"')),
                      );
                    }),
                    _buildActionButton(Icons.tune_outlined, 'Edit', () {
                      _showEditFilters(context);
                    }),
                    _buildActionButton(Icons.search_rounded, 'Lens', () {
                      _showLensResult(context, item);
                    }),
                    _buildActionButton(Icons.lock_outline_rounded, 'Lock', () {
                      _moveToLockedFolder(context, item);
                    }),
                    _buildActionButton(Icons.delete_outline_rounded, 'Delete', () {
                      _deleteItem(context, item);
                    }),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoBottomSheet(BuildContext context, MediaItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_outlined, color: Colors.blue),
                title: Text(DateFormat('EEEE, MMMM d, yyyy').format(item.dateTime)),
                subtitle: Text(DateFormat('h:mm:ss a').format(item.dateTime)),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.image_outlined, color: Colors.green),
                title: Text(item.resolution),
                subtitle: Text('${item.size} • ${item.isVideo ? "MP4 Video" : "JPEG Image"}'),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.place_outlined, color: Colors.redAccent),
                title: Text(item.location),
                subtitle: const Text('Secured storage on this device'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Enhance Photo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFilterOption('Original', Colors.grey),
                _buildFilterOption('Auto Enhance', Colors.amber),
                _buildFilterOption('Vivid', Colors.deepOrange),
                _buildFilterOption('B&W Film', Colors.blueGrey),
                _buildFilterOption('Warm Glow', Colors.orange),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String name, Color color) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Applied filter: $name')),
        );
      },
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.3),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white54),
            ),
            child: Icon(Icons.auto_fix_high, color: color, size: 20),
          ),
          const SizedBox(height: 6),
          Text(name, style: const TextStyle(color: Colors.white70, fontSize: 10)),
        ],
      ),
    );
  }

  void _showLensResult(BuildContext context, MediaItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.search_rounded, color: Colors.blue, size: 28),
                const SizedBox(width: 12),
                Text('Visual Search for "${item.title}"', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            const Text('Identified objects & similar visual matches:'),
            const SizedBox(height: 12),
            Chip(label: Text(item.isVideo ? 'Video Recording' : 'Portrait / Photography'), avatar: const Icon(Icons.label_outline, size: 16)),
            Chip(label: Text(item.location), avatar: const Icon(Icons.location_on_outlined, size: 16)),
          ],
        ),
      ),
    );
  }

  void _moveToLockedFolder(BuildContext context, MediaItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.lock_rounded, color: Colors.amber),
            SizedBox(width: 10),
            Text('Move to Locked Folder?'),
          ],
        ),
        content: const Text(
          'Items in Locked Folder can only be viewed with your passcode or fingerprint, and will not appear in the main photos grid.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              widget.onLockItem?.call(item);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item moved to Locked Folder')),
              );
            },
            child: const Text('Move to Locked'),
          ),
        ],
      ),
    );
  }

  void _deleteItem(BuildContext context, MediaItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Move to trash?'),
        content: const Text('This item will be moved to trash and permanently deleted after 30 days.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              widget.onDeleteItem?.call(item);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Moved to trash')),
              );
            },
            child: const Text('Move to trash', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showMoreMenu(BuildContext context, MediaItem item) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.add_to_photos_outlined),
              title: const Text('Add to album'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.archive_outlined),
              title: const Text('Move to archive'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text('Save to device gallery'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.wallpaper_outlined),
              title: const Text('Use as wallpaper'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
