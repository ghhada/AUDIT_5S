import 'package:flutter/material.dart';
import '../KPI/IlotsStatsPage.dart';

class Button3Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('KPI'),
      ),
      body: Container(
        color: Color(0xFF060D3A),
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              SizedBox(height: 20),
              SizedBox(

                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AllDataPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200.0, 60.0), // Ajustement de la taille du bouton
                    backgroundColor: Colors.orange, // Couleur de fond orangée
                  ),
                  child: Text(
                    'État des Ilots',
                    style: TextStyle(
                      fontSize: 16.0, // Taille de texte du bouton réduite
                      color: Colors.white, // Couleur du texte en blanc
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
