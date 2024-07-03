import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  runApp(
    TranslationProvider(child: const MinimumApp()),
  );
}

class MinimumApp extends StatelessWidget {
  const MinimumApp({super.key});

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    return MaterialApp(
      title: translation.appName,
      locale: TranslationProvider.of(context).flutterLocale,
      supportedLocales: AppLocaleUtils.supportedLocales,
      localizationsDelegates: GlobalMaterialLocalizations.delegates,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          elevation: 1,
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      initialRoute: ApplicationsScreen.route,
      onGenerateRoute: onGenerateRoute,
    );
  }
}
