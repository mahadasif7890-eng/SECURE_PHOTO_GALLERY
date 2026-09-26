import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLifecycleService with WidgetsBindingObserver {
  DateTime? pausedTime;
  int lockTimeoutSeconds = 60; // default 1 minute

  Function? onLockTriggered;
  final storage = FlutterSecureStorage();

  void init(Function lockCallback) {
    onLockTriggered = lockCallback;
    WidgetsBinding.instance.addObserver(this);
    _loadTimeoutSetting();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
  }

  // User settings se timeout load karna (agar user ne change kiya ho)
  Future<void> _loadTimeoutSetting() async {
    String? saved = await storage.read(key: 'lock_timeout_seconds');
    if (saved != null) {
      lockTimeoutSeconds = int.tryParse(saved) ?? 60;
    }
  }

  // Settings screen se timeout change karne ke liye (Student 1 use karega)
  Future<void> updateTimeout(int seconds) async {
    lockTimeoutSeconds = seconds;
    await storage.write(key: 'lock_timeout_seconds', value: seconds.toString());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      pausedTime = DateTime.now();
    } else if (state == AppLifecycleState.resumed) {
      if (pausedTime != null) {
        final diff = DateTime.now().difference(pausedTime!).inSeconds;
        if (diff >= lockTimeoutSeconds) {
          onLockTriggered?.call();
        }
      }
    }
  }
}