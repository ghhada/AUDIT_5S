import 'package:flutter/material.dart';

import '../buttons/KPI.dart';

class ChoixGraphiquePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Choix Graphique'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Naviguer vers la page de suivi des îlots
              },
              child: Text('Suivis des Ilots'), // Bouton pour suivre les îlots
            ),
            SizedBox(height: 20), // Espacement entre les boutons
            ElevatedButton(
              onPressed: () {
                // Ajoutez ici la logique pour le deuxième bouton
              },
              child: Text('Suivis des Auditeurs'), // Bouton pour suivre les auditeurs
            ),
            SizedBox(height: 20), // Espacement entre les boutons
            ElevatedButton(
              onPressed: () {
                // Ajoutez ici la logique pour le troisième bouton
              },
              child: Text('Suivis des Audits'), // Bouton pour suivre les audits
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Button3Page(), // Définir Button3Page comme page d'accueil
  ));
}
