import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uportho_app/design_system/widgets/image_gallery.dart';

void main() {
  Widget sized(Widget child, {double width = 360, double height = 400}) =>
      MaterialApp(home: Scaffold(body: Center(child: SizedBox(width: width, height: height, child: child))));

  testWidgets('galerie goala nu deseneaza nimic (sectiunea dispare complet)', (tester) async {
    await tester.pumpWidget(sized(const ImageGallery(items: [])));
    expect(find.byType(PageView), findsNothing);
    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('o singura poza: fara indicator de pagini', (tester) async {
    await tester.pumpWidget(sized(const ImageGallery(
      items: [GalleryItem(imageUrl: 'https://example.test/api/app/v1/products/101/gallery/0?unique=a')],
    )));
    expect(find.byType(CachedNetworkImage), findsOneWidget);
    expect(find.byType(GalleryPageIndicator), findsNothing);
  });

  testWidgets('mai multe poze: indicator de pagini si derulare orizontala', (tester) async {
    await tester.pumpWidget(sized(const ImageGallery(items: [
      GalleryItem(imageUrl: 'https://example.test/i/1'),
      GalleryItem(imageUrl: 'https://example.test/i/2'),
      GalleryItem(imageUrl: 'https://example.test/i/3'),
    ])));

    expect(find.byType(PageView), findsOneWidget);
    final indicator = tester.widget<GalleryPageIndicator>(find.byType(GalleryPageIndicator));
    expect(indicator.count, 3);
    expect(indicator.current, 0);

    await tester.drag(find.byType(PageView), const Offset(-400, 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.widget<GalleryPageIndicator>(find.byType(GalleryPageIndicator)).current, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('httpHeaders ajung pe fiecare imagine (rutele de galerie sunt autentificate)',
      (tester) async {
    const headers = {'Cookie': 'session_id=abc'};
    await tester.pumpWidget(sized(const ImageGallery(
      items: [GalleryItem(imageUrl: 'https://example.test/i/1')],
      httpHeaders: headers,
    )));
    expect(tester.widget<CachedNetworkImage>(find.byType(CachedNetworkImage)).httpHeaders, headers);
  });

  testWidgets('elementul video arata buton de redare si deschide video_url in exterior',
      (tester) async {
    String? opened;
    await tester.pumpWidget(sized(ImageGallery(
      items: const [
        GalleryItem(
          imageUrl: 'https://example.test/i/1',
          videoUrl: 'https://www.youtube.com/watch?v=xxxx',
        ),
      ],
      onOpenVideo: (url) => opened = url,
    )));

    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    expect(opened, 'https://www.youtube.com/watch?v=xxxx');
  });

  testWidgets('un element de tip video fara poza ramane deschizabil', (tester) async {
    String? opened;
    await tester.pumpWidget(sized(ImageGallery(
      items: const [GalleryItem(videoUrl: 'https://www.youtube.com/watch?v=yyyy')],
      onOpenVideo: (url) => opened = url,
    )));

    expect(find.byType(CachedNetworkImage), findsNothing);
    expect(find.byIcon(Icons.play_arrow_rounded), findsOneWidget);
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    expect(opened, 'https://www.youtube.com/watch?v=yyyy');
    expect(tester.takeException(), isNull);
  });

  testWidgets('o poza obisnuita nu declanseaza deschiderea de video', (tester) async {
    var opened = 0;
    await tester.pumpWidget(sized(ImageGallery(
      items: const [GalleryItem(imageUrl: 'https://example.test/i/1')],
      onOpenVideo: (_) => opened++,
    )));
    await tester.tap(find.byType(ImageGallery));
    expect(opened, 0);
    expect(find.byIcon(Icons.play_arrow_rounded), findsNothing);
  });

  testWidgets('fara callback, un tap pe video nu scapa nicio exceptie in arbore', (tester) async {
    await tester.pumpWidget(sized(const ImageGallery(
      items: [GalleryItem(videoUrl: 'https://www.youtube.com/watch?v=zzzz')],
    )));
    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('intr-o coloana ingusta de ecran, cu titlu romanesc lung dedesubt, nu da overflow',
      (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 150,
          child: ListView(
            children: const [
              ImageGallery(items: [
                GalleryItem(imageUrl: 'https://example.test/i/1'),
                GalleryItem(videoUrl: 'https://www.youtube.com/watch?v=xxxx'),
              ]),
              Text('Set bracketi metalici Atlas Mini .022 pentru tratament ortodontic complet'),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(GalleryPageIndicator), findsOneWidget);
  });

  testWidgets('intr-un spatiu mai jos decat lat, galeria se micsoreaza singura (fara overflow)',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 150,
            height: 90,
            child: ImageGallery(items: [
              GalleryItem(imageUrl: 'https://example.test/i/1'),
              GalleryItem(imageUrl: 'https://example.test/i/2'),
            ]),
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(tester.getSize(find.byType(ImageGallery)).height, lessThanOrEqualTo(90));
    expect(tester.takeException(), isNull);
  });
}
