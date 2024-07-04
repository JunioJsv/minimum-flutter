import 'package:flutter/material.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/preferences/screens/preferences_screen.dart';

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
};
