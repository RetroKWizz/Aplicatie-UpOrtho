import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Cum arata aplicatia. `system` inseamna "urmeaza telefonul": se face intunecat cand
/// si telefonul e intunecat.
enum AppThemeChoice {
  system('system', 'Urmeaza telefonul'),
  light('light', 'Luminos'),
  dark('dark', 'Intunecat');

  const AppThemeChoice(this.value, this.label);

  final String value;
  final String label;

  static AppThemeChoice fromValue(String? raw) =>
      AppThemeChoice.values.where((c) => c.value == raw).firstOrNull ?? AppThemeChoice.system;

  ThemeMode get themeMode => switch (this) {
        AppThemeChoice.system => ThemeMode.system,
        AppThemeChoice.light => ThemeMode.light,
        AppThemeChoice.dark => ThemeMode.dark,
      };
}

/// Unde se tine alegerea. Pe telefon, nu in cont: doi oameni care intra pe acelasi
/// cont de cabinet pot avea fiecare ce aspect vor.
abstract class ThemeStore {
  Future<String?> read();
  Future<void> write(String value);
}

class SecureThemeStore implements ThemeStore {
  SecureThemeStore([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();
  static const _key = 'app_theme_choice';
  final FlutterSecureStorage _storage;

  @override
  Future<String?> read() => _storage.read(key: _key);
  @override
  Future<void> write(String value) => _storage.write(key: _key, value: value);
}

class InMemoryThemeStore implements ThemeStore {
  String? _value;
  @override
  Future<String?> read() async => _value;
  @override
  Future<void> write(String value) async => _value = value;
}

final themeStoreProvider = Provider<ThemeStore>((ref) => SecureThemeStore());

/// Alegerea curenta. Porneste pe `system` si se inlocuieste cu ce e salvat pe telefon
/// imediat ce citirea se termina - citirea e rapida, iar o tema gresita aratata o
/// clipa e mai putin rau decat un ecran gol la pornire.
class ThemeController extends Notifier<AppThemeChoice> {
  @override
  AppThemeChoice build() {
    // Depozitul se ia INAINTE de asteptare, iar dupa ea se verifica `ref.mounted`:
    // altfel, pe un container inchis intre timp (o pornire scurta, un test),
    // citirea s-ar intoarce intr-un provider care nu mai exista si ar arunca.
    final store = ref.read(themeStoreProvider);
    Future<void>(() async {
      final saved = AppThemeChoice.fromValue(await store.read());
      if (!ref.mounted) return;
      if (saved != state) state = saved;
    });
    return AppThemeChoice.system;
  }

  Future<void> choose(AppThemeChoice choice) async {
    state = choice;
    await ref.read(themeStoreProvider).write(choice.value);
  }
}

final themeControllerProvider =
    NotifierProvider<ThemeController, AppThemeChoice>(ThemeController.new);
