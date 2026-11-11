import 'package:flutter/material.dart';
import '../models/media_item.dart';
import '../widgets/media_grid_item.dart';
import '../widgets/photo_details_screen.dart';

class SearchScreen extends StatefulWidget {
  final List<MediaItem> allMedia;
  final Function(MediaItem) onLockItem;
  final Function(MediaItem) onDeleteItem;

  const SearchScreen({
    super.key,
    required this.allMedia,
    required this.onLockItem,
    required this.onDeleteItem,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  final TextEditingController _searchController = TextEditingController();

  List<MediaItem> get _filteredMedia {
    if (_query.trim().isEmpty) {
      return widget.allMedia;
    }
    final q = _query.trim().toLowerCase();
    return widget.allMedia.where((m) {
      if (q == 'video' || q == 'videos') {
        return m.isVideo;
      }
      if (q == 'notes & docs' || q == 'notes') {
        final text = '${m.title} ${m.description}'.toLowerCase();
        return text.contains('note') ||
            text.contains('lecture') ||
            text.contains('certificate') ||
            text.contains('matrix') ||
            text.contains('exam');
      }
      if (q == 'people & pets' || q == 'people') {
        final text = '${m.title} ${m.description}'.toLowerCase();
        return text.contains('friend') ||
            text.contains('selfie') ||
            text.contains('portrait') ||
            text.contains('group') ||
            text.contains('reaction');
      }
      return m.title.toLowerCase().contains(q) ||
          m.description.toLowerCase().contains(q) ||
          m.location.toLowerCase().contains(q) ||
          (m.isVideo && 'video'.contains(q));
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          const double maxContentWidth = 840.0;
          final double horizontalInset =
              width > maxContentWidth ? (width - maxContentWidth) / 2 : 0.0;
          final double gridSpacing = width >= 600 ? 6.0 : 4.0;

          return CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalInset + 16,
                    16,
                    horizontalInset + 16,
                    12,
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) {
                      setState(() {
                        _query = val;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search people, places, documents, things...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                setState(() {
                                  _query = '';
                                });
                              },
                            )
                          : const Icon(Icons.camera_alt_outlined),
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(28),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ),
              ),

              if (_query.isEmpty) ...[
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalInset + 18,
                      8,
                      horizontalInset + 18,
                      8,
                    ),
                    child: const Text(
                      'Explore Categories',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: horizontalInset + 16),
                    child: Row(
                      children: [
                        _buildCategoryChip('People & Pets', Icons.people_outline),
                        _buildCategoryChip('Videos', Icons.videocam_outlined),
                        _buildCategoryChip('Notes & Docs', Icons.description_outlined),
                        _buildCategoryChip('Places', Icons.place_outlined),
                        _buildCategoryChip('Celebrations', Icons.cake_outlined),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 16)),
              ],

              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalInset + gridSpacing,
                  vertical: gridSpacing,
                ),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: gridSpacing,
                    mainAxisSpacing: gridSpacing,
                    childAspectRatio: 1.0,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = _filteredMedia[index];
                      return MediaGridItem(
                        item: item,
                        heroTagPrefix: 'search',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => PhotoDetailsScreen(
                                mediaList: _filteredMedia,
                                initialIndex: index,
                                heroTagPrefix: 'search',
                                onLockItem: widget.onLockItem,
                                onDeleteItem: widget.onDeleteItem,
                              ),
                            ),
                          );
                        },
                        onLongPress: () {},
                      );
                    },
                    childCount: _filteredMedia.length,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: SizedBox(height: bottomInset + 96),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCategoryChip(String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16),
        label: Text(label),
        onPressed: () {
          final queryValue = label == 'Places'
              ? 'campus'
              : (label == 'Celebrations' ? 'celebration' : label.toLowerCase());
          _searchController.text = queryValue;
          setState(() {
            _query = queryValue;
          });
        },
      ),
    );
  }
}
