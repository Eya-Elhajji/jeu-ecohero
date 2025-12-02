import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const EcoHeroApp());
}

class EcoHeroApp extends StatelessWidget {
  const EcoHeroApp({super.key});

  // 🎨 Palette verte personnalisée
  static const MaterialColor customGreen = MaterialColor(
    0xFF2E7D32,
    {
      50: Color(0xFFE8F5E9),
      100: Color(0xFFC8E6C9),
      200: Color(0xFFA5D6A7),
      300: Color(0xFF81C784),
      400: Color(0xFF66BB6A),
      500: Color(0xFF4CAF50),
      600: Color(0xFF43A047),
      700: Color(0xFF388E3C),
      800: Color(0xFF2E7D32),
      900: Color(0xFF1B5E20),
    },
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EcoHero',
      debugShowCheckedModeBanner: false,

      // 🎨 THÈME GLOBAL
      theme: ThemeData(
        primarySwatch: customGreen,
        scaffoldBackgroundColor: const Color(0xFFF7FBF7),

        appBarTheme: const AppBarTheme(
          backgroundColor: customGreen,
          elevation: 2,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: customGreen,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 20,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),

      home: const HomeScreen(),
    );
  }
}
