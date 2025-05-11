import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthService {
  final LocalAuthentication _localAuth = LocalAuthentication();
  final String _biometricEnabledKey = 'biometric_auth_enabled';
  final String _biometricUserIdKey = 'biometric_user_id';

  // Check if device supports biometric authentication
  Future<bool> isBiometricsAvailable() async {
    try {
      // Check if the device is capable of checking biometrics
      final bool canAuthenticateWithBiometrics =
          await _localAuth.canCheckBiometrics;
      final bool canAuthenticate =
          canAuthenticateWithBiometrics || await _localAuth.isDeviceSupported();

      return canAuthenticate;
    } on PlatformException catch (e) {
      debugPrint('Error checking biometrics: $e');
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } on PlatformException catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticate() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to sign in',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Error authenticating: $e');
      return false;
    }
  }

  // Check if biometric authentication is enabled for a user
  Future<bool> isBiometricEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_biometricEnabledKey) ?? false;
    } catch (e) {
      debugPrint('Error checking if biometric is enabled: $e');
      return false;
    }
  }

  // Enable biometric authentication for a user
  Future<bool> enableBiometricAuth(String userId) async {
    try {
      // First authenticate to confirm user identity
      final bool success = await authenticate();

      if (success) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_biometricEnabledKey, true);
        await prefs.setString(_biometricUserIdKey, userId);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error enabling biometric auth: $e');
      return false;
    }
  }

  // Disable biometric authentication
  Future<bool> disableBiometricAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_biometricEnabledKey, false);
      await prefs.remove(_biometricUserIdKey);
      return true;
    } catch (e) {
      debugPrint('Error disabling biometric auth: $e');
      return false;
    }
  }

  // Get user ID associated with biometric
  Future<String?> getBiometricUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_biometricUserIdKey);
    } catch (e) {
      debugPrint('Error getting biometric user ID: $e');
      return null;
    }
  }

  // Authenticate and return user ID if successful
  Future<String?> authenticateAndGetUserId() async {
    try {
      if (await isBiometricEnabled()) {
        final bool success = await authenticate();

        if (success) {
          return await getBiometricUserId();
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error in biometric authentication: $e');
      return null;
    }
  }
}

class BiometricSetupScreen extends StatefulWidget {
  final String userId;

  const BiometricSetupScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  _BiometricSetupScreenState createState() => _BiometricSetupScreenState();
}

class _BiometricSetupScreenState extends State<BiometricSetupScreen> {
  final BiometricAuthService _biometricService = BiometricAuthService();
  bool _isLoading = true;
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  List<BiometricType> _availableBiometrics = [];

  @override
  void initState() {
    super.initState();
    _checkBiometricStatus();
  }

  Future<void> _checkBiometricStatus() async {
    setState(() {
      _isLoading = true;
    });

    final biometricsAvailable = await _biometricService.isBiometricsAvailable();
    final biometricEnabled = await _biometricService.isBiometricEnabled();
    final availableBiometrics =
        await _biometricService.getAvailableBiometrics();

    setState(() {
      _isBiometricAvailable = biometricsAvailable;
      _isBiometricEnabled = biometricEnabled;
      _availableBiometrics = availableBiometrics;
      _isLoading = false;
    });
  }

  Future<void> _toggleBiometricAuth() async {
    setState(() {
      _isLoading = true;
    });

    bool success;
    if (_isBiometricEnabled) {
      success = await _biometricService.disableBiometricAuth();
    } else {
      success = await _biometricService.enableBiometricAuth(widget.userId);
    }

    if (success) {
      setState(() {
        _isBiometricEnabled = !_isBiometricEnabled;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBiometricEnabled
                  ? 'Biometric authentication enabled'
                  : 'Biometric authentication disabled',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBiometricEnabled
                  ? 'Failed to disable biometric authentication'
                  : 'Failed to enable biometric authentication',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biometric Authentication'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Biometric Status',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Availability status
                          Row(
                            children: [
                              Icon(
                                _isBiometricAvailable
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _isBiometricAvailable
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              const Text('Device Support:'),
                              const Spacer(),
                              Text(
                                _isBiometricAvailable
                                    ? 'Available'
                                    : 'Not Available',
                                style: TextStyle(
                                  color: _isBiometricAvailable
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Enabled status
                          Row(
                            children: [
                              Icon(
                                _isBiometricEnabled
                                    ? Icons.check_circle
                                    : Icons.cancel,
                                color: _isBiometricEnabled
                                    ? Colors.green
                                    : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              const Text('Status:'),
                              const Spacer(),
                              Text(
                                _isBiometricEnabled ? 'Enabled' : 'Disabled',
                                style: TextStyle(
                                  color: _isBiometricEnabled
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Available biometrics
                  if (_isBiometricAvailable) ...[
                    const Text(
                      'Available Biometrics',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            _buildBiometricTypeRow(
                              BiometricType.fingerprint,
                              'Fingerprint',
                              Icons.fingerprint,
                            ),
                            if (_availableBiometrics
                                .contains(BiometricType.face))
                              _buildBiometricTypeRow(
                                BiometricType.face,
                                'Face Recognition',
                                Icons.face,
                              ),
                            if (_availableBiometrics
                                    .contains(BiometricType.weak) ||
                                _availableBiometrics
                                    .contains(BiometricType.strong))
                              _buildBiometricTypeRow(
                                BiometricType.strong,
                                'Biometric Authentication',
                                Icons.security,
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Enable/Disable button
                  if (_isBiometricAvailable) ...[
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _toggleBiometricAuth,
                      icon: Icon(
                        _isBiometricEnabled ? Icons.lock_open : Icons.lock,
                      ),
                      label: Text(
                        _isBiometricEnabled
                            ? 'Disable Biometric Authentication'
                            : 'Enable Biometric Authentication',
                      ),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                    ),
                  ] else ...[
                    const Center(
                      child: Text(
                        'Your device does not support biometric authentication.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],

                  // Information text
                  const SizedBox(height: 24),
                  const Card(
                    elevation: 0,
                    color: Color(0xFFECEFFD),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                color: Colors.deepPurple,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'About Biometric Authentication',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Biometric authentication allows you to sign in using your fingerprint or face recognition instead of entering your password. '
                            'Your biometric data never leaves your device and is not stored on our servers.',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBiometricTypeRow(
      BiometricType type, String label, IconData icon) {
    final isAvailable = _availableBiometrics.contains(type);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: isAvailable ? Colors.deepPurple : Colors.grey,
          ),
          const SizedBox(width: 16),
          Text(
            label,
            style: TextStyle(
              fontWeight: isAvailable ? FontWeight.bold : FontWeight.normal,
              color: isAvailable ? Colors.black : Colors.grey,
            ),
          ),
          const Spacer(),
          Icon(
            isAvailable ? Icons.check_circle : Icons.cancel,
            color: isAvailable ? Colors.green : Colors.red,
            size: 20,
          ),
        ],
      ),
    );
  }
}
