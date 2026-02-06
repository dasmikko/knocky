import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Knockout color palette
class KnockoutColors {
  KnockoutColors._();

  // Brand colors
  static const Color knockoutRed = Color(0xFFDB2E2E);
  static const Color knockoutRedHover = Color(0xFFEC3737);

  // Dark theme colors
  static const Color darkBackground = Color(0xFF0B0E11);
  static const Color darkBackgroundLighter = Color(0xFF1F2C39);
  static const Color darkBackgroundDarker = Color(0xFF161D24);
  static const Color darkBodyBackground = Color(0x0D1013CC);
  static const Color darkText = Color(0xFFFFFFFF);

  // Classic theme colors
  static const Color classicBackground = Color(0xFF1B1B1D);
  static const Color classicBackgroundLighter = Color(0xFF2D2D30);
  static const Color classicBackgroundDarker = Color(0xFF222226);

  // Light theme colors
  static const Color lightBackground = Color(0xFF8B8A8D);
  static const Color lightBackgroundLighter = Color(0xFFE6E6E6);
  static const Color lightBackgroundDarker = Color(0xFFF2F3F5);
  static const Color lightText = Color(0xFF222222);

  // User role colors (dark mode)
  static const Color memberColorDark = Color(0xFF3FACFF);
  static const Color memberColorLight = Color(0xFF3B9AE3);
  static const Color goldMemberColor = Color(0xFFFCBE20);
  static const Color goldMemberHighlight = Color(0xFFFFE770);
  static const Color moderatorColorDark = Color(0xFF41FF74);
  static const Color moderatorColorLight = Color(0xFF12AB1A);
  static const Color moderatorInTrainingDark = Color(0xFF4CCF6F);
  static const Color moderatorInTrainingLight = Color(0xFF30B655);
  static const Color bannedUserColor = Color(0xFFE04545);

  // Status/notification colors
  static const Color error = Color(0xFFE74C3C);
  static const Color info = Color(0xFF3498DB);
  static const Color success = Color(0xFF6DFF3E);
  static const Color warning = Color(0xFFF1C40F);

  // Accent colors
  static const Color highlightStronger = Color(0xFFF07C00); // orange
  static const Color highlightWeaker = Color(0xFF4580BF); // blue
  static const Color quoteBorder = Color(0xFF1FA1FD);
  static const Color linkBadge = Color(0xFFD31717);
}

/// Knockout theme data
class KnockoutTheme {
  KnockoutTheme._();

