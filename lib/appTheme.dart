import 'package:flutter/material.dart';

class AppTheme {
  static bool isLightTheme = true;
  static Color primaryColors = HexColor("#00AEEF");
  static Color introColor = HexColor("#f7f9fc");

  static TextTheme _buildTextTheme(TextTheme base) {
    var fontName = "Gilroy";
    return base.copyWith(
      headline6: base.headline6.copyWith(fontFamily: fontName),
      headline5: base.headline6.copyWith(fontFamily: fontName),
      headline4: base.headline6.copyWith(fontFamily: fontName),
      headline3: base.headline6.copyWith(fontFamily: fontName),
      headline2: base.headline6.copyWith(fontFamily: fontName),
      headline1: base.headline6.copyWith(fontFamily: fontName),
      bodyText2: base.headline6.copyWith(fontFamily: fontName),
      bodyText1: base.headline6.copyWith(fontFamily: fontName),
      subtitle2: base.headline6.copyWith(fontFamily: fontName),
      subtitle1: base.headline6.copyWith(fontFamily: fontName),
      button: base.headline6.copyWith(fontFamily: fontName),
      caption: base.headline6.copyWith(fontFamily: fontName),
      overline: base.headline6.copyWith(fontFamily: fontName),
    );
  }

  static ThemeData getTheme() {
    if (isLightTheme) {
      return newLightTheme();
    } else {
      return newDarkTheme();
    }
  }

  static ThemeData newLightTheme() {
    Color primaryColor = primaryColors;
    Color secondaryColor = primaryColors;
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );
    final ThemeData base = ThemeData.light();
    return base.copyWith(
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      buttonColor: primaryColor,
      indicatorColor: Colors.white,
      splashColor: Colors.white24,
      splashFactory: InkRipple.splashFactory,
      accentColor: secondaryColor,
      canvasColor: Colors.white,
      backgroundColor: const Color(0xFFF7F9FC),
      scaffoldBackgroundColor: const Color(0xFFF7F9FC),
      errorColor: const Color(0xFFB00020),
      buttonTheme: ButtonThemeData(
        colorScheme: colorScheme,
        textTheme: ButtonTextTheme.primary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: Colors.white,
        filled: true,
        contentPadding: const EdgeInsets.all(15.0),
        border: new OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(15.0),
          ),
        ),
        enabledBorder: const OutlineInputBorder(
          // width: 0.0 produces a thin "hairline" border
          borderRadius: const BorderRadius.all(
            const Radius.circular(15.0),
          ),
          borderSide: const BorderSide(color: Colors.transparent, width: 0.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: const BorderRadius.all(
            const Radius.circular(15.0),
          ),
          borderSide: BorderSide(color: HexColor("#0e3178"), width: 1.0),
        ),
        hintStyle: TextStyle(
          fontWeight: FontWeight.w500,
          fontFamily: "Gilroy",
          color: Color(0xFFC7C9D1),
        ),
      ),
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildTextTheme(base.accentTextTheme),
      platform: TargetPlatform.iOS,
    );
  }

  static ThemeData newDarkTheme() {
    Color primaryColor = primaryColors;
    Color secondaryColor = primaryColors;
    final ColorScheme colorScheme = const ColorScheme.light().copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
    );
    final ThemeData base = ThemeData.dark();
    return base.copyWith(
      colorScheme: colorScheme,
      primaryColor: primaryColor,
      buttonColor: primaryColor,
      indicatorColor: Colors.white,
      splashColor: Colors.white24,
      splashFactory: InkRipple.splashFactory,
      accentColor: secondaryColor,
      canvasColor: Colors.white,
      backgroundColor: Colors.black,
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      buttonTheme: ButtonThemeData(
        colorScheme: colorScheme,
        textTheme: ButtonTextTheme.primary,
      ),
      textTheme: _buildTextTheme(base.textTheme),
      primaryTextTheme: _buildTextTheme(base.primaryTextTheme),
      accentTextTheme: _buildTextTheme(base.accentTextTheme),
      platform: TargetPlatform.iOS,
    );
  }
}

class HexColor extends Color {
  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF" + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }

  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));
}
