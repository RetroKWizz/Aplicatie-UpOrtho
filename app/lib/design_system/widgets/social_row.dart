import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../api/models/social_link.dart';
import '../colors.dart';
import '../typography.dart';

/// Randul de retele sociale de la finalul paginii Acasa — acelasi bloc pe care
/// site-ul il are sub produse ("Hai alaturi de noi si in Social Media").
///
/// Adresele vin din setarile website-ului, prin `/home`; widgetul nu stie nicio
/// adresa si nu decide ce retele exista. Ce decide el e iconita si numele citit de
/// cititoarele de ecran, dupa numele retelei.
class SocialRow extends StatelessWidget {
  const SocialRow({super.key, required this.links, required this.onOpen});

  final List<SocialLink> links;

  /// Deschiderea adresei. Vine de la ecran (si trece prin aceeasi paza de URL ca
  /// link-ul extern al unui banner), ca testele sa nu atinga browserul real.
  final void Function(SocialLink link) onOpen;

  @override
  Widget build(BuildContext context) {
    if (links.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        children: [
          Text('Urmareste-ne', style: AppTypography.sectionTitle(context)),
          const SizedBox(height: 12),
          // `Wrap` si nu un rand: sase retele cu cercuri de 48 nu incap pe un ecran
          // ingust, iar o derulare laterala ascunsa ar lasa ultimele iconite
          // nevazute tocmai la capatul paginii, unde nimeni nu mai trage.
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 12,
            runSpacing: 12,
            children: [
              for (final link in links)
                _SocialButton(link: link, onTap: () => onOpen(link)),
            ],
          ),
        ],
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.link, required this.onTap});

  final SocialLink link;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final network = socialNetworkLook(link.network);
    return Semantics(
      button: true,
      label: network.label,
      child: Tooltip(
        message: network.label,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.colors.surface,
              border: Border.all(color: context.colors.primaryLight),
            ),
            child: Center(
              child: FaIcon(network.icon, size: 20, color: context.colors.primary),
            ),
          ),
        ),
      ),
    );
  }
}

/// Cum arata o retea in aplicatie: iconita si numele ei scris pentru om.
@immutable
class SocialNetworkLook {
  const SocialNetworkLook(this.icon, this.label);

  final FaIconData icon;
  final String label;
}

/// Iconita si numele unei retele, dupa cheia primita de la server.
///
/// O retea necunoscuta (una adaugata de Odoo intr-o versiune viitoare, sau un camp
/// pe care nu l-am prevazut) primeste o iconita de link si numele ei brut, cu
/// majuscula — tot se deschide. Daca aici s-ar intoarce null, o adresa completata in
/// Odoo ar disparea din aplicatie fara ca nimeni sa afle.
SocialNetworkLook socialNetworkLook(String network) => switch (network) {
      'facebook' => const SocialNetworkLook(FontAwesomeIcons.facebookF, 'Facebook'),
      'instagram' => const SocialNetworkLook(FontAwesomeIcons.instagram, 'Instagram'),
      'youtube' => const SocialNetworkLook(FontAwesomeIcons.youtube, 'YouTube'),
      'linkedin' => const SocialNetworkLook(FontAwesomeIcons.linkedinIn, 'LinkedIn'),
      'tiktok' => const SocialNetworkLook(FontAwesomeIcons.tiktok, 'TikTok'),
      'twitter' => const SocialNetworkLook(FontAwesomeIcons.xTwitter, 'X'),
      'github' => const SocialNetworkLook(FontAwesomeIcons.github, 'GitHub'),
      _ => SocialNetworkLook(FontAwesomeIcons.link, _capitalize(network)),
    };

String _capitalize(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return 'Link';
  return trimmed[0].toUpperCase() + trimmed.substring(1);
}
