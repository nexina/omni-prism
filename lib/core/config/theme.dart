import 'package:flutter/material.dart';
import 'constants.dart';

/// Centralized theme and styling for the app
class AppTheme {
  // Colors
  static const Color backgroundColor = Color(AppConstants.backgroundColorARGB);
  static const Color topBarBackground = Color(AppConstants.topBarBackgroundARGB);
  static const Color buttonBackground = Color(AppConstants.buttonBackgroundARGB);
  static const Color overviewBackground = Color(AppConstants.overviewBackgroundARGB);
  static const Color errorBackground = Color(AppConstants.errorBackgroundARGB);
  static const Color errorTextColor = Color(AppConstants.errorTextColorARGB);
  static const Color whiteColor = Colors.white;
  static const Color transparentColor = Colors.transparent;

  // Text styles
  static const TextStyle titleStyle = TextStyle(
    color: whiteColor,
    fontSize: 20,
  );

  static const TextStyle subtitleStyle = TextStyle(
    color: whiteColor,
    fontSize: 10,
  );

  static const TextStyle projectNameStyle = TextStyle(
    color: Color(0x64FFFFFF), // 100/255 opacity white
    fontSize: 7,
    letterSpacing: 1,
  );

  static const TextStyle errorTextStyle = TextStyle(
    color: errorTextColor,
    fontSize: 10,
  );

  static const TextStyle dialogTitleStyle = TextStyle(
    color: whiteColor,
    fontSize: 18,
  );

  static const TextStyle dialogContentStyle = TextStyle(
    color: whiteColor,
    fontSize: 14,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    color: whiteColor,
    fontSize: 14,
  );

  // Decorations
  static const BoxDecoration topBarDecoration = BoxDecoration(
    color: topBarBackground,
  );

  static const BoxDecoration buttonDecoration = BoxDecoration(
    color: buttonBackground,
  );

  static const BoxDecoration overviewItemDecoration = BoxDecoration(
    color: overviewBackground,
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  static const BoxDecoration emptyStateDecoration = BoxDecoration(
    color: Color(0xFF414141),
    borderRadius: BorderRadius.all(Radius.circular(10)),
  );

  // Border radius
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(10));
  static const BorderRadius smallBorderRadius = BorderRadius.all(Radius.circular(4));

  // Icon sizes
  static const double smallIconSize = 20.0;
  static const double mediumIconSize = 24.0;
  static const double largeIconSize = 30.0;
  static const double appIconSize = 50.0;
  static const double aboutIconSize = 200.0;

  // Spacing
  static const double paddingSmall = 4.0;
  static const double paddingMedium = 8.0;
  static const double paddingLarge = 12.0;
  static const double paddingXLarge = 18.0;

  // Elevation
  static const double defaultElevation = 2.0;

  /// Creates the app's dark theme
  static ThemeData get darkTheme => ThemeData(
        brightness: Brightness.dark,
        fontFamily: AppConstants.fontFamily,
        scaffoldBackgroundColor: backgroundColor,
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF50E3C2),
          secondary: Color(0xFF4A90E2),
          surface: Color(0xFF1C1C1C),
          // background is deprecated, use surface instead
          error: Color(0xFFFF5A5F),
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          // onBackground is deprecated, use onSurface instead
          onError: Colors.white,
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white),
          bodySmall: TextStyle(color: Colors.white),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        appBarTheme: const AppBarTheme(
          backgroundColor: topBarBackground,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: buttonBackground,
          elevation: defaultElevation,
          shape: RoundedRectangleBorder(
            borderRadius: defaultBorderRadius,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonBackground,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: defaultBorderRadius,
            ),
            textStyle: buttonTextStyle,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            textStyle: buttonTextStyle,
          ),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: buttonBackground,
          titleTextStyle: dialogTitleStyle,
          contentTextStyle: dialogContentStyle,
          shape: RoundedRectangleBorder(
            borderRadius: defaultBorderRadius,
          ),
        ),
        dividerTheme: const DividerThemeData(
          color: Color(0x40FFFFFF), // 25% opacity white
          thickness: 1,
        ),
      );
}