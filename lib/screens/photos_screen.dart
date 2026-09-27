import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../widgets/stories_carousel.dart';
import '../widgets/media_grid_item.dart';
import '../widgets/photo_details_screen.dart';

class PhotosScreen extends StatefulWidget {
  final List<MediaItem> mediaItems;
  final List<MemoryStory> stories;
  final Function(MediaItem) onLockItem;
  final Function(MediaItem) onDeleteItem;
  final Function(List<MediaItem>) onBatchLock;
  final Function(List<MediaItem>) onBatchDelete;

  const PhotosScreen({
    super.key,
    required this.mediaItems,
    required this.stories,
    required this.onLockItem,
    required this.onDeleteItem,
    required this.onBatchLock,
    required this.onBatchDelete,
  });

  @override
  State<PhotosScreen> createState() => _PhotosScreenState();
}

class _PhotosScreenState extends State<PhotosScreen> {
  final Set<String> _selectedIds = {};
  final int _columnCount = 3;

  bool get _isSelectionMode => _selectedIds.isNotEmpty;

  void _toggleSelection(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedIds.clear();
    });
  }

  void _selectAll() {
    setState(() {
      _selectedIds.addAll(widget.mediaItems.map((m) => m.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _isSelectionMode ? _buildSelectionAppBar() : null,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Stories / Memories Carousel at the top
          if (!_isSelectionMode) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 8),
                child: StoriesCarousel(stories: widget.stories),
              ),
            ),
          ],

          // Media Grid
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _columnCount,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                childAspectRatio: 1.0,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = widget.mediaItems[index];
                  final isSelected = _selectedIds.contains(item.id);

                  return MediaGridItem(
                    item: item,
                    isSelected: isSelected,
                    isSelectionMode: _isSelectionMode,
                    onTap: () {
                      if (_isSelectionMode) {
                        _toggleSelection(item.id);
                      } else {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder: (context, animation, secondaryAnimation) =>
                                PhotoDetailsScreen(
                              mediaList: widget.mediaItems,
                              initialIndex: index,
                              onLockItem: widget.onLockItem,
                              onDeleteItem: widget.onDeleteItem,
                            ),
                            transitionsBuilder: (context, animation, secondaryAnimation, child) {
                              return FadeTransition(opacity: animation, child: child);
                            },
                          ),
                        );
                      }
                    },
                    onLongPress: () {
                      _toggleSelection(item.id);
                    },
                  );
                },
                childCount: widget.mediaItems.length,
              ),
            ),
          ),

          // Extra bottom padding so floating bottom pill doesn't obscure content
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildSelectionAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.close),
        onPressed: _clearSelection,
      ),
      title: Text('${_selectedIds.length} selected'),
      actions: [
        IconButton(
          icon: const Icon(Icons.select_all_rounded),
          tooltip: 'Select all',
          onPressed: _selectAll,
        ),
        IconButton(
          icon: const Icon(Icons.lock_outline_rounded),
          tooltip: 'Move to Locked Folder',
          onPressed: () {
            final selectedItems = widget.mediaItems
                .where((m) => _selectedIds.contains(m.id))
                .toList();
            widget.onBatchLock(selectedItems);
            _clearSelection();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${selectedItems.length} items moved to Locked Folder')),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: 'Share',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sharing ${_selectedIds.length} items')),
            );
            _clearSelection();
          },
        ),
        IconButton(
          icon: const Icon(Icons.delete_outline_rounded),
          tooltip: 'Delete',
          onPressed: () {
            final selectedItems = widget.mediaItems
                .where((m) => _selectedIds.contains(m.id))
                .toList();
            widget.onBatchDelete(selectedItems);
            _clearSelection();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${selectedItems.length} items moved to trash')),
            );
          },
        ),
      ],
    );
  }
}
