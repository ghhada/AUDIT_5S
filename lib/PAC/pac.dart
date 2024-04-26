import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PACPage extends StatefulWidget {
  @override
  _PACPageState createState() => _PACPageState();
}

class _PACPageState extends State<PACPage> {
  final DatabaseReference _auditsRef = FirebaseDatabase.instance.reference().child('audits');
  List<Map<dynamic, dynamic>> items = [];
  Map<int, Map<int, bool>> actionStates = {};

  @override
  void initState() {
    super.initState();
    _auditsRef.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      setState(() {
        items.add({...values!, 'key': event.snapshot.key});
        if (items.length == 1) {
          _loadActionStates();
        }
      });
    });
  }

  void _loadActionStates() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < items.length; i++) {
      Map<int, bool> savedStates = {};
      for (int j = 0; j < items[i]['total']; j++) {
        String actionStateKey = 'etat_action${j + 1}';
        bool savedState = prefs.getBool('actionState_${items[i]['key']}_$actionStateKey') ?? false;
        savedStates[j] = savedState;
      }
      setState(() {
        actionStates[i] = savedStates;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double tableWidth = screenWidth - 350.0;

    return Scaffold(
      appBar: AppBar(
        title: Text('PAC'),
      ),
      body: items.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          child: DataTable(
            columnSpacing: 20,
            columns: [
              DataColumn(label: SizedBox(width: tableWidth * 0.07, child: Text('Numéro'))),
              DataColumn(label: SizedBox(width: tableWidth * 0.15, child: Text('Nom d\'auditeur'))),
              DataColumn(label: SizedBox(width: tableWidth * 0.15, child: Text('Ilots'))),
              DataColumn(label: SizedBox(width: tableWidth * 0.3, child: Text('Actions'))),
              DataColumn(label: SizedBox(width: tableWidth * 0.15, child: Text('Responsable'))),
              DataColumn(label: SizedBox(width: tableWidth * 0.15, child: Text('Date limite'))),
              DataColumn(label: SizedBox(width: tableWidth * 0.08, child: Text('État d\'action'))),
            ],
            rows: items
                .asMap()
                .entries
                .map(
                  (entry) {
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
                int maxRowCount = actions.length;
                for (int i = 0; i < maxRowCount; i++) {
                  bool actionDone = actionStates[index]?[i] ?? false;
                  rows.add(
                    DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(i == 0 ? Text(nomAuditeur) : SizedBox.shrink()),
                        DataCell(i == 0 ? Text(ilot) : SizedBox.shrink()),
                        DataCell(Text(actions.length > i ? actions[i] : 'N/A')),
                        DataCell(Text(responsables.length > i ? responsables[i] : 'N/A')),
                        DataCell(Text(datesLimites.length > i ? datesLimites[i] : 'N/A')),
                        DataCell(
                          Row(
                            children: [
                              Text(actionDone ? 'Done' : 'En cours', style: TextStyle(color: actionDone ? Colors.green : Colors.yellow)),
                              Switch(
                                value: actionDone,
                                activeColor: Colors.green,
                                inactiveTrackColor: Colors.yellow,
                                onChanged: (bool value) {
                                  setState(() {
                                    if (actionStates.containsKey(index)) {
                                      actionStates[index]![i] = value;
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
                      ],
                    ),
                  );
                }
                return rows;
              },
            )
                .expand((i) => i)
                .toList(),
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
      prefs.setBool('actionState_${items[index]['key']}_$actionStateKey', value);
    } catch (e) {
      print('Error updating action state: $e');
    }
  }
}
