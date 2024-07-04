import 'package:client/core/theme/app_color.dart';
import 'package:flutter/material.dart';

class AppTheme {
  const AppTheme._();
  static OutlineInputBorder _border(
          {Color borderColor = AppColor.borderColor}) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(
          color: borderColor,
          width: 3,
        ),
      );

  static final darkThemeMode = ThemeData.dark().copyWith(
      scaffoldBackgroundColor: AppColor.backgroundColor,
      inputDecorationTheme: InputDecorationTheme(
        contentPadding: const EdgeInsets.all(27),
        enabledBorder: _border(),
        focusedBorder: _border(
          borderColor: AppColor.gradient2,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColor.backgroundColor,
      ));
}
