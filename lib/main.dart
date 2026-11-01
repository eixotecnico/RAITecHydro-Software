import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';
import 'telas/login/login_screen.dart';
import 'telas/modulos/lista_de_modulos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RegadorApp());
}

class RegadorApp extends StatelessWidget {
  const RegadorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Regador Automático',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F8FA),

        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF015A84),
          primary: const Color(0xFF015A84),
        ),

        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF015A84),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF015A84),
            foregroundColor: Colors.white,
          ),
        ),

        useMaterial3: true,
      ),

      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF015A84),
                ),
              ),
            );
          }

          if (snapshot.hasData) {
            return const ListaDeModulos();
          }

          return const TelaLogin();
        },
      ),
    );
  }
}