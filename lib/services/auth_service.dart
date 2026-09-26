import 'package:local_auth/local_auth.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final LocalAuthentication auth = LocalAuthentication();
final storage = FlutterSecureStorage();

// ---------- PIN Functions ----------

String hashPin(String pin) {
  var bytes = utf8.encode(pin);
  var digest = sha256.convert(bytes);
  return digest.toString();
}

Future<void> setPin(String pin) async {
  String hashedPin = hashPin(pin);
  await storage.write(key: 'user_pin', value: hashedPin);
}

Future<bool> verifyPin(String enteredPin) async {
  String? savedHash = await storage.read(key: 'user_pin');
  String enteredHash = hashPin(enteredPin);
  return savedHash == enteredHash;
}

// Naya function: PIN change karna (purana PIN verify karke naya set karna)
Future<bool> changePin(String oldPin, String newPin) async {
  bool isOldCorrect = await verifyPin(oldPin);
  if (isOldCorrect) {
    await setPin(newPin);
    return true;
  }
  return false;
}

// ---------- Biometric Function ----------

Future<bool> authenticateWithBiometrics() async {
  try {
    bool canCheck = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (!canCheck || !isDeviceSupported) {
      return false;
    }

    bool