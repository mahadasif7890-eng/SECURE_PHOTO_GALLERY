import 'package:flutter/material.dart';

class AppLifecycleService with WidgetsBindingObserver {
  DateTime? pausedTime;
  final int lockTimeoutSeconds = 30; // testing ke liye 30 second

  Function? onLockTriggered;

  void init(Function lockCallback) {
    onLockTriggered = lockCallback;
    WidgetsBinding.instance.addObserver(this);
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
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