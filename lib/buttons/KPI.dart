import 'package:flutter/material.dart';
import '../KPI/IlotsStatsPage.dart';
import '../KPI/AuditeursPage.dart';
import '../KPI/Suivisdesilots.dart';
import '../KPI/planningannel.dart';

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
                      MaterialPageRoute(builder: (context) => DebutAuditPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200.0, 60.0),
                    backgroundColor: Colors.blue,
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
                      MaterialPageRoute(builder: (context) => SuiviIlotPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200.0, 60.0),
                    backgroundColor: Colors.green,
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
              SizedBox(height: 20),
              SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PlanningAnnuel()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    fixedSize: Size(200.0, 60.0),
                    backgroundColor: Colors.purple, // Couleur de fond violette pour le bouton du planning annuel
                  ),
                  child: Text(
                    'Maturité de site',
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
