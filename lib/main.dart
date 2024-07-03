import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/routes.dart';
import 'package:path_provider/path_provider.dart';

final dependencies = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: await getApplicationDocumentsDirectory(),
  );
  runApp(
    TranslationProvider(child: const MinimumApp()),
  );
}

class MinimumApp extends StatefulWidget {
  const MinimumApp({super.key});

  @override
  State<MinimumApp> createState() => _MinimumAppState();
}

class _MinimumAppState extends State<MinimumApp> {
  @override
  void initState() {
    dependencies.registerSingleton(PreferencesManagerCubit());
    super.initState();
  }

  @override
  void dispose() {
    dependencies.unregister<PreferencesManagerCubit>(
      disposingFunction: (cubit) async => cubit.close(),
    );
    super.dispose();
  }

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
