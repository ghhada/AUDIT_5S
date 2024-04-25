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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tableau Audit'),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20),
            Text('Nom de l\'auditeur: ${widget.nomAuditeur}'),
            Text('Service: ${widget.service}'),
            Text('Ilot: ${widget.ilot}'),
            Text('Date: ${widget.date}'),
            Text('Heure: ${widget.heure}'),
            SizedBox(height: 20),
            Text(
              'Grille de maintien',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: MediaQuery.of(context).size.width),
                  child: DataTable(
                    columns: [
                      DataColumn(label: SizedBox(width: 550, child: Text('Critères de maintien', style: TextStyle(fontSize: 22)))),
                      DataColumn(label: SizedBox(width: 250, child: Text('Réponse', style: TextStyle(fontSize: 22)))),
                      DataColumn(label: SizedBox(width: 250, child: Text('Actions', style: TextStyle(fontSize: 22)))),
                      DataColumn(label: SizedBox(width: 250, child: Text('Responsable', style: TextStyle(fontSize: 22)))),
                      DataColumn(label: SizedBox(width: 250, child: Text('Date limite', style: TextStyle(fontSize: 22)))),
                    ],
                    rows: List.generate(10, (index) => _buildDataRow(index)),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _finishAudit();
              },
              child: Text('Terminer'),
            ),
          ],
        ),
      ),
    );
  }

  DataRow _buildDataRow(int index) {
    return DataRow(cells: [
      DataCell(SizedBox(width: 550, child: Text(_getLabelText(index), style: TextStyle(fontSize: 20)))),
      DataCell(
        Row(
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
            Text('Ok', style: TextStyle(fontSize: 20)),
            Checkbox(
              value: _checkboxValuesNonOk[index] ?? false,
              onChanged: (value) {
                setState(() {
                  _checkboxValuesNonOk[index] = value;
                  _checkboxValuesOk[index] = !value!;
                });
              },
            ),
            Text('Non Ok', style: TextStyle(fontSize: 20)),
          ],
        ),
      ),
      DataCell(
        TextField(
          decoration: InputDecoration(
            hintText: 'Actions',
          ),
          onChanged: (value) {
            setState(() {
              _actions[index] = value;
            });
          },
        ),
      ),
      DataCell(
        TextField(
          decoration: InputDecoration(
            hintText: 'Responsable',
          ),
          onChanged: (value) {
            setState(() {
              _responsables[index] = value;
            });
          },
        ),
      ),
      DataCell(
        TextButton(
          onPressed: () {
            _selectDate(context, index);
          },
          child: Text(
            _datesLimites[index] != null ? '${_datesLimites[index]!.day}/${_datesLimites[index]!.month}/${_datesLimites[index]!.year}' : 'Choisir une date',
            style: TextStyle(fontSize: 16),
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
    // Créer une liste pour stocker les actions, responsables et dates limites remplies
    List<String> actionsList = [];
    List<String> responsablesList = [];
    List<String> datesLimitesList = [];
    List<String> etatActionsList = []; // New list to store default action states

    // Parcourir les réponses pour chaque ligne du tableau
    for (int i = 0; i < _actions.length; i++) {
      // Vérifier si une action a été renseignée pour cette ligne
      if (_actions[i] != null) {
        actionsList.add('action${i + 1}: ${_actions[i]}');
        etatActionsList.add('etatAction${i + 1}: En cours'); // Ajouter l'état par défaut
      }
      // Vérifier si un responsable a été renseigné pour cette ligne
      if (_responsables[i] != null) {
        responsablesList.add('responsable${i + 1}: ${_responsables[i]}');
      }
      // Vérifier si une date limite a été renseignée pour cette ligne
      if (_datesLimites[i] != null) {
        datesLimitesList.add('dateLimite${i + 1}: ${_datesLimites[i]!.toIso8601String()}');
      }
    }

    // Créer un objet Map pour stocker les données de l'audit
    Map<String, dynamic> auditData = {
      'nomAuditeur': widget.nomAuditeur,
      'date': widget.date,
      'heure': widget.heure,
      'ilot': widget.ilot,
      ...actionsList.asMap().map((i, action) => MapEntry('action${i + 1}', action)),
      ...responsablesList.asMap().map((i, responsable) => MapEntry('responsable${i + 1}', responsable)),
      ...datesLimitesList.asMap().map((i, dateLimite) => MapEntry('dateLimite${i + 1}', dateLimite)),
      ...etatActionsList.asMap().map((i, etatAction) => MapEntry('etatAction${i + 1}', etatAction)), // Ajouter les états des actions
      'total': (_checkboxValuesOk.where((value) => value == true).length / _checkboxValuesOk.length) * 100,
    };

    // Sauvegarder les données de l'audit dans la base de données
    await _databaseRef.push().set(auditData);
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
