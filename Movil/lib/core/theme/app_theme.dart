import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  const AppColors._();


  static const Color primary = Color(0xFF2E7D5B);
  static const Color primaryDark = Color(0xFF1B5E43);
  static const Color secondary = Color(0xFF4CAF7D);
  static const Color tertiary = Color(0xFFA8DDB5);
  static const Color backgroundLight = Color(0xFFE8F5E9);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF4F7F5);


  static const Color textPrimary = Color(0xFF101512);
  static const Color textSecondary = Color(0xFF46584E);
  static const Color textHint = Color(0xFF78877E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);


  static const Color xpGold = Color(0xFFF6C85F);
  static const Color xpGoldLight = Color(0xFFFFF3CD);
  static const Color coinGold = Color(0xFFF6C85F);
  static const Color coinGoldLight = Color(0xFFFFF3CD);


  static const Color bluePastel = Color(0xFF9ED8E8);
  static const Color coralSoft = Color(0xFFF3A6A0);
  static const Color lavender = Color(0xFFC9B8E8);



  static const Color mintSoft = Color(0xFFFFFFFF);
  static const Color mintLight = Color(0xFFD7EFE0);
  static const Color mint = Color(0xFF8ED9B4);
  static const Color mintStrong = Color(0xFF3FAE78);
  static const Color mintDark = Color(0xFF2E7D5B);


  static const Color success = Color(0xFF4CAF7D);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);


  static const Color divider = Color(0xFFDCE5DF);
  static const Color border = Color(0xFFDCE5DF);
  static const Color cardShadow = Color(0x1A000000);
  static const Color overlay = Color(0x66000000);


  static const Color difficultyEasy = Color(0xFF4CAF7D);
  static const Color difficultyMedium = Color(0xFFFF9800);
  static const Color difficultyHard = Color(0xFFE53935);


  static const Color streakFire = Color(0xFFFF6B35);


  static const Color levelPurple = Color(0xFF7B1FA2);


  static const Color gardenGreen = Color(0xFF43A047);
  static const Color gardenGrass = Color(0xFF8BC34A);


  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceDim = Color(0xFFEEF3EF);
  static const Color surfaceCard = Color(0xFFFFFFFF);
  static const Color snackBarBackground = Color(0xFF1F2A24);


  static const Color primaryLight = Color(0xFF4CAF7D);
  static const Color accent = Color(0xFFF6C85F);




  static const Color ecoBg = Color(0xFF071C17);
  static const Color ecoBgLight = Color(0xFF0B251F);
  static const Color ecoGreen = Color(0xFF18C7A0);
  static const Color ecoGreen2 = Color(0xFF22D3A7);
  static const Color ecoGreenLight = Color(0xFF65E6C7);
  static const Color ecoGold = Color(0xFFFFC94A);
  static const Color ecoBlue = Color(0xFF45B8FF);
  static const Color ecoRed = Color(0xFFFF5A52);
}

class AppColorsDark {
  const AppColorsDark._();



  static const Color primary = Color(0xFF3F8F6B);
  static const Color secondary = Color(0xFF5FAE85);
  static const Color tertiary = Color(0xFF24402F);
  static const Color background = Color(0xFF0A1410);
  static const Color surface = Color(0xFF0F1D16);
  static const Color backgroundLight = Color(0xFF182A1F);


  static const Color ecoGreen = Color(0xFF2E6B50);
  static const Color ecoGreen2 = Color(0xFF3A7D5E);
  static const Color ecoGreenLight = Color(0xFF529878);

  static const Color textPrimary = Color(0xFFE8F5E9);
  static const Color textSecondary = Color(0xFFA8DDB5);
  static const Color textHint = Color(0xFF607D63);
  static const Color textOnPrimary = Color(0xFF1C261E);

  static const Color xpGold = Color(0xFFF6C85F);
  static const Color xpGoldLight = Color(0xFF3D3520);
  static const Color coinGold = Color(0xFFF6C85F);
  static const Color coinGoldLight = Color(0xFF3D3520);

  static const Color divider = Color(0xFF2A3A2E);
  static const Color border = Color(0xFF2A3A2E);
  static const Color cardShadow = Color(0x33000000);
  static const Color overlay = Color(0x88000000);

  static const Color success = Color(0xFF4CAF7D);
  static const Color warning = Color(0xFFFFB74D);
  static const Color error = Color(0xFFEF5350);
  static const Color info = Color(0xFF64B5F6);

  static const Color difficultyEasy = Color(0xFF4CAF7D);
  static const Color difficultyMedium = Color(0xFFFFB74D);
  static const Color difficultyHard = Color(0xFFEF5350);

  static const Color streakFire = Color(0xFFFF8A65);
  static const Color levelPurple = Color(0xFFBA68C8);
  static const Color gardenGreen = Color(0xFF66BB6A);
  static const Color gardenGrass = Color(0xFF9CCC65);

  static const Color surfaceElevated = Color(0xFF16261C);
  static const Color surfaceDim = Color(0xFF08120D);
  static const Color surfaceCard = Color(0xFF0F1D16);



  static const Color mintSoft = Color(0xFF14261C);
  static const Color mintLight = Color(0xFF1E3A2B);
  static const Color mint = Color(0xFF5E9F80);
  static const Color mintStrong = Color(0xFF7CBF9B);
  static const Color mintDark = Color(0xFF2E6B50);
}

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      error: AppColors.error,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: AppColors.surface,
      surfaceContainerLow: AppColors.surface,
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surface,
      surfaceContainerHighest: AppColors.surfaceDim,
      outline: AppColors.border,
      outlineVariant: AppColors.border,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 2,
        shadowColor: AppColors.cardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          elevation: 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.3),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.secondary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.secondary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColors.textHint),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.snackBarBackground,
        contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColorsDark.primary,
      primary: AppColorsDark.primary,
      secondary: AppColorsDark.secondary,
      error: AppColorsDark.error,
      surface: AppColorsDark.surface,
      brightness: Brightness.dark,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColorsDark.background,
      appBarTheme: AppBarTheme(
        backgroundColor: AppColorsDark.surface,
        foregroundColor: AppColorsDark.textPrimary,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle.light.copyWith(
          statusBarColor: Colors.transparent,
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColorsDark.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColorsDark.surfaceCard,
        elevation: 4,
        shadowColor: AppColorsDark.cardShadow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColorsDark.primary,
          foregroundColor: AppColorsDark.textOnPrimary,
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColorsDark.primary,
          side: const BorderSide(color: AppColorsDark.primary, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColorsDark.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColorsDark.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColorsDark.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColorsDark.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColorsDark.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColorsDark.error),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: AppColorsDark.textHint),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColorsDark.surface,
        selectedItemColor: AppColorsDark.primary,
        unselectedItemColor: AppColorsDark.textHint,
        type: BottomNavigationBarType.fixed,
        elevation: 12,
        selectedLabelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColorsDark.textPrimary,
        contentTextStyle: TextStyle(
          color: AppColorsDark.textOnPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        behavior: SnackBarBehavior.floating,
      ),
      dialogTheme: DialogThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }
}

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.dark;
  bool _modoDaltonico = false;

  ThemeMode get themeMode => _themeMode;

  bool get isDark => _themeMode == ThemeMode.dark;



  bool get modoDaltonico => _modoDaltonico;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.dark
        ? ThemeMode.light
        : ThemeMode.dark;
    notifyListeners();
  }

  void setModoDaltonico(bool activo) {
    _modoDaltonico = activo;
    notifyListeners();
  }
}
