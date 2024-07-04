import 'package:flutter/material.dart';

const useMaterial3 = true;
const appBarTheme = AppBarTheme(elevation: 1);

ThemeData theme(ColorScheme? colorsScheme) {
  return ThemeData(
    appBarTheme: appBarTheme,
    colorScheme: colorsScheme,
    useMaterial3: useMaterial3,
  );
}
