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
    final q = _query.toLowerCase();
    return widget.allMedia.where((m) {
      return m.title.toLowerCase().contains(q) ||
          m.location.toLowerCase().contains(q) ||
          (m.isVideo && q == 'video');
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                ),
              ),
            ),
          ),

          if (_query.isEmpty) ...[
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(18, 8, 18, 8),
                child: Text(
                  'Explore Categories',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
            padding: const EdgeInsets.symmetric(horizontal: 2),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 2,
                mainAxisSpacing: 2,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final item = _filteredMedia[index];
                  return MediaGridItem(
                    item: item,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => PhotoDetailsScreen(
                            mediaList: _filteredMedia,
                            initialIndex: index,
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

          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
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
          _searchController.text = label.toLowerCase();
          setState(() {
            _query = label.toLowerCase();
          });
        },
      ),
    );
  }
}
