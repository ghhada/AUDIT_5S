import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class PACPage extends StatefulWidget {
  @override
  _PACPageState createState() => _PACPageState();
}

class _PACPageState extends State<PACPage> {
  final DatabaseReference _auditsRef = FirebaseDatabase.instance.reference().child('audits');
  List<Map<dynamic, dynamic>> items = [];
  Map<int, bool> actionStates = {}; // Map pour stocker l'état de chaque action par index

  @override
  void initState() {
    super.initState();
    _auditsRef.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      setState(() {
        items.add(values!);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double tableWidth = screenWidth - 350.0; // Réduire la largeur du tableau

    return Scaffold(
      appBar: AppBar(
        title: Text('PAC'),
      ),
      body: items.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0), // Ajouter un padding à gauche et à droite du tableau
          child: DataTable(
            columnSpacing: 20, // Ajout d'un espacement entre les colonnes
            columns: [
              DataColumn(label: SizedBox(width: tableWidth * 0.07, child: Text('Numéro'))), // 7% de la largeur du tableau
              DataColumn(label: SizedBox(width: tableWidth * 0.15, child: Text('Nom d\'auditeur'))), // 15% de la largeur du tableau
              DataColumn(label: SizedBox(width: tableWidth * 0.15, child: Text('Ilots'))), // 15% de la largeur du tableau
              DataColumn(label: SizedBox(width: tableWidth * 0.3, child: Text('Actions'))), // 30% de la largeur du tableau
              DataColumn(label: SizedBox(width: tableWidth * 0.15, child: Text('Responsable'))), // 15% de la largeur du tableau
              DataColumn(label: SizedBox(width: tableWidth * 0.15, child: Text('Date limite'))), // 15% de la largeur du tableau
              DataColumn(label: SizedBox(width: tableWidth * 0.08, child: Text('État d\'action'))), // 8% de la largeur du tableau
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
                  bool actionDone = actionStates[index * 100 + i] ?? false; // Récupérer l'état de l'action à partir de la Map
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
                              Text(actionDone ? 'Done' : 'En cours', style: TextStyle(color: actionDone ? Colors.green : Colors.yellow)), // Affichage de l'état de l'action avec couleur conditionnelle
                              Switch(
                                value: actionDone,
                                activeColor: Colors.green, // Couleur de l'interrupteur lorsqu'il est "Done"
                                inactiveTrackColor: Colors.yellow, // Couleur de la piste lorsque l'interrupteur est "En cours"
                                onChanged: (bool value) {
                                  setState(() {
                                    actionStates[index * 100 + i] = value; // Mise à jour de l'état de l'action dans la Map
                                    // Ici, vous pouvez mettre à jour l'état dans la base de données si nécessaire
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
}