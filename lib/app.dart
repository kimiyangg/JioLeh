import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:jio_leh/pages/auth_page.dart';
import 'package:jio_leh/pages/map_page.dart';

import 'package:jio_leh/services/auth_services.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  static final _auth = AuthServices();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (!_auth.isSignedIn()) {
          return const AuthPage();
        }
        return const MapPage();
      },
    );
  }
}
