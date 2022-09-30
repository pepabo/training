import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _key = "AccessToken";

  static Future<void> saveAccessToken(String accessToken) async {
    const storage = FlutterSecureStorage();
    await storage.write(key: _key, value: accessToken);
  }

  static Future<String?> getAccessToken() async {
    const storage = FlutterSecureStorage();
    final accessToken = await storage.read(key: _key);

    return accessToken;
  }
}