import 'package:flutter/material.dart';
import '../models/media_item.dart';
import 'photo_details_screen.dart';

class LockedVaultScreen extends StatefulWidget {
  final List<MediaItem> lockedItems;
  final Function(MediaItem)? onUnlockItem;

  const LockedVaultScreen({
    super.key,
    required this.lockedItems,
    this.onUnlockItem,
  });

  @override
  State<LockedVaultScreen> createState() => _LockedVaultScreenState();
}

class _LockedVaultScreenState extends State<LockedVaultScreen> {
  bool _isUnlocked = false;
  String _pin = '';
  final String _correctPin = '1234';
  bool _showError = false;

  void _onDigitPressed(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _showError = false;
      });

      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDeletePressed() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _showError = false;
      });
    }
  }

  void _verifyPin() {
    if (_pin == _correctPin) {
      setState(() {
        _isUnlocked = true;
      });
    } else {
      setState(() {
        _showError = true;
        _pin = '';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Incorrect PIN. (Hint: Default PIN is 1234)'),
          backgroundColor: Colors.redAccent,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _simulateBiometrics() {
    setState(() {
      _isUnlocked = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Biometrics verified successfully'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              _isUnlocked ? Icons.lock_open_rounded : Icons.lock_rounded,
              color: _isUnlocked ? Colors.green : Colors.amber.shade700,
              size: 22,
            ),
            const SizedBox(width: 8),
            const Flexible(
              child: Text(
                'Locked Folder',
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          if (_isUnlocked)
            IconButton(
              icon: const Icon(Icons.lock_outline),
              tooltip: 'Lock now',
              onPressed: () {
                setState(() {
                  _isUnlocked = false;
                  _pin = '';
                });
              },
            ),
        ],
      ),
      body: _isUnlocked ? _buildVaultContent() : _buildPinKeypad(),
    );
  }

  Widget _buildPinKeypad() {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final isCompact = screenHeight < 600;
    final buttonSize = isCompact ? 56.0 : 70.0;
    final rowGap = isCompact ? 10.0 : 16.0;

    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.paddingOf(context).bottom + 92),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isCompact ? 14 : 20),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.shield_outlined,
                    size: isCompact ? 40 : 56,
                    color: Colors.amber.shade800,
                  ),
                ),
                SizedBox(height: isCompact ? 12 : 20),
                Text(
                  'Enter Gallery Passcode',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isCompact ? 19 : 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Default PIN is 1234',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                SizedBox(height: isCompact ? 18 : 28),

                // PIN Indicator Dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isFilled = index < _pin.length;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      width: 18,
                      height: 18,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isFilled ? const Color(0xFF1A73E8) : Colors.transparent,
                        border: Border.all(
                          color: _showError
                              ? Colors.red
                              : (isFilled ? const Color(0xFF1A73E8) : Colors.grey),
                          width: 2,
                        ),
                      ),
                    );
                  }),
                ),
                SizedBox(height: isCompact ? 22 : 40),

                // Number Grid Keypad
                SizedBox(
                  width: 280,
                  child: Column(
                    children: [
                      _buildKeypadRow(['1', '2', '3'], buttonSize),
                      SizedBox(height: rowGap),
                      _buildKeypadRow(['4', '5', '6'], buttonSize),
                      SizedBox(height: rowGap),
                      _buildKeypadRow(['7', '8', '9'], buttonSize),
                      SizedBox(height: rowGap),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.fingerprint_rounded,
                              size: isCompact ? 30 : 36,
                              color: const Color(0xFF1A73E8),
                            ),
                            onPressed: _simulateBiometrics,
                            tooltip: 'Use Fingerprint',
                          ),
                          _buildKeypadButton('0', buttonSize),
                          IconButton(
                            icon: Icon(
                              Icons.backspace_outlined,
                              size: isCompact ? 24 : 28,
                            ),
                            onPressed: _onDeletePressed,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildKeypadRow(List<String> digits, double buttonSize) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildKeypadButton(d, buttonSize)).toList(),
    );
  }

  Widget _buildKeypadButton(String digit, double buttonSize) {
    return InkWell(
      onTap: () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: TextStyle(
            fontSize: buttonSize < 64 ? 22 : 26,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildVaultContent() {
    if (widget.lockedItems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline_rounded, size: 72, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'Locked Folder is empty',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Move sensitive photos & videos here from the main gallery to keep them safe and hidden.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        const double maxContentWidth = 840.0;
        final double horizontalInset =
            width > maxContentWidth ? (width - maxContentWidth) / 2 : 0.0;
        final double gridSpacing = width >= 600 ? 6.0 : 4.0;

        return GridView.builder(
          padding: EdgeInsets.fromLTRB(
            horizontalInset + gridSpacing,
            gridSpacing,
            horizontalInset + gridSpacing,
            MediaQuery.paddingOf(context).bottom + 96,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: gridSpacing,
            mainAxisSpacing: gridSpacing,
            childAspectRatio: 1.0,
          ),
          itemCount: widget.lockedItems.length,
          itemBuilder: (context, index) {
            final item = widget.lockedItems[index];
            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => PhotoDetailsScreen(
                      mediaList: widget.lockedItems,
                      initialIndex: index,
                      heroTagPrefix: 'vault',
                    ),
                  ),
                );
              },
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Hero(
                    tag: 'vault_${item.id}',
                    child: Image.network(
                      item.url,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: item.placeholderColor ?? Colors.grey.shade800,
                        child: const Icon(Icons.image, color: Colors.white54),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.lock, color: Colors.white, size: 14),
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: IconButton(
                      icon: const Icon(Icons.lock_open, color: Colors.white, size: 20),
                      onPressed: () {
                        widget.onUnlockItem?.call(item);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Item restored to main gallery')),
                        );
                      },
                      tooltip: 'Restore to public gallery',
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
