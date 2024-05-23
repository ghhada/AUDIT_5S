import 'package:emailjs/emailjs.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class TableauAudit extends StatefulWidget {
  final String nomAuditeur;
  final String service;
  final String ilot;
  final String date;
  final String heure;

  TableauAudit({
    required this.nomAuditeur,
    required this.service,
    required this.ilot,
    required this.date,
    required this.heure,
  });

  @override
  _TableauAuditState createState() => _TableauAuditState();
}

class _TableauAuditState extends State<TableauAudit> {
  late List<bool?> _checkboxValuesOk;
  late List<bool?> _checkboxValuesNonOk;
  late List<String?> _actions;
  late List<String?> _responsables;
  late List<DateTime?> _datesLimites;

  final _databaseRef = FirebaseDatabase.instance.reference().child('audits');

  @override
  void initState() {
    super.initState();
    _checkboxValuesOk = List.generate(10, (index) => null);
    _checkboxValuesNonOk = List.generate(10, (index) => null);
    _actions = List.generate(10, (index) => null);
    _responsables = List.generate(10, (index) => null);
    _datesLimites = List.generate(10, (index) => null);
  }

  Future<List<String>> getEmails() async {
    List<String> emailList = [];
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('rapporteurs');

    DatabaseEvent event = await ref.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        emailList.add(value['email']);
      });
    }

    return emailList;
  }

  String formatAuditData() {
    List<String> actionsList = [];
    for (int i = 0; i < 10; i++) {
      // Vérifier si une action, un responsable et une date limite ont été spécifiés
      if (_actions[i] != null && _actions[i]!.isNotEmpty && _responsables[i] != null && _responsables[i]!.isNotEmpty) {
        String action = _actions[i]!;
        String responsable = _responsables[i]!;
        String dateLimite = _datesLimites[i] != null ? '${_datesLimites[i]!.day}/${_datesLimites[i]!.month}/${_datesLimites[i]!.year}' : 'Non spécifié';

        actionsList.add("Action ${i + 1} : $action\nResponsable ${i + 1} : $responsable\nDate limite ${i + 1} : $dateLimite\n");
      }
    }

    double pourcentage = (_checkboxValuesOk.where((value) => value == true).length / _checkboxValuesOk.length) * 100;

    return "Auditeur : ${widget.nomAuditeur}\n" +
        "Date: ${widget.date}\n" +
        "Heure: ${widget.heure}\n" +
        "Ilot: ${widget.ilot}\n" +
        "Service: ${widget.service}\n" +
        "Pourcentage: ${pourcentage.toStringAsFixed(2)}%\n" +
        actionsList.join("\n");
  }



  Future<bool> sendEmail() async {
    List<String> emailList = await getEmails();
    String formattedAuditData = formatAuditData();

    try {
      for (String email in emailList) {
        await EmailJS.send(
          'service_ua5dkp3',
          'template_8jhq3ow',
          {
            'user_email': email,
            'user_message': formattedAuditData,
          },
          const Options(
            publicKey: 'jSpioF9IBE7K0psSE',
            privateKey: 'n3GQP6SzQEfhcjcR0fmP3',
          ),
        );
      }
      print('SUCCESS!');
      return true;
    } catch (error) {
      if (error is EmailJSResponseStatus) {
        print('ERROR... ${error.status}: ${error.text}');
      }
      print(error.toString());
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau Audit'),
      ),
      backgroundColor: Color(0xFF060D3A),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: SizedBox(
                width: 300,
                child: Card(
                  color: Colors.orange,
                  elevation: 4,
                  margin: EdgeInsets.all(8),
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations de l\'auditeur',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        SizedBox(height: 8),
                        Text('Nom de l\'auditeur: ${widget.nomAuditeur}', style: TextStyle(color: Colors.white)),
                        Text('Service: ${widget.service}', style: TextStyle(color: Colors.white)),
                        Text('Ilot: ${widget.ilot}', style: TextStyle(color: Colors.white)),
                        Text('Date: ${widget.date}', style: TextStyle(color: Colors.white)),
                        Text('Heure: ${widget.heure}', style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Container(
                color: Colors.white, // Fond du tableau en blanc
                child: DataTable(
                  dataRowHeight: 80,
                  columns: [
                    DataColumn(label: SizedBox(width: 550, child: Text('Critères de maintien', style: TextStyle(fontSize: 30, color: Colors.black)))),
                    DataColumn(label: SizedBox(width: 250, child: Text('Réponse', style: TextStyle(fontSize: 30, color: Colors.black)))),
                    DataColumn(label: SizedBox(width: 250, child: Text('Actions', style: TextStyle(fontSize: 30, color: Colors.black)))),
                    DataColumn(label: SizedBox(width: 250, child: Text('Responsable', style: TextStyle(fontSize: 30, color: Colors.black)))),
                    DataColumn(label: SizedBox(width: 250, child: Text('Date limite', style: TextStyle(fontSize: 30, color: Colors.black)))),
                  ],
                  rows: List.generate(10, (index) => _buildDataRow(index)),
                ),
              ),
            ),
            SizedBox(height: 30),
            Center(
              child: SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: () {
                    _finishAudit();
                    sendEmail();
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.orange,
                    minimumSize: Size(100, 60),
                  ),
                  child: Text(
                    'Terminer',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Text(
                'Total : ${(_checkboxValuesOk.where((value) => value == true).length / _checkboxValuesOk.length) * 100}%',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(int index) {
    return DataRow(cells: [
      DataCell(
        Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          width: 750,
          decoration: BoxDecoration(
            color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
          ),
          child: Text(
            _getLabelText(index),
            style: TextStyle(fontSize: 18, color: Colors.black),
            softWrap: true,
          ),
        ),
      ),
      DataCell(
        Container(
          width: 200,
          child: Row(
            children: [
              Checkbox(
                value: _checkboxValuesOk[index] ?? false,
                onChanged: (value) {
                  setState(() {
                    _checkboxValuesOk[index] = value;
                    _checkboxValuesNonOk[index] = !value!;
                  });
                },
              ),
              Text('Ok', style: TextStyle(fontSize: 16)),
              SizedBox(width: 8),
              Checkbox(
                value: _checkboxValuesNonOk[index] ?? false,
                onChanged: (value) {
                  setState(() {
                    _checkboxValuesNonOk[index] = value;
                    _checkboxValuesOk[index] = !value!;
                  });
                },
              ),
              Text('Non Ok', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
      DataCell(
        Container(
          width: 250,
          child: TextFormField(
            initialValue: _actions[index],
            onChanged: (value) {
              setState(() {
                _actions[index] = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ),
      DataCell(
        Container(
          width: 250,
          child: TextFormField(
            initialValue: _responsables[index],
            onChanged: (value) {
              setState(() {
                _responsables[index] = value;
              });
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ),
      ),
      DataCell(
        Container(
          width: 250,
          child: GestureDetector(
            onTap: () => _selectDate(context, index),
            child: InputDecorator(
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              child: Text(
                _datesLimites[index] != null
                    ? '${_datesLimites[index]!.day}/${_datesLimites[index]!.month}/${_datesLimites[index]!.year}'
                    : 'Sélectionner une date',
              ),
            ),
          ),
        ),
      ),
    ]);
  }

  Future<void> _selectDate(BuildContext context, int index) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _datesLimites[index] ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _datesLimites[index]) {
      setState(() {
        _datesLimites[index] = picked;
      });
    }
  }

  String _getLabelText(int index) {
    switch (index) {
      case 0:
        return 'Les zones et les périmètres 5S sont-ils définis (marquage) et identifiés?';
      case 1:
        return 'Les responsables sont-ils nommés et affichés?';
      case 2:
        return 'Tous les objets et matières inutiles du lieu de travail sont-ils éliminés?';
      case 3:
        return 'Tous les objets ont-ils une place identifiée?';
      case 4:
        return 'Tous les objets sont-ils à leur place?';
      case 5:
        return 'Les accès sont-ils dégagés?';
      case 6:
        return 'Les moyens sont-ils en condition de marche?';
      case 7:
        return 'Les standards sont-ils en place?';
      case 8:
        return 'L\'état 5S est-il affiché sur le lieu de travail?';
      case 9:
        return 'Les zones ont-elles été auditées la semaine dernière avec un plan d\'action associé?';
      default:
        return '';
    }
  }

  Future<void> _finishAudit() async {
    List<String> actionsList = [];
    List<String> responsablesList = [];
    List<String> datesLimitesList = [];

    for (int i = 0; i < _actions.length; i++) {
      if (_actions[i] != null) {
        actionsList.add('action${i+1}: ${_actions[i]}');
      }
      if (_responsables[i] != null) {
        responsablesList.add('responsable${i+1}: ${_responsables[i]}');
      }
      if (_datesLimites[i] != null) {
        datesLimitesList.add('dateLimite${i+1}: ${_datesLimites[i]!.toIso8601String()}');
      }
    }

    Map<String, dynamic> auditData = {
      'nomAuditeur': widget.nomAuditeur,
      'date': widget.date,
      'heure': widget.heure,
      'ilot': widget.ilot,
      ...actionsList.asMap().map((i, action) => MapEntry('action${i+1}', action)),
      ...responsablesList.asMap().map((i, responsable) => MapEntry('responsable${i+1}', responsable)),
      ...datesLimitesList.asMap().map((i, dateLimite) => MapEntry('dateLimite${i+1}', dateLimite)),
      'total': (_checkboxValuesOk.where((value) => value == true).length / _checkboxValuesOk.length) * 100,
    };

    try {
      await _databaseRef.push().set(auditData);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Succès'),
            content: Text('Les données ont été envoyées avec succès à la base de données.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (error) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Une erreur s\'est produite lors de l\'envoi des données : $error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: TableauAudit(
      nomAuditeur: 'Nom Auditeur',
      service: 'Service',
      ilot: 'Ilot',
      date: 'Date',
      heure: 'Heure',
    ),
  ));
}
