import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData darkBW(BuildContext context) {
    final base = Theme.of(context);
    final onBlack = Colors.white;
    final black = const Color(0xFF0B0B0B);
    final surface = const Color(0xFF121212);
    final outline = Colors.white.withOpacity(.18);

    return base.copyWith(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: black,
      colorScheme: base.colorScheme.copyWith(
        brightness: Brightness.dark,
        primary: onBlack,
        onPrimary: Colors.black,
        surface: surface,
        onSurface: onBlack,
        secondary: Colors.grey.shade300,
      ),
      textTheme: base.textTheme.apply(
        bodyColor: onBlack,
        displayColor: onBlack,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      listTileTheme: ListTileThemeData(
        subtitleTextStyle: TextStyle(color: Colors.white),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: black,
        labelStyle: TextStyle(color: onBlack.withOpacity(.7)),
        hintStyle: TextStyle(color: onBlack.withOpacity(.5)),
        prefixIconColor: onBlack.withOpacity(.7),
        suffixIconColor: onBlack.withOpacity(.7),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: outline, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.white,
        contentTextStyle: TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: onBlack.withOpacity(.14),
        thickness: 1,
      ),
      checkboxTheme: CheckboxThemeData(
        side: BorderSide(color: outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),

        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.white
              : Colors.transparent,
        ),
        checkColor: WidgetStateProperty.all(Colors.black),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: black,
        selectedColor: Colors.white,
        color: MaterialStateProperty.all(Colors.grey[300]),
        labelStyle: TextStyle(color: onBlack),
        secondaryLabelStyle: TextStyle(color: onBlack),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: outline),
        ),
      ),
    );
  }

  // (optionnel) si tu veux aussi une version light
  static ThemeData lightFromSeed() => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
  );
}
