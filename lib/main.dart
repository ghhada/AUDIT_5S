import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart'; // Observer pour l'analytique Firebase
import 'package:flutter/foundation.dart' show kIsWeb; // Importation pour vérifier si c'est le Web

import 'screens/main_activity.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configuration Firebase pour Android et le Web
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: kIsWeb
          ? "AIzaSyBTTVGw3VFc_Q6wNDOrIKf91qZNEbO1f8k" // Cle web
          : "AIzaSyAHy9hjSeqksGqVqWjuPIEOwpPlwZ0an3c", // Cle android
      appId: "1:695589450467:web:bd9c7572db0bfa2eb04bd6",
      messagingSenderId: "695589450467",
      projectId: "application5s",
      databaseURL: "https://application5s-default-rtdb.firebaseio.com", // URL de la base de données Firebase
    ),
  );

  // Initialisation de Firebase Analytics
  FirebaseAnalytics analytics = FirebaseAnalytics.instance;

  runApp(MyApp(analytics: analytics));
}

class MyApp extends StatelessWidget {
  final FirebaseAnalytics analytics;

  MyApp({required this.analytics});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Synctech',

        debugShowCheckedModeBanner: false,
      home: MainActivity(),
      navigatorObservers: [
        FirebaseAnalyticsObserver(analytics: analytics),
      ],
    );
  }
}
