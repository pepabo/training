import 'package:flutter_riverpod/flutter_riverpod.dart';

final accessTokenProvider = StateNotifierProvider<AccessTokenNotifier, String?>((ref) {
  return AccessTokenNotifier();
});

class AccessTokenNotifier extends StateNotifier<String?>{
  AccessTokenNotifier() : super(null);

  Future<void> setToken(String accessToken) async {
    state = accessToken;
  }
}