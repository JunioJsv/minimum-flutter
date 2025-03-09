import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:minimum/environment.dart';
import 'package:minimum/features/applications/blocs/applications_manager/applications_manager_cubit.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/applications/utils/applications_actions.dart';
import 'package:minimum/features/applications/utils/applications_groups_actions.dart';
import 'package:minimum/features/preferences/blocs/preferences_manager/preferences_manager_cubit.dart';
import 'package:minimum/i18n/translations.g.dart';
import 'package:minimum/routes.dart';
import 'package:minimum/services/applications_manager_service.dart';
import 'package:minimum/services/local_authentication_service.dart';
import 'package:minimum/themes.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

final dependencies = GetIt.instance;
final observer = RouteObserver<ModalRoute>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  LocaleSettings.useDeviceLocale();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(
      (await getApplicationDocumentsDirectory()).path,
    ),
  );
  SentryFlutter.init(
    (options) {
      options.dsn = kSentryDSN;
    },
    appRunner: () {
      runApp(
        SentryWidget(child: TranslationProvider(child: const MinimumApp())),
      );
    },
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
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    dependencies.registerSingleton(ApplicationsManagerService());
    dependencies.registerSingleton(LocalAuthenticationService());
    dependencies.registerSingleton(
      ApplicationsActions(),
      dispose: (actions) => actions.dispose(),
    );
    dependencies.registerSingleton(
      ApplicationsGroupsActions(),
      dispose: (actions) => actions.dispose(),
    );
    dependencies.registerSingleton(
      PreferencesManagerCubit(dependencies()),
      dispose: (cubit) async => cubit.close(),
    );
    dependencies.registerLazySingleton(
      () => ApplicationsManagerCubit(
        dependencies(),
        dependencies(),
        dependencies(),
        dependencies(),
      )..getInstalledApplications(),
      dispose: (cubit) => cubit.close(),
    );
    WidgetsBinding.instance.addObserver(
      dependencies<ApplicationsManagerService>(),
    );
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      dependencies<ApplicationsManagerService>(),
    );
    dependencies.unregister<PreferencesManagerCubit>();
    dependencies.unregister<ApplicationsManagerCubit>();
    dependencies.unregister<ApplicationsManagerService>();
    dependencies.unregister<LocalAuthenticationService>();
    dependencies.unregister<ApplicationsActions>();
    dependencies.unregister<ApplicationsGroupsActions>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final translation = context.translations;
    return DynamicColorBuilder(
      builder: (ColorScheme? lightDynamic, ColorScheme? darkDynamic) {
        return MaterialApp(
          title: translation.appName,
          locale: TranslationProvider.of(context).flutterLocale,
          supportedLocales: AppLocaleUtils.supportedLocales,
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          theme: theme(lightDynamic ?? const ColorScheme.light()),
          darkTheme: theme(darkDynamic ?? const ColorScheme.dark()),
          themeMode: ThemeMode.system,
          initialRoute: ApplicationsScreen.route,
          navigatorObservers: [observer, SentryNavigatorObserver()],
          onGenerateRoute: onGenerateRoute,
        );
      },
    );
  }
}