  /// Dark theme (default)
  static ThemeData dark() {
    final baseTextTheme = GoogleFonts.openSansTextTheme(
      ThemeData.dark().textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,

      // Color scheme
      colorScheme: const ColorScheme.dark(
        primary: KnockoutColors.knockoutRed,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFF5C1515),
        onPrimaryContainer: Color(0xFFFFDAD6),
        secondary: KnockoutColors.highlightWeaker,
        onSecondary: Colors.white,
        secondaryContainer: KnockoutColors.darkBackgroundLighter,
        onSecondaryContainer: Colors.white,
        tertiary: KnockoutColors.highlightStronger,
        onTertiary: Colors.white,
        error: KnockoutColors.error,
        onError: Colors.white,
        surface: KnockoutColors.darkBackgroundDarker,
        onSurface: KnockoutColors.darkText,
        surfaceContainerLowest: KnockoutColors.darkBackground,
        surfaceContainerLow: Color(0xFF121619),
        surfaceContainer: KnockoutColors.darkBackgroundDarker,
        surfaceContainerHigh: KnockoutColors.darkBackgroundLighter,
        surfaceContainerHighest: Color(0xFF2A3A4A),
        outline: Color(0xFF3D4D5D),
        outlineVariant: Color(0xFF2A3A4A),
      ),

      // Scaffold
      scaffoldBackgroundColor: KnockoutColors.darkBackground,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: KnockoutColors.darkBackgroundDarker,
        foregroundColor: KnockoutColors.darkText,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.openSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: KnockoutColors.darkText,
        ),
      ),

      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KnockoutColors.darkBackgroundDarker,
        selectedItemColor: KnockoutColors.knockoutRed,
        unselectedItemColor: Color(0xFF8A9AA8),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Navigation bar (Material 3)
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: KnockoutColors.darkBackgroundDarker,
        indicatorColor: KnockoutColors.knockoutRed.withValues(alpha: 0.2),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: KnockoutColors.knockoutRed,
            );
          }
          return const TextStyle(
            fontSize: 12,
            color: Color(0xFF8A9AA8),
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: KnockoutColors.knockoutRed);
          }
          return const IconThemeData(color: Color(0xFF8A9AA8));
        }),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: KnockoutColors.darkBackgroundDarker,
        elevation: 4,
        shadowColor: Colors.black54,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: KnockoutColors.darkBackgroundDarker,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Bottom sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: KnockoutColors.darkBackgroundDarker,
        modalBackgroundColor: KnockoutColors.darkBackgroundDarker,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KnockoutColors.knockoutRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          textStyle: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KnockoutColors.highlightWeaker,
          side: const BorderSide(color: KnockoutColors.highlightWeaker),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KnockoutColors.knockoutRed,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: KnockoutColors.darkBackgroundLighter,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: KnockoutColors.knockoutRed,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Input decoration (dark)
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KnockoutColors.darkBackgroundLighter,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: KnockoutColors.knockoutRed),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: KnockoutColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: const TextStyle(color: Color(0xFF6A7A8A)),
      ),

      // Text fields
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: KnockoutColors.knockoutRed,
        selectionColor: Color(0x44DB2E2E),
        selectionHandleColor: KnockoutColors.knockoutRed,
      ),

      // Chips
      chipTheme: ChipThemeData(
        backgroundColor: KnockoutColors.darkBackgroundLighter,
        selectedColor: KnockoutColors.knockoutRed.withValues(alpha: 0.3),
        labelStyle: const TextStyle(color: Colors.white),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A3A4A),
        thickness: 1,
        space: 1,
      ),

      // List tiles
      listTileTheme: const ListTileThemeData(
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        iconColor: Color(0xFF8A9AA8),
      ),

      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: KnockoutColors.darkBackgroundLighter,
        contentTextStyle: const TextStyle(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // Tabs
      tabBarTheme: const TabBarThemeData(
        labelColor: KnockoutColors.knockoutRed,
        unselectedLabelColor: Color(0xFF8A9AA8),
        indicatorColor: KnockoutColors.knockoutRed,
        dividerColor: Colors.transparent,
      ),

      // Progress indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KnockoutColors.knockoutRed,
        linearTrackColor: Color(0xFF2A3A4A),
        circularTrackColor: Color(0xFF2A3A4A),
      ),

      // Sliders
      sliderTheme: SliderThemeData(
        activeTrackColor: KnockoutColors.knockoutRed,
        inactiveTrackColor: KnockoutColors.darkBackgroundLighter,
        thumbColor: KnockoutColors.knockoutRed,
        overlayColor: KnockoutColors.knockoutRed.withValues(alpha: 0.2),
      ),

      // Switches
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KnockoutColors.knockoutRed;
          }
          return const Color(0xFF8A9AA8);
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KnockoutColors.knockoutRed.withValues(alpha: 0.5);
          }
          return const Color(0xFF2A3A4A);
        }),
      ),

      // Checkbox
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KnockoutColors.knockoutRed;
          }
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(Colors.white),
        side: const BorderSide(color: Color(0xFF8A9AA8)),
      ),

      // Radio
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return KnockoutColors.knockoutRed;
          }
          return const Color(0xFF8A9AA8);
        }),
      ),

      // Popup menus
      popupMenuTheme: PopupMenuThemeData(
        color: KnockoutColors.darkBackgroundLighter,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 8,
      ),

      // Tooltips
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: KnockoutColors.darkBackgroundLighter,
          borderRadius: BorderRadius.circular(4),
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
      ),

      // Text theme
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: KnockoutColors.darkText,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: KnockoutColors.darkText,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: KnockoutColors.darkText,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: KnockoutColors.darkText,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: KnockoutColors.darkText,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: KnockoutColors.darkText,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: KnockoutColors.darkText,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: KnockoutColors.darkText,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: KnockoutColors.darkText,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: KnockoutColors.darkText,
          height: 1.3,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: KnockoutColors.darkText,
          height: 1.3,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFFB0B8C0),
          height: 1.3,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: KnockoutColors.darkText,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: KnockoutColors.darkText,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFFB0B8C0),
        ),
      ),
    );
  }

  /// Light theme
  static ThemeData light() {
    final baseTextTheme = GoogleFonts.openSansTextTheme(
      ThemeData.light().textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: KnockoutColors.knockoutRed,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFFFDAD6),
        onPrimaryContainer: Color(0xFF410002),
        secondary: KnockoutColors.memberColorLight,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFE8E8E8),
        onSecondaryContainer: KnockoutColors.lightText,
        tertiary: KnockoutColors.highlightStronger,
        onTertiary: Colors.white,
        error: KnockoutColors.error,
        onError: Colors.white,
        surface: Colors.white,
        onSurface: KnockoutColors.lightText,
        surfaceContainerLowest: Colors.white,
        surfaceContainerLow: Color(0xFFFAFAFA),
        surfaceContainer: Color(0xFFF5F5F5),
        surfaceContainerHigh: KnockoutColors.lightBackgroundLighter,
        surfaceContainerHighest: Color(0xFFD8D8D8),
        outline: Color(0xFFB0B0B0),
        outlineVariant: Color(0xFFD0D0D0),
      ),

      // Scaffold
      scaffoldBackgroundColor: KnockoutColors.lightBackgroundDarker,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: KnockoutColors.lightBackgroundLighter,
        foregroundColor: KnockoutColors.lightText,
        elevation: 0,
        scrolledUnderElevation: 2,
        centerTitle: false,
        titleTextStyle: GoogleFonts.openSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: KnockoutColors.lightText,
        ),
      ),

      // Bottom navigation
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: KnockoutColors.lightBackgroundLighter,
        selectedItemColor: KnockoutColors.knockoutRed,
        unselectedItemColor: Color(0xFF5A5A5A),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Cards
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 4,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: Colors.white,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),

      // Bottom sheets
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        modalBackgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
      ),

      // Buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: KnockoutColors.knockoutRed,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          textStyle: GoogleFonts.openSans(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: KnockoutColors.memberColorLight,
          side: const BorderSide(color: KnockoutColors.memberColorLight),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: KnockoutColors.knockoutRed,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: KnockoutColors.lightBackgroundLighter,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(4),
          borderSide: const BorderSide(color: KnockoutColors.knockoutRed),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        hintStyle: const TextStyle(color: Color(0xFF808080)),
      ),

      // Text selection
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: KnockoutColors.knockoutRed,
        selectionColor: Color(0x44DB2E2E),
        selectionHandleColor: KnockoutColors.knockoutRed,
      ),

      // Dividers
      dividerTheme: const DividerThemeData(
        color: Color(0xFFD0D0D0),
        thickness: 1,
        space: 1,
      ),

      // Floating action button
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: KnockoutColors.knockoutRed,
        foregroundColor: Colors.white,
        elevation: 4,
      ),

      // Progress indicators
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: KnockoutColors.knockoutRed,
        linearTrackColor: Color(0xFFD0D0D0),
        circularTrackColor: Color(0xFFD0D0D0),
      ),

      // Text theme
      textTheme: baseTextTheme.copyWith(
        displayLarge: baseTextTheme.displayLarge?.copyWith(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: KnockoutColors.lightText,
        ),
        displayMedium: baseTextTheme.displayMedium?.copyWith(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: KnockoutColors.lightText,
        ),
        displaySmall: baseTextTheme.displaySmall?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: KnockoutColors.lightText,
        ),
        headlineLarge: baseTextTheme.headlineLarge?.copyWith(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: KnockoutColors.lightText,
        ),
        headlineMedium: baseTextTheme.headlineMedium?.copyWith(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: KnockoutColors.lightText,
        ),
        headlineSmall: baseTextTheme.headlineSmall?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: KnockoutColors.lightText,
        ),
        titleLarge: baseTextTheme.titleLarge?.copyWith(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: KnockoutColors.lightText,
        ),
        titleMedium: baseTextTheme.titleMedium?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: KnockoutColors.lightText,
        ),
        titleSmall: baseTextTheme.titleSmall?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: KnockoutColors.lightText,
        ),
        bodyLarge: baseTextTheme.bodyLarge?.copyWith(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: KnockoutColors.lightText,
          height: 1.3,
        ),
        bodyMedium: baseTextTheme.bodyMedium?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: KnockoutColors.lightText,
          height: 1.3,
        ),
        bodySmall: baseTextTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: const Color(0xFF606060),
          height: 1.3,
        ),
        labelLarge: baseTextTheme.labelLarge?.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: KnockoutColors.lightText,
        ),
        labelMedium: baseTextTheme.labelMedium?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: KnockoutColors.lightText,
        ),
        labelSmall: baseTextTheme.labelSmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: const Color(0xFF606060),
        ),
      ),
    );
  }
}

/// Extension to get user role colors based on theme brightness
extension UserRoleColors on BuildContext {
  Color get memberColor => Theme.of(this).brightness == Brightness.dark
      ? KnockoutColors.memberColorDark
      : KnockoutColors.memberColorLight;

  Color get moderatorColor => Theme.of(this).brightness == Brightness.dark
      ? KnockoutColors.moderatorColorDark
      : KnockoutColors.moderatorColorLight;

  Color get moderatorInTrainingColor => Theme.of(this).brightness == Brightness.dark
      ? KnockoutColors.moderatorInTrainingDark
      : KnockoutColors.moderatorInTrainingLight;

  Color get goldMemberColor => KnockoutColors.goldMemberColor;
  Color get bannedUserColor => KnockoutColors.bannedUserColor;
}
