import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/colors.dart';
import 'package:uportho_app/design_system/theme.dart';
import 'package:uportho_app/features/settings/appearance_screen.dart';
import 'package:uportho_app/features/settings/theme_controller.dart';

void main() {
  ProviderContainer container({ThemeStore? store}) {
    final c = ProviderContainer(overrides: [
      themeStoreProvider.overrideWithValue(store ?? InMemoryThemeStore()),
    ]);
    addTearDown(c.dispose);
    return c;
  }

  Future<void> pump(WidgetTester tester, ProviderContainer c) async {
    await tester.pumpWidget(UncontrolledProviderScope(
      container: c,
      child: const MaterialApp(home: AppearanceScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 20));
  }

  group('alegerea temei', () {
    test('porneste pe "urmeaza telefonul"', () {
      expect(container().read(themeControllerProvider), AppThemeChoice.system);
    });

    test('o valoare necunoscuta din memorie nu arunca', () {
      // O cheie ramasa de la o versiune mai veche nu trebuie sa impiedice pornirea.
      expect(AppThemeChoice.fromValue('turcoaz'), AppThemeChoice.system);
      expect(AppThemeChoice.fromValue(null), AppThemeChoice.system);
    });

    test('alegerea se tine minte pe telefon', () async {
      final store = InMemoryThemeStore();
      final first = container(store: store);
      await first.read(themeControllerProvider.notifier).choose(AppThemeChoice.dark);

      // O pornire noua a aplicatiei citeste ce s-a salvat.
      final second = container(store: store);
      second.read(themeControllerProvider);
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(second.read(themeControllerProvider), AppThemeChoice.dark);
    });

    test('fiecare alegere are modul ei', () {
      expect(AppThemeChoice.system.themeMode, ThemeMode.system);
      expect(AppThemeChoice.light.themeMode, ThemeMode.light);
      expect(AppThemeChoice.dark.themeMode, ThemeMode.dark);
    });
  });

  group('tema intunecata', () {
    test('violetul se deschide pe intuneric, ca sa se citeasca', () {
      // Violetul de brand pe un fundal aproape negru nu trece pragul de contrast.
      expect(AppPalette.dark.primary, isNot(AppPalette.light.primary));
      expect(AppPalette.dark.background.computeLuminance(),
          lessThan(AppPalette.light.background.computeLuminance()));
      expect(AppPalette.dark.textPrimary.computeLuminance(),
          greaterThan(AppPalette.dark.surface.computeLuminance()));
    });

    test('culorile cu inteles raman aceleasi in ambele teme', () {
      // Rosu inseamna eroare si pe luminos, si pe intunecat.
      AppColors.use(AppPalette.light);
      final lightDanger = AppColors.danger;
      AppColors.use(AppPalette.dark);
      expect(AppColors.danger, lightDanger);
      AppColors.use(AppPalette.light);
    });

    test('tema de Flutter urmeaza paleta, nu o a doua lista de culori', () {
      final dark = buildDarkTheme();
      expect(dark.scaffoldBackgroundColor, AppPalette.dark.background);
      expect(dark.brightness, Brightness.dark);
    });
  });

  testWidgets('ecranul arata cele trei optiuni si o bifeaza pe cea aleasa',
      (tester) async {
    final c = container();
    await pump(tester, c);

    expect(find.text('Urmeaza telefonul'), findsOneWidget);
    expect(find.text('Luminos'), findsOneWidget);
    expect(find.text('Intunecat'), findsOneWidget);
    expect(find.byIcon(Icons.radio_button_checked), findsOneWidget);
  });

  testWidgets('apasarea pe o optiune o alege pe loc', (tester) async {
    final c = container();
    await pump(tester, c);

    await tester.tap(find.text('Intunecat'));
    await tester.pump();

    expect(c.read(themeControllerProvider), AppThemeChoice.dark);
  });
}
