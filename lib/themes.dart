import 'package:flutter/material.dart';

const useMaterial3 = true;
const appBarTheme = AppBarTheme(elevation: 1);

SliderThemeData sliderTheme(ColorScheme colorsScheme) {
  return SliderThemeData(
    overlayShape: SliderComponentShape.noOverlay,
    inactiveTrackColor: colorsScheme.primary.withOpacity(.2),
  );
}

SearchBarThemeData searchBarTheme(ColorScheme colorsScheme) {
  return const SearchBarThemeData(
    padding: WidgetStatePropertyAll(
      EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
  );
}

ThemeData theme(ColorScheme colorsScheme) {
  return ThemeData(
    appBarTheme: appBarTheme,
    sliderTheme: sliderTheme(colorsScheme),
    searchBarTheme: searchBarTheme(colorsScheme),
    colorScheme: colorsScheme,
    useMaterial3: useMaterial3,
  );
}
