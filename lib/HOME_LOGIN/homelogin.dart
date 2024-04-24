import 'package:flutter/material.dart';
import 'auditeurslist.dart';
import 'rapporteurslist.dart';
import 'ilotsetats.dart';

class HomeLogin extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Login'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AuditeursListWidget()),
                );
              },
              child: Text('Auditeurs'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RapporteursList()),
                );
              },
              child: Text('Rapporteurs'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => IlotsEtats()),
                );
              },
              child: Text('Etats ilots'),
            ),
          ],
        ),
      ),
    );
  }
}
