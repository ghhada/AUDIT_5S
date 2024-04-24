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

class _DebutAuditPageState extends State<DebutAuditPage> {
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
      // Affichez une boîte de dialogue ou un message d'erreur indiquant à l'utilisateur de remplir toutes les informations nécessaires.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Début audit"),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: widget.containerPadding,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: widget.containerBorderWidth),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButton<String>(
                  iconSize: widget.dropdownIconSize,
                  icon: Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  hint: Text(
                    "Choisissez l'auditeur",
                    style: TextStyle(fontSize: widget.labelTextSize),
                  ),
                  value: selectedAuditeur,
                  items: auditeursNoms.map((String nom) {
                    return DropdownMenuItem<String>(
                      value: nom,
                      child: Text(
                        nom,
                        style: TextStyle(fontSize: widget.dropdownItemFontSize),
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
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: widget.containerPadding,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: widget.containerBorderWidth),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButton<String>(
                  iconSize: widget.dropdownIconSize,
                  icon: Icon(Icons.arrow_drop_down),
                  isExpanded: true,
                  hint: Text(
                    "Choisissez l'ilôt",
                    style: TextStyle(fontSize: widget.labelTextSize),
                  ),
                  value: selectedIlot,
                  items: ilotsNoms.map((String nom) {
                    return DropdownMenuItem<String>(
                      value: nom,
                      child: Text(
                        nom,
                        style: TextStyle(fontSize: widget.dropdownItemFontSize),
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
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: widget.containerPadding,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: widget.containerBorderWidth),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  selectedAuditeur != null ? "Service : $selectedService" : "Service",
                  style: TextStyle(fontSize: widget.labelTextSize),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                onPressed: () => _navigateToNextPage(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Suivant",
                      style: TextStyle(fontSize: widget.buttonFontSize),
                    ),
                    Icon(Icons.arrow_forward_ios),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  padding: widget.buttonTextPadding,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

