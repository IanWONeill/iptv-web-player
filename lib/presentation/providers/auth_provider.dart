import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/services/xtream_codes_service.dart';
import '../../data/models/xtream_models.dart';

/// Authentication state
class AuthState {
  final bool isAuthenticated;
  final UserInfo? userInfo;
  final String? error;
  final bool isLoading;

  const AuthState({
    this.isAuthenticated = false,
    this.userInfo,
    this.error,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    UserInfo? userInfo,
    String? error,
    bool? isLoading,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userInfo: userInfo ?? this.userInfo,
      error: error,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Authentication provider
class AuthNotifier extends StateNotifier<AuthState> {
  final XtreamCodesService _xtreamService;

  AuthNotifier(this._xtreamService) : super(const AuthState());

  Future<bool> login({
    required String baseUrl,
    required String username,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      _xtreamService.initialize(
        baseUrl: baseUrl,
        username: username,
        password: password,
      );

      final userInfo = await _xtreamService.getUserInfo();

      if (userInfo.userInfo.auth == '1') {
        state = state.copyWith(
          isAuthenticated: true,
          userInfo: userInfo,
          isLoading: false,
        );
        return true;
      } else {
        state = state.copyWith(
          isAuthenticated: false,
          error: 'Authentication failed',
          isLoading: false,
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isAuthenticated: false,
        error: e.toString(),
        isLoading: false,
      );
      return false;
    }
  }

  void logout() {
    state = const AuthState();
  }
}

/// Provider instances
final xtreamServiceProvider = Provider<XtreamCodesService>((ref) {
  return XtreamCodesService();
});

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final xtreamService = ref.watch(xtreamServiceProvider);
  return AuthNotifier(xtreamService);
});
