import 'package:flutter/material.dart';

/// 国新证券 brand palette, sampled from the reference screenshots.
const Color kBrandRed = Color(0xFFF5310A);
const Color kBrandOrange = Color(0xFFFF7A45);
const Color kUp = Color(0xFFF91D1D);
const Color kDown = Color(0xFF06AA59);
const Color kFlat = Color(0xFF8A9099);
const Color kBg = Color(0xFFF2F4F7);
const Color kText = Color(0xFF222222);
const Color kTextSub = Color(0xFF666666);
const Color kTextFaint = Color(0xFFA9AEB6);
const Color kDivider = Color(0xFFF0F1F3);
const Color kGolden = Color(0xFFB8860B);

/// 底部导航栏顶部 1px 分隔线（取样自参考截图）。
const Color kTabBarBorder = Color(0xFFEBEDF0);

/// 行情数字字体：提取自原 App（只含数字与 + - . , % / ¥ : 等符号）。
/// 只用在纯数字文本上，中文与其它文字仍走系统字体，避免缺字。
const String kNumFont = 'tztNum';

/// 给数字文本套上原 App 的数字字体。
///
/// 例：`Text(two(q.price), style: numStyle(TextStyle(fontSize: 16, color: c)))`
TextStyle numStyle(TextStyle base) => base.copyWith(
  fontFamily: kNumFont,
  // tztNum 只有数字，显式给出中文字体回退，避免缺字变成方块。
  fontFamilyFallback: const <String>[
    'PingFang SC',
    'Heiti SC',
    'Noto Sans CJK SC',
    'sans-serif',
  ],
);

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
