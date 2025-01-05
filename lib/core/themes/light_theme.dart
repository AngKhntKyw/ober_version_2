import 'package:flutter/material.dart';
import 'package:ober_version_2/core/themes/app_pallete.dart';

class LightTheme {
  static border([Color color = AppPallete.black]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide(
          color: color,
          width: 2,
        ),
      );

  static final lightTheme = ThemeData.light(useMaterial3: true).copyWith(
    scaffoldBackgroundColor: AppPallete.white,

    // Color Scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppPallete.white,
      brightness: Brightness.light,
    ),
    // canvasColor: AppPallete.white,
    // primaryColor: AppPallete.black,
    // highlightColor: AppPallete.highLightBlue,
    // shadowColor: AppPallete.onWhiteBackgroundColor,

    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPallete.white,
      surfaceTintColor: AppPallete.white,
      foregroundColor: AppPallete.backgroundColor,
      elevation: 0,
      titleTextStyle: TextStyle(
        fontWeight: FontWeight.bold,
        color: AppPallete.black,
        fontSize: 20,
      ),
    ),

    // ElevatedButton
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(
        enableFeedback: true,
        shape: WidgetStatePropertyAll(ContinuousRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)))),
        minimumSize: WidgetStatePropertyAll(Size(1000, 60)),
        maximumSize: WidgetStatePropertyAll(Size(1000, 60)),
        foregroundColor: WidgetStatePropertyAll(AppPallete.white),
        backgroundColor: WidgetStatePropertyAll(AppPallete.black),
        alignment: Alignment.center,
      ),
    ),

    // TextButtons

    textButtonTheme: const TextButtonThemeData(
        style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(AppPallete.black),
    )),

    // TextFields
    inputDecorationTheme: InputDecorationTheme(
      contentPadding: const EdgeInsets.all(20),
      enabledBorder: border(AppPallete.lightGrey),
      focusedBorder: border(),
      errorBorder: border(AppPallete.red),
      errorStyle: const TextStyle(color: AppPallete.red),
      focusedErrorBorder: border(AppPallete.red),
      border: border(),
    ),

    // Texts
    primaryTextTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppPallete.black),
      headlineMedium: TextStyle(color: AppPallete.black),
      headlineSmall: TextStyle(color: AppPallete.black),
      bodyLarge: TextStyle(color: AppPallete.black),
      bodyMedium: TextStyle(color: AppPallete.black),
      bodySmall: TextStyle(color: AppPallete.black),
      displayLarge: TextStyle(color: AppPallete.black),
      displayMedium: TextStyle(color: AppPallete.black),
      displaySmall: TextStyle(color: AppPallete.black),
      labelLarge: TextStyle(color: AppPallete.black),
      labelMedium: TextStyle(color: AppPallete.black),
      labelSmall: TextStyle(color: AppPallete.black),
      titleLarge: TextStyle(color: AppPallete.black),
      titleMedium: TextStyle(color: AppPallete.black),
      titleSmall: TextStyle(color: AppPallete.black),
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(color: AppPallete.black),
      headlineMedium: TextStyle(color: AppPallete.black),
      headlineSmall: TextStyle(color: AppPallete.black),
      bodyLarge: TextStyle(color: AppPallete.black),
      bodyMedium: TextStyle(color: AppPallete.black),
      bodySmall: TextStyle(color: AppPallete.black),
      displayLarge: TextStyle(color: AppPallete.black),
      displayMedium: TextStyle(color: AppPallete.black),
      displaySmall: TextStyle(color: AppPallete.black),
      labelLarge: TextStyle(color: AppPallete.black),
      labelMedium: TextStyle(color: AppPallete.black),
      labelSmall: TextStyle(color: AppPallete.black),
      titleLarge: TextStyle(color: AppPallete.black),
      titleMedium: TextStyle(color: AppPallete.black),
      titleSmall: TextStyle(color: AppPallete.black),
    ),

    // // Text Selection
    // textSelectionTheme:
    //     const TextSelectionThemeData(cursorColor: AppPallete.lightBlue),

    // // Text Button
    // textButtonTheme: const TextButtonThemeData(
    //   style: ButtonStyle(
    //     alignment: Alignment.center,
    //     foregroundColor: WidgetStatePropertyAll(AppPallete.black),
    //   ),
    // ),

    // // FloatingActionButton
    // floatingActionButtonTheme: const FloatingActionButtonThemeData(
    //   backgroundColor: AppPallete.lightBlue,
    //   foregroundColor: AppPallete.white,
    //   enableFeedback: true,
    // ),

    // // Chip
    // chipTheme: const ChipThemeData(
    //   backgroundColor: AppPallete.transparent,
    //   surfaceTintColor: AppPallete.transparent,
    //   labelStyle: TextStyle(color: AppPallete.lightBlue),
    // ),

    // // Bottom Navigation Bar
    // bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    //   showSelectedLabels: true,
    //   showUnselectedLabels: true,
    //   enableFeedback: true,
    //   elevation: 0,
    //   selectedItemColor: AppPallete.lightBlue,
    //   selectedLabelStyle: TextStyle(color: AppPallete.lightBlue),
    //   unselectedItemColor: AppPallete.lightGrey,
    //   unselectedLabelStyle: TextStyle(color: AppPallete.lightGrey),
    //   landscapeLayout: BottomNavigationBarLandscapeLayout.spread,
    //   backgroundColor: AppPallete.white,
    //   type: BottomNavigationBarType.fixed,
    // ),

    // // Icon Button
    // iconButtonTheme: const IconButtonThemeData(
    //   style: ButtonStyle(
    //     foregroundColor: WidgetStatePropertyAll(AppPallete.black),
    //   ),
    // ),

    // // Card
    // cardTheme: const CardTheme(elevation: 1),

    // // Tab Bar
    // tabBarTheme: const TabBarTheme(
    //   indicatorColor: AppPallete.lightBlue,
    //   unselectedLabelColor: AppPallete.black,
    //   labelColor: AppPallete.lightBlue,
    //   dividerColor: AppPallete.grey,
    //   tabAlignment: TabAlignment.center,
    // ),

    // //ListTile
    // listTileTheme: const ListTileThemeData(
    //   iconColor: AppPallete.lightBlue,
    //   titleTextStyle: TextStyle(color: AppPallete.backgroundColor),
    //   subtitleTextStyle: TextStyle(color: AppPallete.black),
    // ),

    // // Icon
    // iconTheme: const IconThemeData(color: AppPallete.lightBlue),
    // //Switch
    // switchTheme: SwitchThemeData(
    //   trackOutlineColor: const WidgetStatePropertyAll(AppPallete.grey),
    //   thumbColor: WidgetStateProperty.resolveWith(
    //     (states) {
    //       if (states.contains(WidgetState.selected)) {
    //         return AppPallete.lightBlue;
    //       } else {
    //         return AppPallete.white;
    //       }
    //     },
    //   ),
    //   trackColor: WidgetStateProperty.resolveWith(
    //     (states) {
    //       if (states.contains(WidgetState.selected)) {
    //         return AppPallete.blueAccent;
    //       } else {
    //         return AppPallete.grey;
    //       }
    //     },
    //   ),
    // ),

    // // Pop Up Menu Button
    // popupMenuTheme: const PopupMenuThemeData(
    //   surfaceTintColor: AppPallete.white,
    //   iconColor: AppPallete.black,
    //   color: AppPallete.white,
    //   shadowColor: AppPallete.lightBlue,
    //   labelTextStyle: WidgetStatePropertyAll(
    //     TextStyle(color: AppPallete.black),
    //   ),
    // ),

    // // Dialog
    // dialogTheme: const DialogTheme(
    //   backgroundColor: AppPallete.white,
    // )
    //
  );
}
