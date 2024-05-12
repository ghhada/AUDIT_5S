import 'package:flutter/material.dart';
import '../KPI/IlotsStatsPage.dart';
import '../KPI/AuditeursPage.dart'; // Importez la page des auditeurs
// Importez la page des lots
import '../KPI/Suivisdesilots.dart';

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
                    fixedSize: Size(200.0, 60.0),
                    backgroundColor: Colors.orange,
                  ),
                  child: Text(
                    'État des Ilots',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DebutAuditPage()), // Utilisez la page des auditeurs
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200.0, 60.0),
                    backgroundColor: Colors.blue, // Couleur de fond bleue pour le bouton des auditeurs
                  ),
                  child: Text(
                    'Suivis des Auditeurs',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SuiviIlotPage()), // Utilisez la page des lots
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200.0, 60.0),
                    backgroundColor: Colors.green, // Couleur de fond verte pour le bouton des lots
                  ),
                  child: Text(
                    'Suivis des ilots',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.white,
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
