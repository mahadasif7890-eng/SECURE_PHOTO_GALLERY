import 'package:flutter/material.dart';
import '../models/media_item.dart';

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
            const Text('Locked Folder'),
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
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.shield_outlined, size: 56, color: Colors.amber.shade800),
              ),
              const SizedBox(height: 20),
              const Text(
                'Enter Gallery Passcode',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Default PIN is 1234',
                style: TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 28),

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
                        color: _showError ? Colors.red : (isFilled ? const Color(0xFF1A73E8) : Colors.grey),
                        width: 2,
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 40),

              // Number Grid Keypad
              SizedBox(
                width: 280,
                child: Column(
                  children: [
                    _buildKeypadRow(['1', '2', '3']),
                    const SizedBox(height: 16),
                    _buildKeypadRow(['4', '5', '6']),
                    const SizedBox(height: 16),
                    _buildKeypadRow(['7', '8', '9']),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.fingerprint_rounded, size: 36, color: Color(0xFF1A73E8)),
                          onPressed: _simulateBiometrics,
                          tooltip: 'Use Fingerprint',
                        ),
                        _buildKeypadButton('0'),
                        IconButton(
                          icon: const Icon(Icons.backspace_outlined, size: 28),
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
    );
  }

  Widget _buildKeypadRow(List<String> digits) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: digits.map((d) => _buildKeypadButton(d)).toList(),
    );
  }

  Widget _buildKeypadButton(String digit) {
    return InkWell(
      onTap: () => _onDigitPressed(digit),
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.grey.shade200,
        ),
        alignment: Alignment.center,
        child: Text(
          digit,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
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

    return GridView.builder(
      padding: const EdgeInsets.all(4),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 3,
        mainAxisSpacing: 3,
      ),
      itemCount: widget.lockedItems.length,
      itemBuilder: (context, index) {
        final item = widget.lockedItems[index];
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              item.url,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: item.placeholderColor ?? Colors.grey.shade800,
                child: const Icon(Icons.image, color: Colors.white54),
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
        );
      },
    );
  }
}
