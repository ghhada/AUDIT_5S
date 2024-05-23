import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PACPage extends StatefulWidget {
  @override
  _PACPageState createState() => _PACPageState();
}

class _PACPageState extends State<PACPage> {
  final DatabaseReference _auditsRef =
  FirebaseDatabase.instance.reference().child('audits');
  List<Map<dynamic, dynamic>> items = [];
  Map<int, Map<int, bool>> actionStates = {};

  @override
  void initState() {
    super.initState();
    _auditsRef.onChildAdded.listen((event) {
      setState(() {
        Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
        items.add({...values!, 'key': event.snapshot.key});
        _loadActionStates(event);
      });
    });
  }

  void _loadActionStates(DatabaseEvent event) {
    DataSnapshot dataSnapshot = event.snapshot;
    Map<dynamic, dynamic>? values = dataSnapshot.value as Map?;
    String auditKey = dataSnapshot.key as String;
    if (values != null) {
      Map<int, bool> savedStates = {};
      for (int j = 0; j < values['total']; j++) {
        String actionStateKey = 'etat_action${j + 1}';
        bool savedState = values[actionStateKey] == 'Done';
        savedStates[j] = savedState;
      }
      setState(() {
        actionStates[items.indexWhere((item) => item['key'] == auditKey)] =
            savedStates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PAC'),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: SingleChildScrollView(
          child: DataTable(
            columnSpacing: 20,
            headingRowColor: MaterialStateColor.resolveWith((states) => Colors.orange),
            columns: [
              DataColumn(label: Text('Numéro')),
              DataColumn(label: Text('Nom d\'auditeur')),
              DataColumn(label: Text('Ilots')),
              DataColumn(label: Text('Actions')),
              DataColumn(label: Text('Responsable')),
              DataColumn(label: Text('Date limite')),
              DataColumn(label: Text('État d\'action')),
              DataColumn(label: Text('Supprimer')),
            ],
            rows: items.asMap().entries.map((entry) {
              int index = entry.key;
              Map<dynamic, dynamic> item = entry.value;
              List<DataRow> rows = [];
              String nomAuditeur = item['nomAuditeur'].toString();
              String ilot = item['ilot'].toString();
              List<String> actions = [];
              List<String> responsables = [];
              List<String> datesLimites = [];
              for (String key in item.keys) {
                if (key.startsWith('action')) {
                  actions.add(item[key].toString().split(': ')[1]);
                }
                if (key.startsWith('responsable')) {
                  responsables.add(item[key].toString().split(': ')[1]);
                }
                if (key.startsWith('dateLimite')) {
                  datesLimites.add(_extractDate(item[key].toString()));
                }
              }
              int maxRowCount = [
                actions.length,
                responsables.length,
                datesLimites.length
              ].reduce((value, element) => value > element ? value : element);
              for (int i = 0; i < maxRowCount; i++) {
                List<DataCell> cells = [
                  DataCell(Text((index + 1).toString())),
                  DataCell(i == 0 ? Text(nomAuditeur) : SizedBox.shrink()),
                  DataCell(i == 0 ? Text(ilot) : SizedBox.shrink()),
                ];
                if (actions.length > i) {
                  cells.add(DataCell(Text(actions[i])));
                } else {
                  cells.add(DataCell(Text('N/A')));
                }
                if (responsables.length > i) {
                  cells.add(DataCell(Text(responsables[i])));
                } else {
                  cells.add(DataCell(Text('N/A')));
                }
                if (datesLimites.length > i) {
                  cells.add(DataCell(Text(datesLimites[i])));
                } else {
                  cells.add(DataCell(Text('N/A')));
                }
                bool actionDone = actionStates[index]?[i] ?? false;
                cells.add(
                  DataCell(
                    Row(
                      children: [
                        Text(
                          actionDone ? 'Done' : 'En cours',
                          style: TextStyle(
                            color: actionDone ? Colors.green : Colors.yellow,
                          ),
                        ),
                        Switch(
                          value: actionDone,
                          activeColor: Colors.green,
                          inactiveTrackColor: Colors.yellow,
                          onChanged: (bool value) {
                            setState(() {
                              if (actionStates.containsKey(index)) {
                                actionStates[index]?[i] = value;
                              } else {
                                actionStates[index] = {i: value};
                              }
                              updateActionState(index, i, value);
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
                cells.add(
                  DataCell(
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _deleteAction(index, i);
                      },
                    ),
                  ),
                );
                rows.add(DataRow(cells: cells));
              }
              return rows;
            }).expand((i) => i).toList(),
          ),
        ),
      ),
    );
  }

  String _extractDate(String dateTimeString) {
    return dateTimeString.split(': ')[1].split('T')[0];
  }

  void updateActionState(int index, int actionIndex, bool value) async {
    String actionStateKey = 'etat_action${actionIndex + 1}';
    String auditKey = items[index]['key'];
    String auditPath = '$auditKey';
    try {
      await _auditsRef.child(auditPath).update({actionStateKey: value ? 'Done' : 'En cours'});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setBool('actionState_${auditKey}_$actionStateKey', value);
    } catch (e) {
      print('Error updating action state: $e');
    }
  }

  void _deleteAction(int index, int actionIndex) async {
    String auditKey = items[index]['key'];
    String actionKey = 'action${actionIndex + 1}';
    String responsableKey = 'responsable${actionIndex + 1}';
    String dateLimiteKey = 'dateLimite${actionIndex + 1}';
    String actionStateKey = 'etat_action${actionIndex + 1}';

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove('actionState_${auditKey}_$actionStateKey');

      await _auditsRef.child(auditKey).update({
        actionKey: null,
        responsableKey: null,
        dateLimiteKey: null,
        actionStateKey: null,
      });

      setState(() {
        items[index].remove(actionKey);
        items[index].remove(responsableKey);
        items[index].remove(dateLimiteKey);
        actionStates[index]?.remove(actionIndex);
      });
    } catch (e) {
      print('Error deleting action: $e');
    }
  }
}
