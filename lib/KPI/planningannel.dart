import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';

class PlanningAnnuel extends StatefulWidget {
  @override
  _PlanningAnnuelState createState() => _PlanningAnnuelState();
}

class _PlanningAnnuelState extends State<PlanningAnnuel> {
  late List<Auditeur> auditeurs;
  late List<Ilot> ilots;
  late List<Audit> audits;
  int selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    auditeurs = [];
    ilots = [];
    audits = [];
    _getIlots();
    _getAudits();
  }

  void _getAudits() {
    final databaseReference = FirebaseDatabase.instance.reference().child('audits');
    databaseReference.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        final audit = Audit(
          key: event.snapshot.key!,
          ilot: values['ilot'] ?? '',
          date: DateFormat('dd-MM-yyyy').parse(values['date']),
          total: values['total'] ?? 0,
        );
        setState(() {
          audits.add(audit);
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
          etat: values['etat'] ?? '',
        );
        setState(() {
          ilots.add(ilot);
        });
      }
    });
  }

  int _getWeekOfYear(DateTime date) {
    final dayOfYear = int.parse(DateFormat('D').format(date));
    return ((dayOfYear - date.weekday + 10) / 7).floor();
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
              SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 24.0,
                  columns: _buildTableColumns(),
                  rows: _buildTableRows(),
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

    for (int i = 1; i <= 52; i++) {
      columns.add(DataColumn(label: Text('S$i', style: TextStyle(fontSize: 16))));
    }

    return columns;
  }

  List<DataRow> _buildTableRows() {
    List<DataRow> rows = ilots.map((ilot) {
      Color ilotColor = _getIlotColor(ilot);
      List<DataCell> cells = [
        DataCell(
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: ilotColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Text(
              ilot.nom,
              style: TextStyle(fontSize: 14, color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        for (int i = 1; i <= 52; i++)
          DataCell(_buildAuditCell(ilot.nom, i)),
      ];
      return DataRow(cells: cells);
    }).toList();

    // Ajout de la ligne pour la moyenne de chaque semaine
    rows.add(DataRow(cells: [
      DataCell(Text('Moyenne', style: TextStyle(fontWeight: FontWeight.bold))),
      for (int week = 1; week <= 52; week++)
        DataCell(_calculateAverageForWeek(week)),
    ]));

    return rows;
  }

  Widget _calculateAverageForWeek(int week) {
    // Calculer la somme des audits pour la semaine donnée
    int totalForWeek = 0;
    for (var audit in audits) {
      if (_getWeekOfYear(audit.date) == week) {
        totalForWeek += audit.total;
      }
    }
    // Calculer la moyenne en divisant la somme par le nombre d'ilots
    double average = totalForWeek / ilots.length;
    return Text(average.toStringAsFixed(2)); // Affichage de la moyenne avec deux décimales
  }

  Widget _buildAuditCell(String ilot, int week) {
    final auditForWeek = audits.firstWhere(
          (audit) => audit.ilot == ilot && _getWeekOfYear(audit.date) == week,
      orElse: () => Audit(key: '', ilot: '', date: DateTime(0), total: 0),
    );
    return Container(
      width: 60.0,
      child: Center(child: Text(auditForWeek.total != 0 ? '${auditForWeek.total}' : '')),
    );
  }

  Color _getIlotColor(Ilot ilot) {
    int hashCode = ilot.key.hashCode;
    Color color = Color((hashCode & 0xFFFFFF).toUnsigned(32) | 0xFF000000);
    return color;
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
}


  class Auditeur {
  late String key;
  String nom;
  String email;
  String service;
  late List<bool> checkedList;

  Auditeur({required this.key, required this.nom, required this.email, required this.service}) {
    checkedList = List.generate(52, (_) => false);
  }
}

class Ilot {
  late String key;
  String nom;
  String etat;

  Ilot({required this.key, required this.nom, required this.etat});
}

class Audit {
  late String key;
  String ilot;
  DateTime date;
  int total;

  Audit({required this.key, required this.ilot, required this.date, required this.total});
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: PlanningAnnuel(),
    debugShowCheckedModeBanner: false,
  ));
}
