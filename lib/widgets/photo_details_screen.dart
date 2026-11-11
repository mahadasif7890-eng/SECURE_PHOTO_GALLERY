import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/media_item.dart';

class PhotoDetailsScreen extends StatefulWidget {
  final List<MediaItem> mediaList;
  final int initialIndex;
  final String heroTagPrefix;
  final Function(MediaItem)? onLockItem;
  final Function(MediaItem)? onDeleteItem;

  const PhotoDetailsScreen({
    super.key,
    required this.mediaList,
    required this.initialIndex,
    this.heroTagPrefix = 'media',
    this.onLockItem,
    this.onDeleteItem,
  });

  @override
  State<PhotoDetailsScreen> createState() => _PhotoDetailsScreenState();
}

class _PhotoDetailsScreenState extends State<PhotoDetailsScreen> {
  static const List<String> _months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December',
  ];

  static const List<String> _weekdays = [
    'Monday',
    'Tuesday',
    'Wednesday',
    'Thursday',
    'Friday',
    'Saturday',
    'Sunday',
  ];

  late PageController _pageController;
  late int _currentIndex;
  bool _showUi = true;
  bool _isPlayingVideo = false;
  late List<MediaItem> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.mediaList);
    _currentIndex = _items.isEmpty
        ? 0
        : widget.initialIndex.clamp(0, _items.length - 1);
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  String _formatShortDate(DateTime dt) {
    return '${dt.day} ${_months[dt.month - 1]} ${dt.year}';
  }

  String _formatFullDate(DateTime dt) {
    final weekday = _weekdays[dt.weekday - 1];
    final month = _months[dt.month - 1];
    return '$weekday, $month ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt, {bool includeSeconds = false}) {
    final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final period = dt.hour >= 12 ? 'PM' : 'AM';
    if (includeSeconds) {
      final second = dt.second.toString().padLeft(2, '0');
      return '$hour12:$minute:$second $period';
    }
    return '$hour12:$minute $period';
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

  void _goToPage(int index) {
    if (index < 0 || index >= _items.length) return;
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_items.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('No media available', style: TextStyle(color: Colors.white70)),
        ),
      );
    }

    final item = _items[_currentIndex];
    final size = MediaQuery.sizeOf(context);
    final isWideScreen = size.width >= 700;
    final isCompactHeight = size.height < 520;
    final isNarrowWidth = size.width < 360;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.of(context).pop(),
        const SingleActivator(LogicalKeyboardKey.arrowLeft): () => _goToPage(_currentIndex - 1),
        const SingleActivator(LogicalKeyboardKey.arrowRight): () => _goToPage(_currentIndex + 1),
      },
      child: Focus(
        autofocus: true,
        child: Scaffold(
          backgroundColor: Colors.black,
          body: GestureDetector(
            onVerticalDragEnd: (details) {
              if (details.primaryVelocity != null && details.primaryVelocity! > 320) {
                Navigator.of(context).pop();
              }
            },
            child: Stack(
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
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: isWideScreen ? 48 : 0,
                            vertical: isCompactHeight ? 8 : 0,
                          ),
                          child: Hero(
                            tag: '${widget.heroTagPrefix}_${media.id}',
                            child: InteractiveViewer(
                              minScale: 0.8,
                              maxScale: 4.0,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Image.network(
                                    media.url,
                                    fit: BoxFit.contain,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: (media.placeholderColor ?? Colors.grey.shade900)
                                            .withValues(alpha: 0.35),
                                        width: double.infinity,
                                        height: 300,
                                        child: const Center(
                                          child: CircularProgressIndicator(color: Colors.white70),
                                        ),
                                      );
                                    },
                                    errorBuilder: (context, error, stackTrace) => Container(
                                      color: media.placeholderColor ?? Colors.grey.shade900,
                                      width: double.infinity,
                                      height: 300,
                                      child: const Center(
                                        child: Icon(
                                          Icons.image_not_supported,
                                          color: Colors.white54,
                                          size: 60,
                                        ),
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
                                          _isPlayingVideo
                                              ? Icons.pause_rounded
                                              : Icons.play_arrow_rounded,
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
                      ),
                    );
                  },
                ),

                // Desktop / Tablet Side Navigation Buttons
                if (_showUi && isWideScreen && _currentIndex > 0)
                  Positioned(
                    left: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_left_rounded, color: Colors.white, size: 30),
                          tooltip: 'Previous photo',
                          onPressed: () => _goToPage(_currentIndex - 1),
                        ),
                      ),
                    ),
                  ),
                if (_showUi && isWideScreen && _currentIndex < _items.length - 1)
                  Positioned(
                    right: 16,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: Material(
                        color: Colors.black54,
                        shape: const CircleBorder(),
                        child: IconButton(
                          icon: const Icon(Icons.chevron_right_rounded, color: Colors.white, size: 30),
                          tooltip: 'Next photo',
                          onPressed: () => _goToPage(_currentIndex + 1),
                        ),
                      ),
                    ),
                  ),

                // Top App Bar
                if (_showUi)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: MediaQuery.paddingOf(context).top + 4,
                        bottom: isCompactHeight ? 4 : 8,
                      ),
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.black87, Colors.transparent],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 900),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                                tooltip: 'Back to gallery',
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _formatShortDate(item.dateTime),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      _formatTime(item.dateTime),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
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
                                tooltip: item.isFavorite ? 'Remove from favorites' : 'Favorite',
                                onPressed: _toggleFavorite,
                              ),
                              IconButton(
                                icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
                                tooltip: 'Photo details',
                                onPressed: () => _showInfoBottomSheet(context, item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.more_vert, color: Colors.white),
                                tooltip: 'More options',
                                onPressed: () => _showMoreMenu(context, item),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Bottom Caption (Title & Description) + Action Bar
                if (_showUi)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.only(
                        top: isCompactHeight ? 16 : 28,
                        bottom: MediaQuery.paddingOf(context).bottom + (isCompactHeight ? 6 : 12),
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.72),
                            Colors.black.withValues(alpha: 0.92),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 800),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isWideScreen ? 24 : 18,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            item.title,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: isCompactHeight ? 15 : 17.5,
                                              fontWeight: FontWeight.w700,
                                              letterSpacing: -0.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${_currentIndex + 1} / ${_items.length}',
                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                    if (item.description.isNotEmpty) ...[
                                      SizedBox(height: isCompactHeight ? 2 : 4),
                                      Text(
                                        item.description,
                                        maxLines: isCompactHeight ? 1 : 3,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: 0.86),
                                          fontSize: isCompactHeight ? 12 : 13.5,
                                          height: 1.35,
                                        ),
                                      ),
                                    ],
                                    if (!isCompactHeight) ...[
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.place_outlined,
                                            color: Colors.white60,
                                            size: 14,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              item.location,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                color: Colors.white60,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              SizedBox(height: isCompactHeight ? 6 : 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildActionButton(Icons.share_outlined, 'Share', () {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Sharing "${item.title}"')),
                                      );
                                    }, compact: isCompactHeight || isNarrowWidth),
                                  ),
                                  Expanded(
                                    child: _buildActionButton(Icons.tune_outlined, 'Edit', () {
                                      _showEditFilters(context);
                                    }, compact: isCompactHeight || isNarrowWidth),
                                  ),
                                  Expanded(
                                    child: _buildActionButton(Icons.search_rounded, 'Lens', () {
                                      _showLensResult(context, item);
                                    }, compact: isCompactHeight || isNarrowWidth),
                                  ),
                                  Expanded(
                                    child: _buildActionButton(Icons.lock_outline_rounded, 'Lock', () {
                                      _moveToLockedFolder(context, item);
                                    }, compact: isCompactHeight || isNarrowWidth),
                                  ),
                                  Expanded(
                                    child:
                                        _buildActionButton(Icons.delete_outline_rounded, 'Delete', () {
                                      _deleteItem(context, item);
                                    }, compact: isCompactHeight || isNarrowWidth),
                                  ),
                                ],
                              ),
                            ],
                          ),
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

  Widget _buildActionButton(
    IconData icon,
    String label,
    VoidCallback onTap, {
    bool compact = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 4 : 8,
          vertical: compact ? 4 : 6,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: compact ? 20 : 24),
            SizedBox(height: compact ? 2 : 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white,
                fontSize: compact ? 10 : 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoBottomSheet(BuildContext context, MediaItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    item.description,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined, color: Colors.blue),
                  title: Text(_formatFullDate(item.dateTime)),
                  subtitle: Text(_formatTime(item.dateTime, includeSeconds: true)),
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
          ),
        );
      },
    );
  }

  void _showEditFilters(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black87,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enhance Photo',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.spaceAround,
                children: [
                  _buildFilterOption('Original', Colors.grey),
                  _buildFilterOption('Auto Enhance', Colors.amber),
                  _buildFilterOption('Vivid', Colors.deepOrange),
                  _buildFilterOption('B&W Film', Colors.blueGrey),
                  _buildFilterOption('Warm Glow', Colors.orange),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.search_rounded, color: Colors.blue, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Visual Search for "${item.title}"',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Identified objects & similar visual matches:'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(
                    label: Text(item.isVideo ? 'Video Recording' : 'Portrait / Photography'),
                    avatar: const Icon(Icons.label_outline, size: 16),
                  ),
                  Chip(
                    label: Text(item.location),
                    avatar: const Icon(Icons.location_on_outlined, size: 16),
                  ),
                ],
              ),
            ],
          ),
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
            Expanded(child: Text('Move to Locked Folder?')),
          ],
        ),
        content: const Text(
          'Items in Locked Folder can only be viewed with your passcode or fingerprint, and will not appear in the main photos grid.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade800,
              foregroundColor: Colors.white,
            ),
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
        content: const Text(
          'This item will be moved to trash and permanently deleted after 30 days.',
        ),
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
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
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
