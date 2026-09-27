import 'package:flutter/material.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _backupEnabled = false;
  bool _biometricsEnabled = true;
  bool _autoSync = true;
  bool _highQualityBackup = true;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA);
    final borderColor = isDark ? const Color(0xFF333333) : const Color(0xFFE5E7EB);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account & Profile'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
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
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Color(0xFF1A73E8),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.edit, color: Colors.white, size: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Alex Johnson',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'alex@gmail.com',
                    style: TextStyle(color: Colors.grey, fontSize: 13.5),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF34A853).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_user_rounded, color: Color(0xFF34A853), size: 16),
                        SizedBox(width: 6),
                        Text(
                          'Encrypted Vault Active',
                          style: TextStyle(
                            color: Color(0xFF34A853),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Storage Overview
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Device & Vault Storage',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '14.2 GB of 128 GB',
                        style: TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Row(
                      children: [
                        Expanded(flex: 40, child: Container(height: 8, color: const Color(0xFF4285F4))),
                        Expanded(flex: 25, child: Container(height: 8, color: const Color(0xFFEA4335))),
                        Expanded(flex: 15, child: Container(height: 8, color: const Color(0xFFFBBC05))),
                        Expanded(flex: 120, child: Container(height: 8, color: Colors.grey.shade300)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStorageLegend(const Color(0xFF4285F4), 'Photos (8 GB)'),
                      _buildStorageLegend(const Color(0xFFEA4335), 'Videos (5 GB)'),
                      _buildStorageLegend(const Color(0xFFFBBC05), 'Locked (1.2 GB)'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Security & Privacy Settings
            _buildSectionHeader('Security & Privacy'),
            _buildSettingsGroup(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.fingerprint_rounded, color: Color(0xFF1A73E8)),
                  title: const Text('Biometric Unlock'),
                  subtitle: const Text('Use Fingerprint / Face ID for Locked Folder'),
                  value: _biometricsEnabled,
                  onChanged: (val) => setState(() => _biometricsEnabled = val),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.pin_outlined, color: Color(0xFF34A853)),
                  title: const Text('Change PIN Code'),
                  subtitle: const Text('Update 4-digit gallery passcode'),
                  trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('PIN settings updated')),
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.vpn_key_outlined, color: Color(0xFFFBBC05)),
                  title: const Text('Local Encryption Key'),
                  subtitle: const Text('AES-256 Bit on-device key active'),
                  trailing: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Backup & Sync
            _buildSectionHeader('Cloud & Sync'),
            _buildSettingsGroup(
              cardColor: cardColor,
              borderColor: borderColor,
              children: [
                SwitchListTile(
                  secondary: const Icon(Icons.cloud_upload_outlined, color: Color(0xFF4285F4)),
                  title: const Text('Cloud Backup'),
                  subtitle: const Text('Automatic backup to Google Photos cloud'),
                  value: _backupEnabled,
                  onChanged: (val) => setState(() => _backupEnabled = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.sync_rounded, color: Color(0xFF8E24AA)),
                  title: const Text('Auto-sync on Wi-Fi'),
                  subtitle: const Text('Save cellular data while uploading'),
                  value: _autoSync,
                  onChanged: (val) => setState(() => _autoSync = val),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: const Icon(Icons.high_quality_outlined, color: Color(0xFFEA4335)),
                  title: const Text('Original Quality Upload'),
                  subtitle: const Text('Preserve full resolution and EXIF data'),
                  value: _highQualityBackup,
                  onChanged: (val) => setState(() => _highQualityBackup = val),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Log Out Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () {
                  _showLogoutDialog(context);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout_rounded, size: 18),
                    SizedBox(width: 8),
                    Text('Log Out from Gallery', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildSettingsGroup({
    required Color cardColor,
    required Color borderColor,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildStorageLegend(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(text, style: const TextStyle(fontSize: 11.5, color: Colors.grey)),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Log out?'),
        content: const Text('Are you sure you want to log out from Secure Photo Gallery?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const AuthScreen()),
                (route) => false,
              );
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
