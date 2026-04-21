// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// ─────────────────────────────────────────────────────────────────────────────
//  RICE MART — APP THEME
// ─────────────────────────────────────────────────────────────────────────────

class AppColors {
  AppColors._();

  // ── Core Palette ────────────────────────────────────────────
  static const Color darkGreen = Color(0xFF1A2820);
  static const Color lightGreen = Color(0xFF5A8A6E);
  static const Color golden = Color(0xFF9D7E3F);
  static const Color cream = Color(0xFFD4C9A8);
  static const Color borderGold = Color(0xFFB8A97A);

  // ── Semantic ─────────────────────────────────────────────────
  static const Color success = Color(0xFF2E7D32);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFF57C00);
  static const Color info = Color(0xFF1565C0);

  // ── Translucent helpers (use .withOpacity on the base colors
  //    where needed, but these constants cover the most common values)
  static Color cardFill = cream.withOpacity(0.22);
  static Color cardBorder = borderGold.withOpacity(0.45);
  static Color inputFill = cream.withOpacity(0.30);
  static Color inputBorder = borderGold.withOpacity(0.55);
  static Color overlayLight = cream.withOpacity(0.30);
  static Color labelSecondary = darkGreen.withOpacity(0.65);
  static Color hintText = darkGreen.withOpacity(0.60);
  static Color iconMuted = darkGreen.withOpacity(0.75);
  static Color divider = darkGreen.withOpacity(0.15);
}

// ─────────────────────────────────────────────────────────────────────────────
//  GRADIENTS
// ─────────────────────────────────────────────────────────────────────────────

class AppGradients {
  AppGradients._();

  /// Used on Splash, Login, Register, ForgotPassword, Dashboard background, etc.
  static const LinearGradient background = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.lightGreen, AppColors.golden],
  );

  /// Subtle overlay for cards / containers that need a tinted gradient.
  static LinearGradient cardOverlay = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      AppColors.cream.withOpacity(0.25),
      AppColors.borderGold.withOpacity(0.15),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  TEXT STYLES
// ─────────────────────────────────────────────────────────────────────────────

class AppTextStyles {
  AppTextStyles._();

