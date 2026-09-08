import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config.dart';

void main() {
  // Un release fara --dart-define=API_BASE_URL=https://... ar porni linistit spre
  // localhost, in clar. Preferam sa cada la lansare, cu mesaj, decat sa ajunga asa
  // in magazin. Vezi AppConfig.assertReleaseApiBaseUrl.
  AppConfig.assertReleaseApiBaseUrl();
  runApp(const ProviderScope(child: UpOrthoApp()));
}
