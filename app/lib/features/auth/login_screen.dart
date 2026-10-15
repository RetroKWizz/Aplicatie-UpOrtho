import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../design_system/colors.dart';
import '../../design_system/typography.dart';
import 'auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final error = auth.hasError ? ref.read(authControllerProvider.notifier).lastErrorMessage : null;

    return Scaffold(
      // Bara cu back exista ca sa se poata INTOARCE in magazin. Fara ea, cine apasa
      // "Intra" din banda ramane blocat: intrarile folosesc `go`, care inlocuieste
      // stiva, iar iOS n-are back de sistem. Prima persoana care ar fi patit-o e
      // recenzorul Apple, care apasa tot ca sa vada ce face.
      appBar: AppBar(
        leading: Navigator.of(context).canPop()
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Inapoi in magazin',
                onPressed: () => context.go('/'),
              ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('UpOrtho', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800, color: context.colors.primary)),
              const SizedBox(height: 6),
              Text('Intra in contul tau de client', style: AppTypography.caption(context)),
              const SizedBox(height: 28),
              TextField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _password,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Parola'),
                onSubmitted: (_) => _submit(),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(error, style: const TextStyle(color: AppColors.danger)),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: auth.isLoading ? null : _submit,
                child: auth.isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Autentificare'),
              ),
              const SizedBox(height: 14),
              // Fara asta, crearea unui cont era accesibila doar din tabul Cont: cine
              // ajungea aici din banda nu afla niciodata ca isi poate face unul.
              TextButton(
                onPressed: () => context.go('/signup'),
                child: const Text('Nu am cont — creeaza unul'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (_email.text.trim().isEmpty || _password.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Introdu email si parola.')));
      return;
    }
    ref.read(authControllerProvider.notifier).login(_email.text, _password.text);
  }
}
