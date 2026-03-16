import 'package:flutter/foundation.dart';
import '../../auth/models/login_response_model.dart';
import '../../auth/services/auth_api.dart';
import '../../auth/services/token_storage.dart';

class SplashViewModel extends ChangeNotifier {
  final AuthApi authApi;
  final TokenStorage tokenStorage;

  SplashViewModel({required this.authApi, required this.tokenStorage});

  UserModel? user;
  bool isLoading = false;
  String? errorMessage;
  bool shouldGoHome = false;
  bool shouldGoLogin = false;
  bool shouldGoNickname = false;

  Future<void> initialize() async {
    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();

      final accessToken = await tokenStorage.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        shouldGoLogin = true;
        return;
      }

      final me = await authApi.getMe(accessToken);
      user = me;
      if (me.profileCompleted) {
        shouldGoHome = true;
      } else {
        shouldGoNickname = true;
      }
    } catch (e) {
      await tokenStorage.clearTokens();
      shouldGoLogin = true;
      errorMessage = e.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
