import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class PACPage extends StatefulWidget {
  @override
  _PACPageState createState() => _PACPageState();
}

class _PACPageState extends State<PACPage> {
  final DatabaseReference _auditsRef = FirebaseDatabase.instance.reference().child('audits');
  List<Map<dynamic, dynamic>> items = [];

  @override
  void initState() {
    super.initState();
    _loadData();
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
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
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
                List<bool> actionStates = [];
                for (String key in item.keys) {
                  if (key.startsWith('action')) {
                    actions.add(item[key].toString().split(': ')[1]);
                    String actionKey = key; // Action key
                    bool actionDone = item['${actionKey}Done'] == 'Done'; // Get action state
                    actionStates.add(actionDone);
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
                  rows.add(
                    DataRow(
                      cells: [
                        DataCell(Text((index + 1).toString())),
                        DataCell(i == 0 ? Text(nomAuditeur) : SizedBox.shrink()),
                        DataCell(i == 0 ? Text(ilot) : SizedBox.shrink()),
                        DataCell(Text(actions[i])),
                        DataCell(Text(responsables.length > i ? responsables[i] : 'N/A')),
                        DataCell(Text(datesLimites.length > i ? datesLimites[i] : 'N/A')),
                        DataCell(
                          Row(
                            children: [
                              Text(actionStates[i] ? 'Done' : 'En cours',
                                  style: TextStyle(
                                      color: actionStates[i] ? Colors.green : Colors.yellow)),
                              Switch(
                                value: actionStates[i],
                                activeColor: Colors.green,
                                inactiveTrackColor: Colors.yellow,
                                onChanged: (bool value) {
                                  _updateActionState(index, 'action${i + 1}', value ? 'Done' : 'En cours');
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

  void _updateActionState(int itemIndex, String actionKey, String newState) {
    if (itemIndex < items.length) {
      _auditsRef.child(itemIndex.toString()).update({'$actionKey': newState}).then((_) {
        setState(() {
          items[itemIndex]['${actionKey}Done'] = newState;
        });
      });
    }
  }


  void _loadData() {
    _auditsRef.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        setState(() {
          items.add(values);
        });
      }
    });
  }

  String _extractDate(String dateTimeString) {
    return dateTimeString.split(': ')[1].split('T')[0];
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: PACPage(),
  ));
}
