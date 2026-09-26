import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'pin_lock_screen.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController pinController = TextEditingController();
  String message = '';

  void savePin() async {
    if (pinController.text.length == 4) {
      await setPin(pinController.text);
      setState(() {
        message = 'PIN set successfully!';
      });

      // 1 second wait karo, phir Lock Screen pe navigate karo
      await Future.delayed(const Duration(seconds: 1));
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PinLockScreen()),
      );
    } else {
      setState(() {
        message = 'PIN must be 4 digits';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set your PIN')),
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
              decoration: const InputDecoration(labelText: 'Enter 4-digit PIN'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: savePin,
              child: const Text('Save PIN'),
            ),
            const SizedBox(height: 10),
            Text(message),
          ],
        ),
      ),
    );
  }
}