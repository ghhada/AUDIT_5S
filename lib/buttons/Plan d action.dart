import 'package:flutter/material.dart';
import '../PAC/pac.dart'; // Assure-toi que le chemin est correct.

class Button2Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Planifier la navigation après le build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => PACPage()),
      );
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Plan d\'action'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Redirection vers PAC...',
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),  // Un espace
            CircularProgressIndicator(),  // Indicateur de chargement
          ],
        ),
      ),
    );
  }
}