import 'package:flutter/material.dart';
import 'package:minimum/features/applications/screens/applications_group_screen.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/applications/screens/create_applications_group_screen.dart';
import 'package:minimum/features/icon_packs/screens/icon_pack_selector_screen.dart';
import 'package:minimum/features/icon_packs/screens/icon_pack_drawable_selector_screen.dart';
import 'package:minimum/features/preferences/screens/preferences_screen.dart';

extension RouteExtension on Route<dynamic> {
  T arguments<T>() => settings.arguments as T;
}

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final builder = routes[settings.name];
  if (builder == null) return null;

  return MaterialPageRoute(
    settings: settings,
    builder: builder,
  );
}

final Map<String, WidgetBuilder> routes = {
  ApplicationsScreen.route: (context) => const ApplicationsScreen(),
  PreferencesScreen.route: (context) => const PreferencesScreen(),
  CreateApplicationsGroupScreen.route: (context) =>
      const CreateApplicationsGroupScreen(),
  ApplicationsGroupScreen.route: (context) => const ApplicationsGroupScreen(),
  IconPackSelectorScreen.route: (context) => const IconPackSelectorScreen(),
  IconPackDrawableSelectorScreen.route: (context) =>
      const IconPackDrawableSelectorScreen(),
};
