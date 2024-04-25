import 'package:flutter/material.dart';
import 'main_activity2.dart'; // Import de MainActivity2

class MainActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Synctech'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded( // Ajout de Expanded pour centrer le texte verticalement
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'Bienvenue dans Synctech',
                      style: TextStyle(
                        fontSize: 36.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center, // Ajout de TextAlign.center pour centrer le texte horizontalement
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: () {
                        // Naviguer vers la deuxième activité
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainActivity2()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange, // Couleur de fond du bouton
                        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 50), // Espacement du bouton
                      ),
                      child: Text(
                        'Commencer votre audit',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white, // Couleur du texte du bouton
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
