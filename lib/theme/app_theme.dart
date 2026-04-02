import 'package:flutter/material.dart';

// Paleta de cores principal do app
class AppColors {
  // Verde escuro - cor primaria (header, botoes principais)
  static const Color primaryDark = Color(0xFF2D5016);

  // Verde medio - categorias, graficos
  static const Color primaryMedium = Color(0xFF4A7C20);

  // Verde claro - hortifruti no grafico
  static const Color primaryLight = Color(0xFF7BB33A);

  // Verde destaque - botao "Nova Compra", icones ativos
  static const Color accent = Color(0xFF5B8C2A);

  // Amarelo - higiene no grafico
  static const Color chartYellow = Color(0xFFD4A017);

  // Cinza claro - "Outros" no grafico, checkboxes
  static const Color chartGray = Color(0xFFB0B0B0);

  // Fundo geral da tela
  static const Color background = Color(0xFFF5F5F0);

  // Fundo dos cards
  static const Color cardBackground = Color(0xFFFFFFFF);

  // Texto principal
  static const Color textPrimary = Color(0xFF1A1A1A);

  // Texto secundario (subtitulos, datas)
  static const Color textSecondary = Color(0xFF666666);

  // Texto terciario (informacoes menores)
  static const Color textTertiary = Color(0xFF999999);

  // Borda dos cards e separadores
  static const Color border = Color(0xFFE8E8E0);

  // Fundo do campo de busca
  static const Color searchBackground = Color(0xFFF0F0E8);

  // Cor do check de mes concluido
  static const Color checkGreen = Color(0xFF4A7C20);
}

class AppTheme {
  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryDark,
        primary: AppColors.primaryDark,
        secondary: AppColors.accent,
        surface: AppColors.cardBackground,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,

      // Estilo da AppBar
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primaryDark,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        ),
      ),

      // Estilo dos cards
      cardTheme: CardThemeData(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.border, width: 1),
        ),
        margin: EdgeInsets.zero,
      ),

      // Estilo da barra de navegacao inferior
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardBackground,
        selectedItemColor: AppColors.primaryDark,
        unselectedItemColor: AppColors.textTertiary,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
        elevation: 8,
        type: BottomNavigationBarType.fixed,
      ),

      // Estilo dos botoes elevados
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Estilo dos campos de texto
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.searchBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        hintStyle: const TextStyle(
          color: AppColors.textTertiary,
          fontSize: 14,
        ),
      ),

      fontFamily: 'Roboto',
    );
  }
}