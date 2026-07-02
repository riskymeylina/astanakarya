import 'package:flutter/material.dart';

class PurchaseTheme {
  // Primary colors from existing design system
  static const Color cream = Color(0xFFFDD096);
  static const Color navy = Color(0xFF1E2B5B);
  static const Color brown = Color(0xFF8E4E16);
  static const Color darkBrown = Color(0xFF33241A);

  // Supporting colors
  static const Color background = Color(0xFFF8F3EC);
  static const Color checkoutBackground = Color(0xFFFAFAFA);
  static const Color cardBackground = Colors.white;
  static const Color lightCream = Color(0xFFFFF8F0);
  static const Color paymentSelectedBg = Color(0xFFEAF8EF);
  static const Color dividerColor = Color(0xFFEDEDED);
  static const Color border = Color(0xFFDEC9AD);
  static const Color lightBorder = Color(0xFFE9D7BF);
  static const Color orangeBg = Color(0xFFFFE9C8);
  static const Color brownText = Color(0xFF6D5540);
  static const Color hintText = Color(0xFFB8A090);

  // Status colors
  static const Color success = Color(0xFF1F7A45);
  static const Color error = Color(0xFFC0392B);
  static const Color warning = Color(0xFFE67E22);

  // Text styles
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: darkBrown,
    fontFamily: 'TomatoGrotesk',
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: darkBrown,
    fontFamily: 'TomatoGrotesk',
  );

  static const TextStyle checkoutTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: Color(0xFF171717),
    fontFamily: 'TomatoGrotesk',
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: darkBrown,
    fontFamily: 'TomatoGrotesk',
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: darkBrown,
    fontFamily: 'TomatoGrotesk',
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: brownText,
    fontFamily: 'TomatoGrotesk',
  );

  static const TextStyle hint = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: hintText,
    fontFamily: 'TomatoGrotesk',
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    color: hintText,
    fontFamily: 'TomatoGrotesk',
  );

  // Spacing constants
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing6 = 6;
  static const double spacing8 = 8;
  static const double spacing10 = 10;
  static const double spacing12 = 12;
  static const double spacing14 = 14;
  static const double spacing16 = 16;
  static const double spacing18 = 18;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;

  // Border radius
  static const double radiusSmall = 10;
  static const double radiusMedium = 14;
  static const double radiusLarge = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 26;
  static const double radiusRound = 28;

  // Animation durations
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationLong = Duration(milliseconds: 400);

  // Input field height
  static const double inputHeight = 56;

  // Button height
  static const double buttonHeight = 56;
  static const double checkoutButtonHeight = 50;
  static const double sectionSpacing = 12;

  // Icon size constants
  static const double iconSmall = 16;
  static const double iconMedium = 18;
  static const double iconStandard = 24;
  static const double iconLarge = 32;

  // Shadow definitions
  static const BoxShadow shadowSmall = BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 4,
    offset: Offset(0, 2),
  );

  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x1F000000),
    blurRadius: 8,
    offset: Offset(0, 4),
  );

  static const List<BoxShadow> shadowsSmall = [shadowSmall];
  static const List<BoxShadow> shadowsMedium = [shadowMedium];

  // Input decoration
  static InputDecoration buildInputDecoration({
    required String label,
    String? hint,
    Widget? suffix,
    bool isRequired = false,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffix: suffix,
      hintStyle: const TextStyle(
        color: hintText,
        fontSize: 13.5,
        fontFamily: 'TomatoGrotesk',
      ),
      labelStyle: const TextStyle(
        color: brownText,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        fontFamily: 'TomatoGrotesk',
      ),
      filled: true,
      fillColor: lightCream,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing14,
        vertical: spacing12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: cream, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: error, width: 2),
      ),
    );
  }

  // Card decoration
  static BoxDecoration cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radiusXL),
      border: Border.all(color: lightBorder),
      boxShadow: shadowsSmall,
    );
  }

  // Price text with formatting
  static TextStyle priceStyle() {
    return const TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w900,
      color: navy,
      fontFamily: 'TomatoGrotesk',
    );
  }
}
