import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class Ilot {
  final String id;
  final String nom;

  Ilot({required this.id, required this.nom});
}

class SuiviIlotPage extends StatefulWidget {
  @override
  _SuiviIlotPageState createState() => _SuiviIlotPageState();
}

class _SuiviIlotPageState extends State<SuiviIlotPage> {
  String? selectedIlot;
  List<String> ilotsNoms = [];
  Map<String, String> ilotsServices = {};
  Map<String, Map<String, int>> ilotData = {};
  List<charts.Series<HistogramData, String>> seriesList = [];

  @override
  void initState() {
    super.initState();
    _getIlots();
  }

  void _getIlots() {
    final ilotsReference = FirebaseDatabase.instance.reference().child('ilots');
    ilotsReference.onChildAdded.listen((event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      if (values != null && values['nom'] != null && values['etat'] != null) {
        setState(() {
          ilotsNoms.add(values['nom']);
          ilotsServices[values['nom']] = values['etat'];
          ilotData[values['nom']] = {}; // Initialiser les données pour cet ilot
        });
      }
    }, onError: (error) {
      print('Erreur lors de la récupération des ilots : $error');
    });
  }

  Future<void> _calculateAuditCounts(String ilot) async {
    final auditsReference = FirebaseDatabase.instance.reference().child('audits');
    try {
      auditsReference.onValue.listen((event) {
        final snapshot = event.snapshot;
        if (snapshot.value != null) {
          final Map<dynamic, dynamic>? auditsMap = snapshot.value as Map<dynamic, dynamic>?;

          if (auditsMap != null) {
            final auditCounts = <String, int>{};
            final dateFormatter = DateFormat('d-M-yyyy');

            for (int i = 1; i <= 12; i++) {
              auditCounts[DateFormat('MMMM').format(DateTime(2022, i))] = 0;
            }

            auditsMap.forEach((key, value) {
              final audit = value as Map<dynamic, dynamic>;
              if (audit['ilot'] == ilot) {
                final date = dateFormatter.parse(audit['date']);
                final month = DateFormat('MMMM').format(date);
                auditCounts.update(month, (value) => value + 1, ifAbsent: () => 1);
              }
            });

            setState(() {
              ilotData[ilot] = Map.from(auditCounts);
              _updateChartData(ilot);
            });
          } else {
            print('No audit data available.');
          }
        } else {
          print('No audit data available.');
        }
      });
    } catch (error) {
      print('Error fetching audit data: $error');
    }
  }


  void _updateChartData(String ilot) {
    final data = ilotData[ilot]!.entries.map((entry) => HistogramData(entry.key, entry.value)).toList();
    setState(() {
      seriesList = [
        charts.Series<HistogramData, String>(
          id: 'Histogram',
          domainFn: (HistogramData data, _) => data.category,
          measureFn: (HistogramData data, _) => data.value.toDouble(),
          data: data,
        )..setAttribute(charts.rendererIdKey, 'customBarRenderer'), // Ajoutez cette ligne pour attribuer un identifiant au renderer
      ];
    });
  }

  void _navigateToNextPage(BuildContext context) {
    if (selectedIlot != null) {
      _calculateAuditCounts(selectedIlot!);
    } else {
      // Gérer le cas où aucun ilot n'est sélectionné
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Suivi des Ilots"),
      ),
      backgroundColor: Color(0xFF060D3A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown pour choisir l'ilot
            Container(
              padding: EdgeInsets.all(20.0),
              margin: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              decoration: BoxDecoration(
                color: Color(0xFFFFFFFF),
                border: Border.all(color: Colors.white, width: 1.0),
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
                  "Choisissez l'ilot",
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
                    _calculateAuditCounts(value!);
                  });
                },
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
                      padding: EdgeInsets.symmetric(vertical: 15, horizontal: 100),
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
            // Affichage de l'histogramme
            Container(
              height: 200,
              padding: EdgeInsets.all(20),
              child: charts.BarChart(
                seriesList,
                animate: true,
                barGroupingType: charts.BarGroupingType.grouped,
                defaultRenderer: charts.BarRendererConfig<String>(),
                customSeriesRenderers: [
                  charts.BarRendererConfig<String>(
                    customRendererId: 'customBarRenderer', // Utilisez l'identifiant personnalisé
                  ),
                ],
                domainAxis: charts.OrdinalAxisSpec(
                  renderSpec: charts.SmallTickRendererSpec(
                    labelStyle: charts.TextStyleSpec(
                      color: charts.MaterialPalette.white, // Couleur du texte des mois
                    ),
                  ),
                ),
                primaryMeasureAxis: charts.NumericAxisSpec(
                  renderSpec: charts.GridlineRendererSpec(
                    labelStyle: charts.TextStyleSpec(
                      color: charts.MaterialPalette.white, // Couleur du texte des nombres
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

// Classe pour les données de l'histogramme
class HistogramData {
  final String category;
  final int value;

  HistogramData(this.category, this.value);
}

void main() {
  runApp(MaterialApp(
    title: 'Navigation Example',
    home: SuiviIlotPage(),
  ));
}
