import 'package:flutter/material.dart';
import 'auditeurslist.dart';
import 'rapporteurslist.dart';
import 'ilotsetats.dart';
import 'planningPage.dart';

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
          color: Color(0xFF060D3A), // Dark blue background
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildAnimatedButton(
                label: 'Auditeurs',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AuditeursListWidget()),
                  );
                },
              ),
              SizedBox(height: 20.0),
              _buildAnimatedButton(
                label: 'Rapporteurs',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RapporteursList()),
                  );
                },
              ),
              SizedBox(height: 20.0),
              _buildAnimatedButton(
                label: 'Etats ilots',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => IlotsEtats()),
                  );
                },
              ), SizedBox(height: 20.0),
              _buildAnimatedButton(
                label: 'Planning Annuel',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PlanningAnnuel()),
                  );
                },
              ),


            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({required String label, required VoidCallback onPressed}) {
    return AnimatedOpacity(
      duration: Duration(milliseconds: 500),
      opacity: _isVisible ? 1.0 : 0.0,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all(Colors.orange), // Orange background
          fixedSize: MaterialStateProperty.all(Size(200.0, 60.0)), // Fixed size
        ),
        child: Text(
          label,
          style: TextStyle(color: Colors.white), // White text
        ),
      ),
    );
  }
}

