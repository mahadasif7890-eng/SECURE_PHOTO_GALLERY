import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

Future<encrypt.Key> getEncryptionKey() async {
  String? existingKey = await storage.read(key: 'encryption_key');
  if (existingKey != null) {
    return encrypt.Key.fromBase64(existingKey);
  } else {
    final newKey = encrypt.Key.fromSecureRandom(32);
    await storage.write(key: 'encryption_key', value: newKey.base64);
    return newKey;
  }
}

Future<void> encryptFile(File inputFile, String outputPath) async {
  final key = await getEncryptionKey();
  final iv = encrypt.IV.fromSecureRandom(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final bytes = await inputFile.readAsBytes();
  final encrypted = encrypter.encryptBytes(bytes, iv: iv);

  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(iv.bytes + encrypted.bytes);
}

Future<List<int>> decryptFile(String encryptedPath) async {
  final key = await getEncryptionKey();
  final file = File(encryptedPath);
  final fileBytes = await file.readAsBytes();

  final iv = encrypt.IV(fileBytes.sublist(0, 16));
  final encryptedBytes = fileBytes.sublist(16);

  final encrypter = encrypt.Encrypter(encrypt.AES(key));
  final decrypted = encrypter.decryptBytes(
    encrypt.Encrypted(encryptedBytes),
    iv: iv,
  );
  return decrypted;
}