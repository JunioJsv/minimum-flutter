import 'package:flutter/material.dart';

const useMaterial3 = true;
const appBarTheme = AppBarTheme(elevation: 1);

SliderThemeData sliderTheme(ColorScheme colorScheme) {
  return SliderThemeData(
    overlayShape: SliderComponentShape.noOverlay,
    inactiveTrackColor: colorScheme.primary.withOpacity(.2),
  );
}

SearchBarThemeData searchBarTheme(ColorScheme colorScheme) {
  return const SearchBarThemeData(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}

CardTheme cardTheme(ColorScheme colorScheme) {
  return const CardTheme();
}

ThemeData theme(ColorScheme colorScheme) {
  return ThemeData(
    appBarTheme: appBarTheme,
    sliderTheme: sliderTheme(colorScheme),
    searchBarTheme: searchBarTheme(colorScheme),
    cardTheme: cardTheme(colorScheme),
    colorScheme: colorScheme,
    useMaterial3: useMaterial3,
  );
}
