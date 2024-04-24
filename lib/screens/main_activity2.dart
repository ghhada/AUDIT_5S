import 'package:flutter/material.dart';
import '../buttons/5S.dart'; // Import Button1Page
import '../buttons/Plan d action.dart'; // Import Button2Page
import '../buttons/KPI.dart'; // Import Button3Page
import '../buttons/Assessement.dart'; // Import Button4Page
import '../buttons/admin.dart'; // Import LoginScreen

class MainActivity2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/background.jpg'), // Chemin vers l'image de fond
                fit: BoxFit.cover, // Redimensionner l'image pour couvrir toute la zone
              ),
            ),
          ),
          Positioned(
            top: 20.0,
            right: 20.0,
            child: ElevatedButton(
              onPressed: () {
                // Navigate to the login screen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Login()),
                );
              },
              child: Text('ADMIN'),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 200, // Largeur prédéfinie du bouton
                  height: 50, // Hauteur prédéfinie du bouton
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the page defined by Button1
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Button1Page()),
                      );
                    },
                    child: Text('5S'),
                  ),
                ),
                SizedBox(height: 10.0), // Add spacing between buttons
                SizedBox(
                  width: 200, // Largeur prédéfinie du bouton
                  height: 50, // Hauteur prédéfinie du bouton
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the page defined by Button2
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Button2Page()),
                      );
                    },
                    child: Text('Plan d action'),
                  ),
                ),
                SizedBox(height: 10.0), // Add spacing between buttons
                SizedBox(
                  width: 200, // Largeur prédéfinie du bouton
                  height: 50, // Hauteur prédéfinie du bouton
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the page defined by Button3
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Button3Page()),
                      );
                    },
                    child: Text('   KPI   '),
                  ),
                ),
                SizedBox(height: 10.0), // Add spacing between buttons
                SizedBox(
                  width: 200, // Largeur prédéfinie du bouton
                  height: 50, // Hauteur prédéfinie du bouton
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the page defined by Button4
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Button4Page()),
                      );
                    },
                    child: Text('Assessment'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
