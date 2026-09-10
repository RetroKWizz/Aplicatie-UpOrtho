import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Pagina de plata a magazinului, deschisa in aplicatie.
///
/// De ce un WebView si nu un ecran nativ: in Odoo 18 formularul de card (Stripe) e
/// **inline** - JavaScript care ruleaza in pagina, nu o redirectionare catre o adresa
/// externa. Nu exista un URL de plata care sa poata fi deschis altfel, iar datele
/// cardului nu au voie sa treaca prin aplicatie. Pagina incarcata aici e chiar
/// formularul real al magazinului, deci raman valabile toate regulile lor.
///
/// De ce nu browserul telefonului: sesiunea Odoo traieste in cookie-ul aplicatiei.
/// Un browser extern ar deschide magazinul nelogat, cu cosul gol.
///
/// Ecranul se inchide singur cand navigarea ajunge la `returnUrlPrefix` (pagina de
/// confirmare a magazinului) si intoarce `true`; inchis de utilizator, intoarce
/// `false` - comanda ramane atunci in asteptare, iar ecranul precedent o reciteste.
class PaymentWebViewScreen extends StatefulWidget {
  const PaymentWebViewScreen({
    super.key,
    required this.baseUrl,
    required this.path,
    required this.returnUrlPrefix,
    required this.sessionId,
  });

  /// Originea Odoo (aceeasi cu a API-ului).
  final String baseUrl;

  /// Calea paginii de plata, asa cum a intors-o serverul (ex. `/shop/payment`).
  final String path;

  /// Cand URL-ul curent incepe cu `baseUrl + returnUrlPrefix`, plata s-a incheiat.
  final String returnUrlPrefix;

  /// Cookie-ul de sesiune al aplicatiei, pus in WebView inainte de prima incarcare.
  /// WebView-ul are propriul magazin de cookie-uri: fara acest pas, pagina s-ar
  /// incarca nelogata.
  final String? sessionId;

  @override
  State<PaymentWebViewScreen> createState() => _PaymentWebViewScreenState();
}

class _PaymentWebViewScreenState extends State<PaymentWebViewScreen> {
  late final WebViewController _controller;
  bool _loading = true;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) {
          if (_isReturnUrl(url)) _finish();
        },
        onPageFinished: (url) {
          if (mounted) setState(() => _loading = false);
          if (_isReturnUrl(url)) _finish();
        },
      ));
    _start();
  }

  String get _returnUrl => '${widget.baseUrl}${widget.returnUrlPrefix}';

  bool _isReturnUrl(String url) => url.startsWith(_returnUrl);

  void _finish() {
    if (_finished || !mounted) return;
    _finished = true;
    Navigator.of(context).pop(true);
  }

  Future<void> _start() async {
    final sessionId = widget.sessionId;
    if (sessionId != null) {
      final host = Uri.parse(widget.baseUrl).host;
      await WebViewCookieManager().setCookie(
        WebViewCookie(name: 'session_id', value: sessionId, domain: host, path: '/'),
      );
    }
    await _controller.loadRequest(Uri.parse('${widget.baseUrl}${widget.path}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plata'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          tooltip: 'Renunta la plata',
          onPressed: () => Navigator.of(context).pop(false),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_loading) const LinearProgressIndicator(),
        ],
      ),
    );
  }
}
