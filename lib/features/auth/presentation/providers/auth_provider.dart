import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/storage/preferences.dart';

class AuthState {
  final bool isAuthenticated;
  final String? username;
  final bool isAdmin;

  const AuthState({
    required this.isAuthenticated,
    this.username,
    this.isAdmin = false,
  });

  AuthState copyWith({bool? isAuthenticated, String? username, bool? isAdmin}) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      username: username ?? this.username,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._prefs) : super(const AuthState(isAuthenticated: false)) {
    _init();
  }

  final SharedPreferences _prefs;

  static const _keyIsLoggedIn = 'auth_is_logged_in';
  static const _keyUsername = 'auth_username';
  static const _keyIsAdmin = 'auth_is_admin';

  void _init() {
    final isLoggedIn = _prefs.getBool(_keyIsLoggedIn) ?? false;
    final username = _prefs.getString(_keyUsername);
    final isAdmin = _prefs.getBool(_keyIsAdmin) ?? false;

    if (isLoggedIn && username != null) {
      state = AuthState(
        isAuthenticated: true,
        username: username,
        isAdmin: isAdmin,
      );
    }
  }

  Future<bool> login(String usernameOrEmail, String password) async {
    final trimmedUser = usernameOrEmail.trim();
    final trimmedPass = password.trim();

    if (trimmedUser.isEmpty || trimmedPass.isEmpty) {
      return false;
    }

    // Admin Credentials
    if (trimmedUser == 'Bhagirath-admin' && trimmedPass == 'Nitatsu@123') {
      await _saveAuth(username: trimmedUser, isAdmin: true);
      return true;
    }

    // User Login validation
    if (trimmedPass.length >= 6) {
      await _saveAuth(username: trimmedUser, isAdmin: false);
      return true;
    }

    return false;
  }

  Future<void> logout() async {
    await _prefs.remove(_keyIsLoggedIn);
    await _prefs.remove(_keyUsername);
    await _prefs.remove(_keyIsAdmin);
    state = const AuthState(isAuthenticated: false);
  }

  Future<void> _saveAuth({
    required String username,
    required bool isAdmin,
  }) async {
    await _prefs.setBool(_keyIsLoggedIn, true);
    await _prefs.setString(_keyUsername, username);
    await _prefs.setBool(_keyIsAdmin, isAdmin);
    state = AuthState(
      isAuthenticated: true,
      username: username,
      isAdmin: isAdmin,
    );
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthNotifier(prefs);
});
