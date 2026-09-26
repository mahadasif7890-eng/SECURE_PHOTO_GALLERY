import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../services/auth_service.dart';

final storage = FlutterSecureStorage();

String hashPinCheck(String pin) {
  var bytes = utf8.encode(pin);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

Future<bool> verifyPin(String enteredPin) async {
  String? savedHash = await storage.read(key: 'user_pin');
  String enteredHash = hashPinCheck(enteredPin);
  return savedHash == enteredHash;
}

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final TextEditingController pinController = TextEditingController();
  String message = '';

  void checkPin() async {
    bool isCorrect = await verifyPin(pinController.text);
    setState(() {
      message = isCorrect ? 'Unlocked! ✅' : 'Wrong PIN ❌';
    });
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
              decoration: const InputDecoration(labelText: 'Enter your PIN'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkPin,
              child: const Text('Unlock'),
            ),
            const SizedBox(height: 10),
            Text(message),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: useBiometric,
              icon: const Icon(Icons.fingerprint),
              label: const Text('Use Biometric'),
            ),
          ],
        ),
      ),
    );
  }
}