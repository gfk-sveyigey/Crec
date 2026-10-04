import 'package:flutter/material.dart';

/// 国新证券 brand palette, sampled from the reference screenshots.
const Color kBrandRed = Color(0xFFE93323);
const Color kBrandOrange = Color(0xFFFF7A45);
const Color kUp = Color(0xFFF5222D);
const Color kDown = Color(0xFF00A06A);
const Color kFlat = Color(0xFF8A9099);
const Color kBg = Color(0xFFF4F5F7);
const Color kText = Color(0xFF1D2129);
const Color kTextSub = Color(0xFF86909C);
const Color kTextFaint = Color(0xFFA9AEB6);
const Color kDivider = Color(0xFFF0F1F3);
const Color kGolden = Color(0xFFB8860B);

/// A-share convention: red for up, green for down.
Color changeColor(num? v) {
  if (v == null) return kFlat;
  if (v > 0) return kUp;
  if (v < 0) return kDown;
  return kFlat;
}

ThemeData buildAppTheme() {
  final ThemeData base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: kBg,
    primaryColor: kBrandRed,
    splashFactory: NoSplash.splashFactory,
    colorScheme: base.colorScheme.copyWith(
      primary: kBrandRed,
      secondary: kBrandOrange,
      surface: Colors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      foregroundColor: kText,
      titleTextStyle: TextStyle(
        color: kText,
        fontSize: 21,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: kDivider,
      thickness: 1,
      space: 1,
    ),
    textTheme: base.textTheme.apply(bodyColor: kText, displayColor: kText),
  );
}
