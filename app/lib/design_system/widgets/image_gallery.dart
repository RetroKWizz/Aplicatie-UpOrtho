import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../colors.dart';

/// Un element de galerie, in forma de care are nevoie widgetul: un URL absolut de
/// imagine si, optional, un URL de video. Deliberat NU e modelul API `ProductImage`
/// — design system-ul nu importa modele de wire (vezi datoria tehnica 1 din
/// docs/DE-FACUT.md, care cerea explicit ca widgeturile noi din Faza 2 sa nu mai
/// creasca peste acel cuplaj). Maparea model -> element sta in ecran.
@immutable
class GalleryItem {
  const GalleryItem({this.imageUrl, this.videoUrl});

  /// URL absolut al pozei; `null` = intrare fara poza (un video fara miniatura
  /// atasata, cazul in care serverul trimite `url: null`).
  final String? imageUrl;

  /// `null` = poza obisnuita; altfel elementul e video si se deschide in exterior.
  final String? videoUrl;

  bool get isVideo => videoUrl != null;

  @override
  bool operator ==(Object other) =>
      other is GalleryItem && other.imageUrl == imageUrl && other.videoUrl == videoUrl;

  @override
  int get hashCode => Object.hash(imageUrl, videoUrl);
}

/// Galeria de poze a produsului: derulare orizontala, cu indicator de pagini cand
/// sunt mai multe. Elementele de tip video arata miniatura cu buton de redare si
/// se deschid in aplicatia externa (YouTube/browser) — nu exista player in
/// aplicatie si nu se adauga niciun pachet video pentru asta.
///
/// Galerie goala = niciun pixel desenat: pe ecranul de produs fiecare sectiune
/// fara date dispare complet.
class ImageGallery extends StatefulWidget {
  const ImageGallery({
    super.key,
    required this.items,
    this.httpHeaders,
    this.onOpenVideo,
  });

  final List<GalleryItem> items;

  /// Headere pentru cererile de imagine (cookie de sesiune Odoo): rutele
  /// `/products/<id>/gallery/<image_id>` sunt autentificate, ca si celelalte rute
  /// de imagine. Cine construieste headerele decide daca URL-ul e pe originea
  /// proprie (`imageHeadersFor`) — widgetul doar le transmite mai departe.
  final Map<String, String>? httpHeaders;

  /// Ce se intampla la apasarea pe un element video. Implicit: deschidere externa
  /// cu `url_launcher`. Testele injecteaza propriul callback ca sa nu atinga
  /// platforma.
  final void Function(String videoUrl)? onOpenVideo;

  @override
  State<ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<ImageGallery> {
  final _controller = PageController();
  int _current = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _open(String videoUrl) {
    final onOpenVideo = widget.onOpenVideo;
    if (onOpenVideo != null) {
      onOpenVideo(videoUrl);
      return;
    }
    // Aceleasi doua capcane ca la link-urile de banner (vezi
    // features/home/banner_link.dart): `Uri.tryParse('')` intoarce un Uri valid,
    // iar o schema arbitrara ar deschide orice aplicatie care o pretinde. Deschidem
    // doar http/https cu host, si niciodata nu lasam o exceptie de platforma sa
    // scape dintr-un handler de tap pe care nu-l asteapta nimeni.
    final uri = Uri.tryParse(videoUrl.trim());
    if (uri == null || (!uri.isScheme('http') && !uri.isScheme('https')) || uri.host.isEmpty) {
      return;
    }
    unawaited(() async {
      try {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (error) {
        debugPrint('Nu s-a putut deschide videoul produsului: $error');
      }
    }());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    // AspectRatio, nu inaltime fixa: isi ia inaltimea din latimea disponibila si,
    // cand parintele are inaltime marginita mai mica, se micsoreaza singur in loc
    // sa dea overflow.
    return AspectRatio(
      aspectRatio: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ColoredBox(
          color: AppColors.background,
          child: Stack(
            children: [
              PageView.builder(
                controller: _controller,
                itemCount: widget.items.length,
                onPageChanged: (index) => setState(() => _current = index),
                itemBuilder: (context, index) => _GalleryPage(
                  item: widget.items[index],
                  httpHeaders: widget.httpHeaders,
                  onPlay: _open,
                ),
              ),
              if (widget.items.length > 1)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 10,
                  child: Center(
                    child: GalleryPageIndicator(count: widget.items.length, current: _current),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GalleryPage extends StatelessWidget {
  const _GalleryPage({required this.item, required this.httpHeaders, required this.onPlay});

  final GalleryItem item;
  final Map<String, String>? httpHeaders;
  final void Function(String videoUrl) onPlay;

  @override
  Widget build(BuildContext context) {
    final image = item.imageUrl == null
        ? const Center(
            child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary, size: 40))
        : CachedNetworkImage(
            imageUrl: item.imageUrl!,
            httpHeaders: httpHeaders,
            fit: BoxFit.contain,
            errorWidget: (_, _, _) => const Center(
                child: Icon(Icons.image_not_supported_outlined, color: AppColors.textSecondary, size: 40)),
          );

    if (!item.isVideo) return image;

    return Stack(
      fit: StackFit.expand,
      children: [
        image,
        Center(
          child: Material(
            color: Colors.black45,
            shape: const CircleBorder(),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => onPlay(item.videoUrl!),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Bulinele de sub galerie. Widget public doar ca testele sa poata verifica pagina
/// curenta fara sa se agate de pixeli.
class GalleryPageIndicator extends StatelessWidget {
  const GalleryPageIndicator({super.key, required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var index = 0; index < count; index++)
            Padding(
              padding: EdgeInsets.only(right: index == count - 1 ? 0 : 6),
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == current ? AppColors.primary : AppColors.primaryLight,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
