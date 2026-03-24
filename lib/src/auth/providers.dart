import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/app_config.dart';
import '../ui/error_text.dart';
import 'auth_api.dart';
import 'auth_repository.dart';
import 'auth_session.dart';
import 'host_storage.dart';
import 'token_storage.dart';

final appConfigProvider = Provider<AppConfig>(
  (ref) => AppConfig.fromDartDefines(),
);

final sharedPreferencesProvider = FutureProvider<SharedPreferences>(
  (ref) => SharedPreferences.getInstance(),
);

final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (ref) => const FlutterSecureStorage(),
);

final authRepositoryProvider = FutureProvider<AuthRepository>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final config = ref.watch(appConfigProvider);
  final client = ref.watch(httpClientProvider);
  final secureStorage = ref.watch(secureStorageProvider);

  final api = AuthApi(
    client: client,
    clientId: config.oauthClientId,
    clientSecret: config.oauthClientSecret,
  );

  return AuthRepository(
    api: api,
    tokenStorage: TokenStorage(secureStorage),
    hostStorage: HostStorage(prefs),
  );
});

final authMessageProvider =
    NotifierProvider<AuthMessageNotifier, String?>(AuthMessageNotifier.new);
final sessionNoticeProvider =
    NotifierProvider<SessionNoticeNotifier, String?>(SessionNoticeNotifier.new);

class AuthMessageNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? message) => state = message;
  void clear() => state = null;
}

class SessionNoticeNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void set(String? message) => state = message;
  void clear() => state = null;
}

final authSessionProvider =
    AsyncNotifierProvider<AuthSessionController, AuthSession?>(
      AuthSessionController.new,
    );

class AuthSessionController extends AsyncNotifier<AuthSession?> {
  @override
  Future<AuthSession?> build() async {
    final repo = await ref.watch(authRepositoryProvider.future);
    ref.read(sessionNoticeProvider.notifier).clear();
    return repo.readCachedSession();
  }

  Future<AuthSession> sessionForNetwork() async {
    final current = state.value;
    if (current == null) {
      ref
          .read(sessionNoticeProvider.notifier)
          .set('Session expired. Continue offline or logout to login again.');
      throw const SessionExpiredException();
    }
    if (!current.isExpired) return current;

    final refreshToken = current.refreshToken;
    if (refreshToken == null || refreshToken.trim().isEmpty) {
      ref
          .read(sessionNoticeProvider.notifier)
          .set('Session expired. Continue offline or logout to login again.');
      throw const SessionExpiredException();
    }

    final repo = await ref.read(authRepositoryProvider.future);
    try {
      final refreshed = await repo.refreshIfExpired(current);
      state = AsyncData(refreshed);
      return refreshed;
    } on AuthRefreshInvalidException {
      ref
          .read(sessionNoticeProvider.notifier)
          .set('Session expired. Continue offline or logout to login again.');
      throw const SessionExpiredException();
    } catch (_) {
      ref
          .read(sessionNoticeProvider.notifier)
          .set('No connection. Working offline.');
      throw const NoConnectionException();
    }
  }

  Future<void> login({
    required String hostUrl,
    required String username,
    required String password,
  }) async {
    final repo = await ref.read(authRepositoryProvider.future);
    ref.read(authMessageProvider.notifier).clear();
    ref.read(sessionNoticeProvider.notifier).clear();
    state = const AsyncLoading();
    try {
      final session = await repo.login(
        hostUrl: hostUrl,
        username: username,
        password: password,
      );
      state = AsyncData(session);
    } catch (e) {
      ref.read(authMessageProvider.notifier).set(_mapAuthError(e));
      state = const AsyncData(null);
    }
  }

  Future<void> logout() async {
    final repo = await ref.read(authRepositoryProvider.future);
    await repo.logout();
    ref.read(sessionNoticeProvider.notifier).clear();
    state = const AsyncData(null);
  }

  Future<List<String>> getHostHistory() async {
    final repo = await ref.read(authRepositoryProvider.future);
    return repo.getHostHistory();
  }

  Future<String?> getLastHost() async {
    final repo = await ref.read(authRepositoryProvider.future);
    return repo.getLastHost();
  }
}

String _mapAuthError(Object error) {
  if (error is AuthApiException) {
    if (error.statusCode == 400 || error.statusCode == 401) {
      return 'Invalid credentials';
    }
    return 'Login failed (${error.statusCode})';
  }
  if (error is FormatException) return error.message;
  return 'Network error, try again';
}
