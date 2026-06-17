import 'package:flutter/material.dart';

import 'package:jio_leh/pages/auth/gate/auth_gate.dart';

import 'package:jio_leh/app/service_provider.dart';


final navigatorKey = GlobalKey<NavigatorState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ServiceProvider(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        navigatorKey: navigatorKey,
        home: const AuthGate(),
      ),
    );
  }
}
