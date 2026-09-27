import 'package:flutter/material.dart';
import '../data/sample_data.dart';
import '../models/media_item.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/floating_bottom_bar.dart';
import '../widgets/locked_vault_screen.dart';
import 'photos_screen.dart';
import 'collections_screen.dart';
import 'search_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentTabIndex = 0;
  late List<MediaItem> _mediaItems;
  late List<MediaItem> _lockedItems;
  late List<MemoryStory> _stories;
  late List<CollectionAlbum> _collections;

  @override
  void initState() {
    super.initState();
    _mediaItems = List.from(SampleData.allMedia);
    _lockedItems = [
      SampleData.allMedia[2],
      SampleData.allMedia[7],
    ];
    _stories = List.from(SampleData.memoryStories);
    _collections = List.from(SampleData.collections);
  }

  void _lockItem(MediaItem item) {
    setState(() {
      _mediaItems.removeWhere((m) => m.id == item.id);
      _lockedItems.add(item.copyWith(isLocked: true));
    });
  }

  void _unlockItem(MediaItem item) {
    setState(() {
      _lockedItems.removeWhere((m) => m.id == item.id);
      _mediaItems.insert(0, item.copyWith(isLocked: false));
    });
  }

  void _deleteItem(MediaItem item) {
    setState(() {
      _mediaItems.removeWhere((m) => m.id == item.id);
      _lockedItems.removeWhere((m) => m.id == item.id);
    });
  }

  void _batchLock(List<MediaItem> items) {
    setState(() {
      final ids = items.map((e) => e.id).toSet();
      _mediaItems.removeWhere((m) => ids.contains(m.id));
      _lockedItems.addAll(items.map((m) => m.copyWith(isLocked: true)));
    });
  }

  void _batchDelete(List<MediaItem> items) {
    setState(() {
      final ids = items.map((e) => e.id).toSet();
      _mediaItems.removeWhere((m) => ids.contains(m.id));
      _lockedItems.removeWhere((m) => ids.contains(m.id));
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      // 0. Photos timeline
      PhotosScreen(
        mediaItems: _mediaItems,
        stories: _stories,
        onLockItem: _lockItem,
        onDeleteItem: _deleteItem,
        onBatchLock: _batchLock,
        onBatchDelete: _batchDelete,
      ),
      // 1. Collections tab
      CollectionsScreen(
        collections: _collections,
        lockedItems: _lockedItems,
        onUnlockItem: _unlockItem,
      ),
      // 2. Locked Folder with Passcode screen
      LockedVaultScreen(
        lockedItems: _lockedItems,
        onUnlockItem: _unlockItem,
      ),
      // 3. Search / Google Lens
      SearchScreen(
        allMedia: _mediaItems,
        onLockItem: _lockItem,
        onDeleteItem: _deleteItem,
      ),
    ];

    return Scaffold(
      appBar: _currentTabIndex == 2 ? null : const CustomAppBar(),
      body: Stack(
        children: [
          IndexedStack(
            index: _currentTabIndex,
            children: pages,
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: FloatingBottomBar(
              currentIndex: _currentTabIndex == 3 ? -1 : _currentTabIndex,
              onTabSelected: (index) {
                setState(() {
                  _currentTabIndex = index;
                });
              },
              onSearchLensTap: () {
                setState(() {
                  _currentTabIndex = 3;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}
