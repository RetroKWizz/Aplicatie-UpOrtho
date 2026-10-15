import 'package:flutter/material.dart';

import '../colors.dart';
import '../typography.dart';

/// Banda care spune, o singura data pe ecran, de ce nu se vad preturile.
///
/// Magazinul isi arata catalogul oricui, dar tine preturile pentru clienti. Un om care
/// deschide aplicatia fara cont trebuie sa afle asta o data, limpede — nu pe fiecare
/// card (ar obosi) si nici abia cand apasa "Adauga in cos" (ar parea ca aplicatia e
/// stricata cat timp cauta pretul).
///
/// Se deseneaza dupa blocul `pricing` primit de la server, nu dupa starea locala de
/// autentificare: o sesiune expirata arata inca "autentificat" in aplicatie cat timp
/// nu cere nimic, iar banda ar lipsi exact cand e nevoie de ea.
class SignInBanner extends StatelessWidget {
  const SignInBanner({super.key, required this.onSignIn});

  final VoidCallback onSignIn;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        color: context.colors.primaryLight.withValues(alpha: 0.25),
        border: Border(
          top: BorderSide(color: context.colors.primaryLight.withValues(alpha: 0.6)),
          bottom: BorderSide(color: context.colors.primaryLight.withValues(alpha: 0.6)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.lock_outline, size: 20, color: context.colors.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Intra in cont ca sa vezi preturile si sa comanzi.',
              style: AppTypography.caption(context)
                  .copyWith(color: context.colors.textPrimary, height: 1.35),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: onSignIn,
            style: FilledButton.styleFrom(
              backgroundColor: context.colors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              minimumSize: const Size(0, 44),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Intra'),
          ),
        ],
      ),
    );
  }
}
