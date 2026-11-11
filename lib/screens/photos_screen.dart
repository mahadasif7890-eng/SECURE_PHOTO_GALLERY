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
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      appBar: _isSelectionMode ? _buildSelectionAppBar() : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const double maxContentWidth = 840.0;
          final double horizontalInset =
              width > maxContentWidth ? (width - maxContentWidth) / 2 : 0.0;
          final double gridSpacing = width >= 600 ? 6.0 : 4.0;

          return Scrollbar(
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: [
                // Stories / Memories Carousel at the top
                if (!_isSelectionMode)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        horizontalInset,
                        4,
                        horizontalInset,
                        8,
                      ),
                      child: StoriesCarousel(stories: widget.stories),
                    ),
                  ),

                // Media Grid (3 photographs per row with consistent spacing)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: horizontalInset + gridSpacing,
                    vertical: gridSpacing,
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _columnCount,
                      crossAxisSpacing: gridSpacing,
                      mainAxisSpacing: gridSpacing,
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
                          heroTagPrefix: 'photos',
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
                                    heroTagPrefix: 'photos',
                                    onLockItem: widget.onLockItem,
                                    onDeleteItem: widget.onDeleteItem,
                                  ),
                                  transitionsBuilder:
                                      (context, animation, secondaryAnimation, child) {
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
                SliverToBoxAdapter(
                  child: SizedBox(height: bottomInset + 96),
                ),
              ],
            ),
          );
        },
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
