import 'package:local_auth/local_auth.dart';

final LocalAuthentication auth = LocalAuthentication();

Future<bool> authenticateWithBiometrics() async {
  try {
    bool canCheck = await auth.canCheckBiometrics;
    bool isDeviceSupported = await auth.isDeviceSupported();

    if (!canCheck || !isDeviceSupported) {
      return false;
    }

    bool authenticated = await auth.authenticate(
      localizedReason: 'Unlock your vault',
      options: const AuthenticationOptions(
        biometricOnly: true,
        stickyAuth: true,
      ),
    );

    return authenticated;
  } catch (e) {
    print('Biometric error: $e');
    return false;
  }
}