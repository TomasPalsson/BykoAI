import 'package:flutter/material.dart';
import 'package:byko_app/screens/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: theme,
      home: HomeScreen(),
    );
  }

  ThemeData get theme => ThemeData(
    primaryColor: Color(0xFF0067a4),
    scaffoldBackgroundColor: Color(0xFF2B2C28),
    textTheme: TextTheme(
      bodyMedium: GoogleFonts.roboto(
        fontSize: 16,
        color: Colors.white,
      ),
    ),
  );
}

