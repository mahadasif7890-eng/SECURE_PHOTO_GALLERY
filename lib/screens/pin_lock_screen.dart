import 'package:flutter/material.dart';
import '../services/auth_service.dart';


class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController pinController = TextEditingController();
  String message = '';
  int wrongAttempts = 0;
  final int maxAttempts = 5;
  bool isLockedOut = false;

  void checkPin() async {
    if (isLockedOut) {
      setState(() {
        message = 'Too many attempts. Wait 30 seconds.';
      });
      return;
    }

    bool isCorrect = await verifyPin(pinController.text);

    if (isCorrect) {
      setState(() {
        message = 'Unlocked! ✅';
        wrongAttempts = 0;
      });
    } else {
      wrongAttempts++;
      if (wrongAttempts >= maxAttempts) {
        setState(() {
          isLockedOut = true;
          message = 'Too many wrong attempts. Locked for 30 seconds.';
        });
        Future.delayed(const Duration(seconds: 30), () {
          setState(() {
            isLockedOut = false;
            wrongAttempts = 0;
            message = 'You can try again now.';
          });
        });
      } else {
        setState(() {
          message = 'Wrong PIN ❌ (${maxAttempts - wrongAttempts} attempts left)';
        });
      }
    }
  }

  void useBiometric() async {
    bool success = await authenticateWithBiometrics();
    setState(() {
      message = success ? 'Unlocked with biometric! ✅' : 'Biometric failed ❌';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter PIN')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              enabled: !isLockedOut,
              decoration: const InputDecoration(labelText: 'Enter your PIN'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLockedOut ? null : checkPin,
              child: const Text('Unlock'),
            ),
            const SizedBox(height: 10),
            Text(message),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: isLockedOut ? null : useBiometric,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Use Biometric'),
            ),
          ],
        ),
      ),
    );
  }
}