  // ── Headings ─────────────────────────────────────────────────
  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGreen,
    letterSpacing: 0.3,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGreen,
    letterSpacing: 0.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGreen,
    letterSpacing: 0.3,
  );

  static const TextStyle heading4 = TextStyle(
    fontSize: 14.5,
    fontWeight: FontWeight.bold,
    color: AppColors.darkGreen,
  );

  // ── Body ─────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 14,
    color: AppColors.darkGreen,
    height: 1.5,
  );

  static TextStyle bodyMedium = TextStyle(
    fontSize: 13.5,
    color: AppColors.darkGreen.withOpacity(0.85),
    height: 1.5,
  );

  static TextStyle bodySmall = TextStyle(
    fontSize: 12,
    color: AppColors.darkGreen.withOpacity(0.65),
    height: 1.4,
  );

  // ── Labels ───────────────────────────────────────────────────
  static const TextStyle label = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGreen,
    letterSpacing: 0.2,
  );

  static TextStyle labelMuted = TextStyle(
    fontSize: 13,
    color: AppColors.darkGreen.withOpacity(0.75),
  );

  static TextStyle hint = TextStyle(
    fontSize: 14,
    color: AppColors.darkGreen.withOpacity(0.60),
  );

  // ── Button ───────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    color: AppColors.darkGreen,
    letterSpacing: 0.3,
  );

  // ── Section titles (Admin / Notification Settings) ────────────
  static TextStyle sectionTitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: AppColors.darkGreen.withOpacity(0.80),
    letterSpacing: 0.3,
  );

  // ── Splash ───────────────────────────────────────────────────
  static const TextStyle splashTitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 56,
    fontWeight: FontWeight.w300,
    color: AppColors.darkGreen,
    letterSpacing: 2,
  );

  static const TextStyle splashSubtitle = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 18,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGreen,
    letterSpacing: 0.5,
  );

  static const TextStyle splashLoading = TextStyle(
    fontFamily: 'Poppins',
    fontSize: 24,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGreen,
    letterSpacing: 1,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  DECORATION HELPERS
// ─────────────────────────────────────────────────────────────────────────────

class AppDecorations {
  AppDecorations._();

  /// Standard card — used by Admin, NotificationSettings, etc.
  static BoxDecoration card = BoxDecoration(
    color: AppColors.cardFill,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(color: AppColors.cardBorder),
    boxShadow: [
      BoxShadow(
        color: AppColors.darkGreen.withOpacity(0.07),
        blurRadius: 10,
        offset: const Offset(0, 3),
      ),
    ],
  );

  /// Input field container — Login, Register, ForgotPassword, ChangePassword.
  static BoxDecoration inputField = BoxDecoration(
    color: AppColors.inputFill,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.inputBorder),
  );

  /// Pill / chip container (language toggle, filter chips).
  static BoxDecoration pill = BoxDecoration(
    color: AppColors.overlayLight,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: AppColors.borderGold.withOpacity(0.50)),
  );

  /// Back-button / icon-button container.
  static BoxDecoration iconButton = BoxDecoration(
    color: AppColors.cream.withOpacity(0.25),
    borderRadius: BorderRadius.circular(10),
    border: Border.all(color: AppColors.borderGold.withOpacity(0.50)),
  );

  /// Full-screen gradient background (wrap the entire Scaffold body).
  static const BoxDecoration gradientBackground = BoxDecoration(
    gradient: AppGradients.background,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  BUTTON STYLE
// ─────────────────────────────────────────────────────────────────────────────

class AppButtonStyles {
  AppButtonStyles._();

  /// Primary elevated button used across all auth screens.
  static ButtonStyle primary = ElevatedButton.styleFrom(
    backgroundColor: AppColors.cream.withOpacity(0.35),
    foregroundColor: AppColors.darkGreen,
    elevation: 0,
    minimumSize: const Size(double.infinity, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
      side: BorderSide(color: AppColors.borderGold.withOpacity(0.70)),
    ),
  );

  /// Text / ghost button (e.g., "Forgot Password?", "Back to Sign In").
  static ButtonStyle ghost = TextButton.styleFrom(
    padding: EdgeInsets.zero,
    minimumSize: Size.zero,
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    foregroundColor: AppColors.darkGreen,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
//  MATERIAL THEME DATA
// ─────────────────────────────────────────────────────────────────────────────

ThemeData get appTheme {
  return ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',

    // ── Color scheme ──────────────────────────────────────────
    colorScheme: ColorScheme.light(
      primary: AppColors.darkGreen,
      secondary: AppColors.golden,
      surface: AppColors.cream,
      onPrimary: AppColors.cream,
      onSecondary: AppColors.darkGreen,
      onSurface: AppColors.darkGreen,
      error: AppColors.error,
    ),

    scaffoldBackgroundColor: AppColors.lightGreen,

    // ── AppBar ────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: AppColors.darkGreen),
      titleTextStyle: AppTextStyles.heading3,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    ),

    // ── Input decoration ──────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      border: InputBorder.none,
      hintStyle: AppTextStyles.hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    ),

    // ── Elevated button ───────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: AppButtonStyles.primary,
    ),

    // ── Text button ───────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(style: AppButtonStyles.ghost),

    // ── Checkbox ──────────────────────────────────────────────
    checkboxTheme: CheckboxThemeData(
      checkColor: WidgetStateProperty.all(AppColors.cream),
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.golden;
        return Colors.transparent;
      }),
      side: BorderSide(
        color: AppColors.darkGreen.withOpacity(0.70),
        width: 1.5,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
    ),

    // ── Switch ────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return AppColors.cream;
        return AppColors.darkGreen.withOpacity(0.40);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return AppColors.darkGreen.withOpacity(0.65);
        }
        return AppColors.darkGreen.withOpacity(0.15);
      }),
      trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
    ),

    // ── Divider ───────────────────────────────────────────────
    dividerTheme: DividerThemeData(
      color: AppColors.darkGreen.withOpacity(0.15),
      thickness: 1,
      space: 1,
    ),

    // ── Snackbar ──────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.cream.withOpacity(0.95),
      contentTextStyle: AppTextStyles.bodyLarge.copyWith(
        color: AppColors.darkGreen,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
    ),

    // ── Progress indicator ────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.darkGreen,
      linearMinHeight: 2.5,
    ),

    // ── Icon ──────────────────────────────────────────────────
    iconTheme: IconThemeData(
      color: AppColors.darkGreen.withOpacity(0.75),
      size: 20,
    ),
  );
}