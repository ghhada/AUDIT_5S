import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'TableauAudit.dart'; // Importez la nouvelle page TableauAudit.dart

class DebutAuditPage extends StatefulWidget {
  final double buttonFontSize;
  final EdgeInsets buttonTextPadding;
  final double labelTextSize;
  final EdgeInsets containerPadding;
  final double containerBorderWidth;
  final double dropdownIconSize;
  final double dropdownItemFontSize;

  const DebutAuditPage({
    Key? key,
    this.buttonFontSize = 18.0,
    this.buttonTextPadding = const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
    this.labelTextSize = 18.0,
    this.containerPadding = const EdgeInsets.all(10.0),
    this.containerBorderWidth = 1.0,
    this.dropdownIconSize = 24.0,
    this.dropdownItemFontSize = 18.0,
  }) : super(key: key);

  @override
  _DebutAuditPageState createState() => _DebutAuditPageState();
}

class _DebutAuditPageState extends State<DebutAuditPage>
{
  String? selectedAuditeur;
  String? selectedService;
  String? selectedIlot;
  List<String> auditeursNoms = [];
  List<String> ilotsNoms = [];
  Map<String, String> auditeursServices = {};

  @override
  void initState() {
    super.initState();
    _getAuditeurs();
    _getIlots();
  }

  void _getAuditeurs() {
    final auditeursReference = FirebaseDatabase.instance.reference().child('auditeurs');
    auditeursReference.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null && values['nom'] != null && values['service'] != null) {
        setState(() {
          auditeursNoms.add(values['nom']);
          auditeursServices[values['nom']] = values['service'];
        });
      }
    });
  }

  void _getIlots() {
    final ilotsReference = FirebaseDatabase.instance.reference().child('ilots');
    ilotsReference.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null && values['nom'] != null) {
        setState(() {
          ilotsNoms.add(values['nom']);
        });
      }
    });
  }

  void _navigateToNextPage(BuildContext context) {
    if (selectedAuditeur != null && selectedService != null && selectedIlot != null) {
      DateTime now = DateTime.now();
      String formattedDate = "${now.day}-${now.month}-${now.year}";
      String formattedTime = "${now.hour}:${now.minute}";

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => TableauAudit(
            nomAuditeur: selectedAuditeur!,
            service: selectedService!,
            ilot: selectedIlot!,
            date: formattedDate,
            heure: formattedTime,
          ),
        ),
      );
    } else {
      // Gérer le cas où les champs ne sont pas sélectionnés
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Début audit"),
      ),
      backgroundColor: Color(0xFF060D3A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown pour choisir l'auditeur
            Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Theme(
                data: Theme.of(context).copyWith(
                  unselectedWidgetColor: Colors.orange,
                ),
                child: DropdownButton<String>(
                  iconSize: 24.0,
                  icon: Icon(
                    Icons.arrow_drop_down,
                    color: Colors.orange,
                  ),
                  isExpanded: true,
                  hint: Text(
                    "Choisissez l'auditeur",
                    style: TextStyle(fontSize: 18.0),
                  ),
                  value: selectedAuditeur,
                  items: auditeursNoms.map((String nom) {
                    return DropdownMenuItem<String>(
                      value: nom,
                      child: Text(
                        nom,
                        style: TextStyle(fontSize: 18.0),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedAuditeur = value;
                      selectedService = auditeursServices[value!];
                    });
                  },
                ),
              ),
            ),
            // Dropdown pour choisir l'ilôt
            Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: DropdownButton<String>(
                iconSize: 24.0,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: Colors.orange,
                ),
                isExpanded: true,
                hint: Text(
                  "Choisissez l'ilôt",
                  style: TextStyle(fontSize: 18.0),
                ),
                value: selectedIlot,
                items: ilotsNoms.map((String nom) {
                  return DropdownMenuItem<String>(
                    value: nom,
                    child: Text(
                      nom,
                      style: TextStyle(fontSize: 18.0),
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedIlot = value;
                  });
                },
              ),
            ),
            // Affichage du service sélectionné
            Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border.all(color: Colors.grey, width: 1.0),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                selectedAuditeur != null ? "Service : $selectedService" : "Service",
                style: TextStyle(fontSize: 18.0),
              ),
            ),
            // Bouton pour passer à la page suivante
            Center(
              child: Container(
                padding: EdgeInsets.only(top: 20.0),
                child: InkWell(
                  onTap: () {
                    _navigateToNextPage(context);
                  },
                  borderRadius: BorderRadius.circular(30.0),
                  child: Ink(
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal:100),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Suivant',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
