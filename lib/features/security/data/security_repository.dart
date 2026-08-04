import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
class SecurityRepository {
  SecurityRepository() : _storage = const FlutterSecureStorage(), _localAuth = LocalAuthentication();
  final FlutterSecureStorage _storage;
  final LocalAuthentication _localAuth;
  static const _pinKey = 'notes_app_pin';
  Future<bool> hasPin() async {
    final value = await _storage.read(key: _pinKey);
    return value != null && value.isNotEmpty;
  }
  Future<void> setPin(String pin) => _storage.write(key: _pinKey, value: pin);
  Future<bool> verifyPin(String pin) async {
    final stored = await _storage.read(key: _pinKey);
    return stored != null && stored == pin;
  }
  Future<void> clearPin() => _storage.delete(key: _pinKey);
  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      return supported && canCheck;
    } catch (_) {
      return false;
    }
  }
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Autenticate para ver esta nota',
        options: const AuthenticationOptions(biometricOnly: true, stickyAuth: true),
      );
    } catch (_) {
      return false;
    }
  }
}
