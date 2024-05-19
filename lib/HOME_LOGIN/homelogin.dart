import 'package:flutter/material.dart';
import 'auditeurslist.dart';
import 'rapporteurslist.dart';
import 'ilotsetats.dart';

class HomeLogin extends StatefulWidget {
  @override
  _HomeLoginState createState() => _HomeLoginState();
}

class _HomeLoginState extends State<HomeLogin> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Login'),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Color(0xFF060D3A), // Fond bleu foncé
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: _isVisible ? 1.0 : 0.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AuditeursListWidget()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange), // Fond orange
                    fixedSize: MaterialStateProperty.all(Size(200.0, 60.0)), // Taille fixe
                  ),
                  child: Text('Auditeurs', style: TextStyle(color: Colors.white)), // Texte blanc
                ),
              ),
              SizedBox(height: 20.0),
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: _isVisible ? 1.0 : 0.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RapporteursList()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange), // Fond orange
                    fixedSize: MaterialStateProperty.all(Size(200.0, 60.0)), // Taille fixe
                  ),
                  child: Text('Rapporteurs', style: TextStyle(color: Colors.white)), // Texte blanc
                ),
              ),
              SizedBox(height: 20.0),
              AnimatedOpacity(
                duration: Duration(milliseconds: 500),
                opacity: _isVisible ? 1.0 : 0.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => IlotsEtats()),
                    );
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.orange), // Fond orange
                    fixedSize: MaterialStateProperty.all(Size(200.0, 60.0)), // Taille fixe
                  ),
                  child: Text('Etats ilots', style: TextStyle(color: Colors.white)), // Texte blanc
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}