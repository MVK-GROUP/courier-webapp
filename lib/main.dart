import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:url_strategy/url_strategy.dart';

import 'app.dart';
import 'utilities/locales.dart';

Future<void> main() async {
  setPathUrlStrategy();
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  runApp(EasyLocalization(
    supportedLocales: SupportedLocales.locales,
    path: 'assets/translations',
    fallbackLocale: SupportedLocales.defaultLocale.locale,
    child: const App(),
  ));
}
