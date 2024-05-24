import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class PlanningAnnuel extends StatefulWidget {
  @override
  _PlanningAnnuelState createState() => _PlanningAnnuelState();
}

class _PlanningAnnuelState extends State<PlanningAnnuel> {
  late List<Auditeur> auditeurs;
  late List<Ilot> ilots;
  late List<Planning> plannings;
  int selectedYear = DateTime.now().year;
  int selectedTrimestre = 1; // Trimestre sélectionné
  late List<DataColumn> columns;

  @override
  void initState() {
    super.initState();
    auditeurs = [];
    ilots = [];
    plannings = [];
    columns = _buildTableColumns();
    _getAuditeurs();
    _getIlots();
    _getPlanning();
  }

  void _getAuditeurs() {
    final databaseReference = FirebaseDatabase.instance.reference().child('auditeurs');
    databaseReference.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        final auditeur = Auditeur(
          key: event.snapshot.key!,
          nom: values['nom'] ?? '',
          email: values['email'] ?? '',
          service: values['service'] ?? '',
        );
        setState(() {
          auditeurs.add(auditeur);
        });
      }
    });
  }

  void _getIlots() {
    final databaseReference = FirebaseDatabase.instance.reference().child('ilots');
    databaseReference.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        final ilot = Ilot(
          key: event.snapshot.key!,
          nom: values['nom'] ?? '',
          couleur: values['couleur'] ?? '',
        );
        setState(() {
          ilots.add(ilot);
        });
      }
    });
  }

  void _getPlanning() {
    final databaseReference = FirebaseDatabase.instance.reference().child('planning');
    databaseReference.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        final planning = Planning(
          key: event.snapshot.key!,
          auditeurKey: values['auditeurKey'] ?? '',
          week: values['week'] ?? 0,
          ilotKey: values['ilotKey'] ?? '',
        );
        setState(() {
          plannings.add(planning);
        });
      }
    });
  }

  void _updatePlanning(Planning planning) {
    final databaseReference = FirebaseDatabase.instance.reference().child('planning').child(planning.key);
    databaseReference.update({
      'auditeurKey': planning.auditeurKey,
      'week': planning.week,
      'ilotKey': planning.ilotKey,
    });
  }

  void _createPlanning(Planning planning) {
    final databaseReference = FirebaseDatabase.instance.reference().child('planning').push();
    databaseReference.set({
      'auditeurKey': planning.auditeurKey,
      'week': planning.week,
      'ilotKey': planning.ilotKey,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planning Annuel'),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () {
              _selectYear(context);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedTrimestre = 1;
                        columns = _buildTableColumns();
                      });
                    },
                    child: Text('1er Trimestre'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedTrimestre = 2;
                        columns = _buildTableColumns();
                      });
                    },
                    child: Text('2ème Trimestre'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedTrimestre = 3;
                        columns = _buildTableColumns();
                      });
                    },
                    child: Text('3ème Trimestre'),
                  ),
                  SizedBox(width: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedTrimestre = 4;
                        columns = _buildTableColumns();
                      });
                    },
                    child: Text('4ème Trimestre'),
                  ),
                ],
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24.0,
                  columns: columns,
                  rows: _buildTableRows(),
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade200),
                  headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  dataRowColor: MaterialStateColor.resolveWith((states) => Colors.blue.shade50),
                  dataTextStyle: TextStyle(color: Colors.black),
                  dividerThickness: 1.0,
                  border: TableBorder.all(color: Colors.grey, width: 1.0),
                ),
              ),
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24.0,
                  columns: [
                    DataColumn(label: Text('Ilot', style: TextStyle(fontSize: 16))),
                    DataColumn(label: Text('Couleur', style: TextStyle(fontSize: 16))),
                    DataColumn(label: Text('Actions', style: TextStyle(fontSize: 16))),
                  ],
                  rows: _buildIlotsRows(),
                  headingRowColor: MaterialStateColor.resolveWith((states) => Colors.green.shade200),
                  headingTextStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                  dataRowColor: MaterialStateColor.resolveWith((states) => Colors.green.shade50),
                  dataTextStyle: TextStyle(color: Colors.black),
                  dividerThickness: 1.0,
                  border: TableBorder.all(color: Colors.grey, width: 1.0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<DataColumn> _buildTableColumns() {
    List<DataColumn> columns = [
      DataColumn(label: Text('Nom', style: TextStyle(fontSize: 16))),
    ];

    int startWeek = (selectedTrimestre - 1) * 13 + 1;
    int endWeek = selectedTrimestre * 13;
    for (int i = startWeek; i <= endWeek; i++) {
      columns.add(DataColumn(label: Text('S$i', style: TextStyle(fontSize: 16))));
    }

    return columns;
  }

  List<DataRow> _buildTableRows() {
    List<DataRow> rows = auditeurs.map((auditeur) {
      List<DataCell> cells = [
        DataCell(Text(auditeur.nom, style: TextStyle(fontSize: 14))),
      ];
      int startWeek = (selectedTrimestre - 1) * 13 + 1;
      int endWeek = selectedTrimestre * 13;
      for (int i = startWeek; i <= endWeek; i++) {
        Planning? planning = plannings.firstWhere(
              (p) => p.auditeurKey == auditeur.key && p.week == i,
          orElse: () => Planning(key: '', auditeurKey: '', week: 0, ilotKey: ''),
        );

        Ilot? ilot = ilots.firstWhere((i) => i.key == planning.ilotKey, orElse: () => Ilot(key: '', nom: '', couleur: '#FFFFFF'));

        Color color;
        try {
          color = Color(int.parse(ilot.couleur.replaceFirst('#', '0xff')));
        } catch (e) {
          color = Colors.grey; // Couleur par défaut en cas d'erreur
        }

        cells.add(
          DataCell(
            GestureDetector(
              onTap: () {
                _selectIlot(context, auditeur, i);
              },
              child: Container(
                width: 60.0,
                height: 20.0,
                color: color,
              ),
            ),
          ),
        );
      }
      return DataRow(cells: cells);
    }).toList();

    return rows;
  }

  List<DataRow> _buildIlotsRows() {
    return ilots.map((ilot) {
      Color color;
      try {
        color = Color(int.parse(ilot.couleur.replaceFirst('#', '0xff')));
      } catch (e) {
        color = Colors.grey; // Couleur par défaut en cas d'erreur
      }
      return DataRow(
          cells: [
          DataCell(Text(ilot.nom, style: TextStyle(fontSize: 14))),
            DataCell(Container(
              width: 60.0,
              height: 20.0,
              color: color,
            )),
            DataCell(IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _selectColor(context, ilot);
              },
            )),
          ],
      );
    }).toList();
  }

  Future<void> _selectYear(BuildContext context) async {
    final pickedYear = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(DateTime.now().year - 5),
      lastDate: DateTime(DateTime.now().year + 5),
      initialDatePickerMode: DatePickerMode.year,
    );

    if (pickedYear != null && pickedYear.year != selectedYear) {
      setState(() {
        selectedYear = pickedYear.year;
      });
    }
  }

  void _selectColor(BuildContext context, Ilot ilot) {
    Color pickedColor = Colors.blue;
    String selectedIlotName = ilot.nom; // Initialisez le nom de l'îlot sélectionné

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Sélectionner une couleur'),
              content: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButton<String>(
                      hint: Text('Choisissez un îlot'), // Texte par défaut
                      value: selectedIlotName,
                      onChanged: (String? newValue) {
                        setState(() {
                          selectedIlotName = newValue!;
                        });
                      },
                      items: [''].followedBy(ilots.map((Ilot ilot) {
                        return ilot.nom;
                      })).toList().map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 10),
                    Text('Choisissez une couleur:'),
                    ColorPicker(
                      pickerColor: pickedColor,
                      onColorChanged: (Color color) {
                        pickedColor = color;
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                ElevatedButton(
                  child: Text('Annuler'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                ElevatedButton(
                  child: Text('Enregistrer'),
                  onPressed: () {
                    setState(() {
                      ilot.couleur = '#${pickedColor.value.toRadixString(16).substring(2)}';
                      _updateIlot(ilot);
                    });
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }






  void _updateIlot(Ilot ilot) {
    final databaseReference = FirebaseDatabase.instance.reference().child('ilots').child(ilot.key);
    databaseReference.update({
      'nom': ilot.nom,
      'couleur': ilot.couleur,
    });
  }

  void _selectIlot(BuildContext context, Auditeur auditeur, int week) {
    String? selectedIlotKey; // Variable pour stocker la clé de l'îlot sélectionné

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Sélectionner un îlot pour la semaine $week'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Choisissez un îlot:'),
                DropdownButton<String>(
                  value: selectedIlotKey,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedIlotKey = newValue;
                    });
                  },
                  items: ilots.map<DropdownMenuItem<String>>((Ilot ilot) {
                    return DropdownMenuItem<String>(
                      value: ilot.key,
                      child: Text(ilot.nom),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text('Annuler'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Enregistrer'),
              onPressed: () {
                if (selectedIlotKey != null) {
                  setState(() {
                    Planning newPlanning = Planning(key: '', auditeurKey: auditeur.key, week: week, ilotKey: selectedIlotKey!);
                    plannings.removeWhere((p) => p.auditeurKey == auditeur.key && p.week == week);
                    plannings.add(newPlanning);
                    _createPlanning(newPlanning);
                  });
                  Navigator.of(context).pop();
                } else {
                  // Afficher un message d'erreur si aucun îlot n'est sélectionné
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Veuillez choisir un îlot')));
                }
              },
            ),
          ],
        );
      },
    );
  }

}

class Auditeur {
  late String key;
  String nom;
  String email;
  String service;

  Auditeur({required this.key, required this.nom, required this.email, required this.service});
}

class Ilot {
  late String key;
  String nom;
  String couleur;

  Ilot({required this.key, required this.nom, required this.couleur});
}

class Planning {
  late String key; // Rendre cette propriété obligatoire
  String auditeurKey;
  int week;
  String ilotKey;

  Planning({required this.key, required this.auditeurKey, required this.week, required this.ilotKey});
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: PlanningAnnuel(),
    debugShowCheckedModeBanner: false,
  ));
}

