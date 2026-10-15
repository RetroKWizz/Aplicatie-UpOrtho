import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../api/api_exception.dart';
import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import '../checkout/payment_webview_screen.dart';
import '../../providers.dart';
import 'auth_controller.dart';

/// Crearea unui cont, cu exact campurile formularului de pe uportho.ro.
///
/// Nicio regula de validare nu e scrisa aici: serverul cheama metodele de inregistrare
/// ale magazinului, deci parola refuzata, emailul deja folosit si inregistrarea oprita
/// vin cu mesajele lor. Ecranul doar le arata si, la doua coduri anume, schimba drumul:
/// `email_taken` propune autentificarea, `signup_needs_webview` deschide pagina
/// magazinului (unde reCAPTCHA lor functioneaza - nu o ocolim).
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(authControllerProvider.notifier).signUp(
          name: _name.text,
          login: _email.text,
          password: _password.text,
          confirmPassword: _confirm.text,
        );
    if (!mounted) return;
    final error = ref.read(authControllerProvider).error;
    if (error is ApiException && error.code == 'signup_needs_webview') {
      final api = ref.read(apiClientProvider);
      final session = await ref.read(sessionStoreProvider).read();
      if (!mounted) return;
      await Navigator.of(context).push(MaterialPageRoute<bool>(
        builder: (_) => PaymentWebViewScreen(
          baseUrl: api.baseUrl,
          path: '/web/signup',
          returnUrlPrefix: '/my',
          sessionId: session,
        ),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final busy = auth.isLoading;
    final error = auth.error;
    final message = ref.read(authControllerProvider.notifier).lastErrorMessage;
    final emailTaken = error is ApiException && error.code == 'email_taken';

    return Scaffold(
      appBar: AppBar(title: const Text('Creeaza cont')),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + MediaQuery.paddingOf(context).bottom),
        children: [
          Text(
            'Contul e acelasi cu cel de pe uportho.ro. Dupa ce il creezi, vezi preturile '
            'si poti comanda.',
            style: AppTypography.body(context).copyWith(color: context.colors.textSecondary),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(labelText: 'Nume'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autocorrect: false,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _password,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Parola'),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _confirm,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Confirma parola'),
          ),
          if (message != null && error != null) ...[
            const SizedBox(height: 14),
            Text(message, style: AppTypography.caption(context).copyWith(color: AppColors.danger)),
          ],
          if (emailTaken) ...[
            const SizedBox(height: 10),
            // Comoditatea paginii lor: cand contul exista, drumul e autentificarea, nu
            // o a doua incercare de inregistrare cu acelasi email.
            OutlinedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Am deja cont — intra'),
            ),
          ],
          const SizedBox(height: 22),
          FilledButton(
            onPressed: busy ? null : _submit,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(50)),
            child: busy
                ? const SizedBox(
                    width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Creeaza contul'),
          ),
          const SizedBox(height: 14),
          TextButton(
            onPressed: () => context.go('/login'),
            child: const Text('Am deja cont'),
          ),
        ],
      ),
    );
  }
}
