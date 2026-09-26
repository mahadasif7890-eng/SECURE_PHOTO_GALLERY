import 'package:encrypt/encrypt.dart' as encrypt;
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Encryption key generate ya fetch karna
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

// Image file ko encrypt karke vault folder mein save karna
// Student 3 isko call karega jab image import ho
Future<String> encryptAndSaveImage(File inputFile, String fileName) async {
  final key = await getEncryptionKey();
  final iv = encrypt.IV.fromSecureRandom(16);
  final encrypter = encrypt.Encrypter(encrypt.AES(key));

  final bytes = await inputFile.readAsBytes();
  final encrypted = encrypter.encryptBytes(bytes, iv: iv);

  // Vault ki apni private folder banao
  final appDir = await getApplicationDocumentsDirectory();
  final vaultDir = Directory('${appDir.path}/vault_images');
  if (!await vaultDir.exists()) {
    await vaultDir.create(recursive: true);
  }

  final outputPath = '${vaultDir.path}/$fileName.enc';
  final outputFile = File(outputPath);
  await outputFile.writeAsBytes(iv.bytes + encrypted.bytes);

  return outputPath; // Student 3 ye path database mein save karega
}

// Encrypted image ko decrypt karke bytes return karna (dikhane ke liye)
// Student 1 isko call karega gallery mein image dikhane ke liye
Future<List<int>> decryptImage(String encryptedPath) async {
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

// Vault se image delete karna
Future<void> deleteEncryptedImage(String encryptedPath) async {
  final file = File(encryptedPath);
  if (await file.exists()) {
    await file.delete();
  }
}