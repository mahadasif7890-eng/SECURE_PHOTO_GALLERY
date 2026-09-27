import 'package:flutter/material.dart';
import '../screens/profile_screen.dart';
import 'google_photos_logo.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBackupTap;
  final VoidCallback? onAddTap;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onProfileTap;

  const CustomAppBar({
    super.key,
    this.onBackupTap,
    this.onAddTap,
    this.onNotificationTap,
    this.onProfileTap,
  });

  @override
  Size get preferredSize => const Size.fromHeight(60);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      bottom: false,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            // Google Photos Pinwheel Logo
            GestureDetector(
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Secure Photo Gallery'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
              child: const GooglePhotosLogo(size: 32),
            ),
            const SizedBox(width: 14),

            // "Backup is off" status
            InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onBackupTap ??
                  () {
                    _showBackupDialog(context);
                  },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                child: Row(
                  children: [
                    Text(
                      'Backup is off',
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white70 : const Color(0xFF1F1F1F),
                        letterSpacing: -0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),

            // Add (+) Icon
            IconButton(
              icon: Icon(
                Icons.add_outlined,
                size: 26,
                color: isDark ? Colors.white : const Color(0xFF1F1F1F),
              ),
              onPressed: onAddTap ??
                  () {
                    _showCreateNewSheet(context);
                  },
              tooltip: 'Create / Add',
            ),

            // Notification Bell Icon
            IconButton(
              icon: Icon(
                Icons.notifications_none_rounded,
                size: 26,
                color: isDark ? Colors.white : const Color(0xFF1F1F1F),
              ),
              onPressed: onNotificationTap ??
                  () {
                    _showNotificationsSheet(context);
                  },
              tooltip: 'Activity & Sharing',
            ),

            const SizedBox(width: 4),

            // User Profile Avatar with Backup status badge
            GestureDetector(
              onTap: onProfileTap ??
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const ProfileScreen()),
                    );
                  },
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF4285F4),
                        width: 2.2,
                      ),
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8E24AA), Color(0xFFD81B60)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'h',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -2,
                    bottom: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_off_rounded,
                        size: 11,
                        color: isDark ? Colors.white70 : const Color(0xFF5F6368),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateNewSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.65,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      'Create new',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildSheetItem(context, Icons.photo_album_outlined, 'Album'),
                  _buildSheetItem(context, Icons.dashboard_outlined, 'Collage', hasBadge: true),
                  _buildSheetItem(context, Icons.movie_outlined, 'Highlight video'),
                  _buildSheetItem(context, Icons.crop_portrait_rounded, 'Cinematic photo'),
                  _buildSheetItem(context, Icons.filter_none_rounded, 'Animation'),
                  _buildSheetItem(context, Icons.portrait_rounded, 'Remix', hasBadge: true),
                  _buildSheetItem(context, Icons.slow_motion_video_rounded, 'Video remix'),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Divider(),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    child: Text(
                      'Get photos',
                      style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(height: 6),
                  _buildSheetItem(context, Icons.sync_rounded, 'Share with a partner'),
                  _buildSheetItem(context, Icons.download_rounded, 'Import from other places'),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSheetItem(BuildContext context, IconData icon, String title, {bool hasBadge = false}) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      leading: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(icon, size: 24),
          if (hasBadge)
            Positioned(
              right: -2,
              top: -2,
              child: Container(
                width: 7,
                height: 7,
                decoration: const BoxDecoration(
                  color: Color(0xFFD93025),
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Selected: $title'), duration: const Duration(seconds: 1)),
        );
      },
    );
  }

  void _showBackupDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.cloud_upload_outlined, color: Colors.blue, size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Cloud Backup',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Back up photos & videos securely to your account',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.shield_outlined, color: Colors.green),
                title: const Text('Local Encrypted Storage Active'),
                subtitle: const Text('All your media is stored safely on device'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A73E8),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Backup settings updated')),
                  );
                },
                child: const Text('Turn on backup'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.notifications_none_rounded, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text(
                'No new sharing activity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text(
                'When friends share photos or invite you to albums, they will appear here.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }
}
