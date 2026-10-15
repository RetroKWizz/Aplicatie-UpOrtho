import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../api/models/instagram_feed.dart';
import '../colors.dart';
import '../typography.dart';

/// Feedul de Instagram de la finalul paginii Acasa, acelasi pe care il are si pagina
/// de start a site-ului.
///
/// Pozele nu trec prin Odoo si nu le avem noi: blocul de pe site e un iframe catre
/// `instagram.com/<cont>/embed`, iar aici e aceeasi pagina intr-un WebView. De aceea
/// feedul **nu e un rand de poze apasabile**: tot ce e inauntru apartine paginii
/// Instagram. Apasarea pe antetul de deasupra deschide profilul in aplicatia
/// Instagram de pe telefon.
///
/// Inaltimea e fixa, nu masurata din pagina: iframe-ul isi anunta inaltimea doar
/// printr-un mesaj de JavaScript catre fereastra-parinte, pe care un WebView nu il
/// primeste. 340 e cat antetul paginii Instagram plus doua randuri de poze la latimea
/// unui telefon - masurat pe simulator; mai mult lasa o banda alba dedesubt.
class InstagramFeedCard extends StatefulWidget {
  const InstagramFeedCard({
    super.key,
    required this.feed,
    required this.onOpenProfile,
    this.height = 340,
  });

  final InstagramFeed feed;

  /// Deschiderea profilului. Vine de la ecran, ca testele sa nu atinga browserul.
  final VoidCallback onOpenProfile;

  final double height;

  @override
  State<InstagramFeedCard> createState() => _InstagramFeedCardState();
}

class _InstagramFeedCardState extends State<InstagramFeedCard> {
  WebViewController? _controller;

  @override
  void initState() {
    super.initState();
    // Controllerul se creeaza doar acolo unde exista o platforma de WebView. In
    // teste widget nu exista niciuna, iar constructorul ar arunca si ar pica orice
    // test care deseneaza Acasa - cardul isi arata atunci doar antetul.
    try {
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..loadRequest(Uri.parse(widget.feed.embedUrl));
    } catch (error) {
      debugPrint('WebView indisponibil pentru feedul Instagram: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: widget.onOpenProfile,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  Expanded(
                    child: Text('De pe Instagram',
                        style: AppTypography.sectionTitle(context)),
                  ),
                  Text('@${widget.feed.username}',
                      style: AppTypography.caption(context)
                          .copyWith(color: context.colors.primary)),
                  const SizedBox(width: 4),
                  Icon(Icons.open_in_new, size: 16, color: context.colors.primary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: SizedBox(
              height: widget.height,
              child: _controller == null
                  // Fara WebView (test, platforma fara suport) ramane o suprafata
                  // goala, nu o eroare: feedul e in plus, nu e magazinul.
                  ? ColoredBox(color: context.colors.surface)
                  : WebViewWidget(controller: _controller!),
            ),
          ),
        ],
      ),
    );
  }
}
