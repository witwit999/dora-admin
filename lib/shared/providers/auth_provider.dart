import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/models/user_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/service_providers.dart';
import '../../core/utils/app_logger.dart';

// Auth state
class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({this.user, this.isLoading = false, this.error});

  bool get isAuthenticated => user != null;

  AuthState copyWith({User? user, bool? isLoading, String? error}) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(AuthState()) {
    // Check if user is already logged in on initialization
    _checkAuthStatus();
  }

  /// Check if user is already authenticated (has valid tokens)
  Future<void> _checkAuthStatus() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      if (isLoggedIn) {
        final adminId = await _authService.getAdminId();
        if (adminId != null) {
          state = state.copyWith(
            user: User.fromLoginResponse(adminId),
            isLoading: false,
          );
        }
      }
    } catch (e) {
      // If check fails, user is not authenticated
      state = state.copyWith(isLoading: false);
    }
  }

  /// Login with phone and password
  Future<bool> login(String phone, String password) async {
    AppLogger.i('AuthProvider: Starting login process');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Validate input
      if (phone.isEmpty || password.isEmpty) {
        AppLogger.w('AuthProvider: Validation failed - empty fields');
        state = state.copyWith(
          isLoading: false,
          error: 'Phone and password are required',
        );
        return false;
      }

      // Call login API
      AppLogger.i('AuthProvider: Calling auth service login');
      final response = await _authService.login(
        phone: phone,
        password: password,
      );

      // Create user from response
      final user = User.fromLoginResponse(response['adminId'] as int);
      AppLogger.i('AuthProvider: Login successful - User created with adminId: ${user.adminId}');

      state = state.copyWith(
        user: user,
        isLoading: false,
        error: null,
      );

      AppLogger.i('AuthProvider: Auth state updated - isAuthenticated: ${state.isAuthenticated}');
      return true;
    } catch (e) {
      AppLogger.e('AuthProvider: Login failed', e);
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return false;
    }
  }

  /// Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();
      state = AuthState();
    } catch (e) {
      // Clear state even if logout endpoint fails
      state = AuthState();
    }
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.read(authServiceProvider);
  return AuthNotifier(authService);
});
