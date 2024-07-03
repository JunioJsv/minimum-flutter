import 'package:flutter/material.dart';
import 'package:minimum/features/applications/screens/applications_screen.dart';
import 'package:minimum/features/preferences/screens/preferences_screen.dart';

Route<dynamic>? onGenerateRoute(RouteSettings settings) {
  final route = routes[settings.name];
  if (route == null) return null;

  return switch (route.type) {
    AppRouteType.page => MaterialPageRoute(
        settings: settings,
        builder: route.builder,
      )
  };
}

enum AppRouteType {
  page,
}

class AppRoute {
  final AppRouteType type;
  final WidgetBuilder builder;

  AppRoute({
    this.type = AppRouteType.page,
    required this.builder,
  });
}

final Map<String, AppRoute> routes = {
  ApplicationsScreen.route: AppRoute(
    builder: (context) => const ApplicationsScreen(),
  ),
  PreferencesScreen.route: AppRoute(
    builder: (context) => const PreferencesScreen(),
  )
};
