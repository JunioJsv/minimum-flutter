import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:minimum/i18n/translations.g.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  runApp(const MinimumApp());
}

class MinimumApp extends StatelessWidget {
  const MinimumApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: translations.appName,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Container(),
    );
  }
}
