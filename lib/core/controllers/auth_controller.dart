import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../services/auth_service.dart';

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

final authControllerProvider = StateNotifierProvider<AuthController, bool>((
  ref,
) {
  final authService = ref.watch(authServiceProvider);
  return AuthController(authService);
});

class AuthController extends StateNotifier<bool> {
  final AuthService _authService;

  AuthController(this._authService) : super(false);

  Future<String?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    state = true;

    final errorMsg = await _authService.loginWithEmail(
      email: email,
      password: password,
    );

    state = false;
    return errorMsg;
  }

  Future<String?> loginWithGoogle() async {
    state = true;

    final errorMsg = await _authService.loginWithGoogle();

    state = false;
    return errorMsg;
  }

  Future<String?> resetPassword(String email) async {
    return await _authService.resetPassword(email: email);
  }

  Future<String?> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    state = true;

    final errorMsg = await _authService.registerWithEmail(
      name: name,
      email: email,
      password: password,
    );

    state = false;
    return errorMsg;
  }

  Future<void> logout() async {
    state = true;
    await _authService.logout();
    state = false;
  }
}
