import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';

class Auditeur {
  final String id;
  final String nom;

  Auditeur({required this.id, required this.nom});
}

class DebutAuditPage extends StatefulWidget {
  @override
  _DebutAuditPageState createState() => _DebutAuditPageState();
}

class _DebutAuditPageState extends State<DebutAuditPage> {
  String? selectedAuditeur;
  List<String> auditeursNoms = [];
  Map<String, String> auditeursServices = {};
  Map<String, Map<String, int>> auditeurData = {};
  List<charts.Series<HistogramData, String>> seriesList = [];

  @override
  void initState() {
    super.initState();
    _getAuditeurs();
  }

  void _getAudits() {
    final auditsReference = FirebaseDatabase.instance.reference().child('audits');
    auditsReference.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? audits = snapshot.value as Map<dynamic, dynamic>?;
      if (audits != null) {
        audits.forEach((key, value) {
          print('Audit key: $key, value: $value');
          // Traitez les données de l'audit ici selon vos besoins
        });
      }
    }).catchError((error) {
      print('Erreur lors de la récupération des audits : $error');
    });
  }

  void _getAuditeurs() {
    final auditeursReference = FirebaseDatabase.instance.reference().child('auditeurs');
    auditeursReference.onChildAdded.listen((event) {
      // Ici, event est de type DatabaseEvent
      DataSnapshot snapshot = event.snapshot;
      Map<dynamic, dynamic>? values = snapshot.value as Map?;
      if (values != null && values['nom'] != null && values['service'] != null) {
        setState(() {
          auditeursNoms.add(values['nom']);
          auditeursServices[values['nom']] = values['service'];
          auditeurData[values['nom']] = {}; // Initialiser les données pour cet auditeur
        });
      }
    });
  }

  void _calculateAuditCounts() {
    final auditsReference = FirebaseDatabase.instance.reference().child('audits');
    auditsReference.once().then((DatabaseEvent event) {
      DataSnapshot snapshot = event.snapshot;
      final audits = snapshot.value as Map<dynamic, dynamic>?;
      if (audits != null) {
        auditeursNoms.forEach((auditeur) {
          final auditeurAudits = audits.values.where((audit) => audit['nomAuditeur'] == auditeur);
          final auditCounts = <String, int>{};

          // Initialiser les compteurs pour chaque mois à 0
          auditCounts['January'] = 0;
          auditCounts['February'] = 0;
          auditCounts['March'] = 0;
          auditCounts['April'] = 0;
          auditCounts['May'] = 0;
          auditCounts['June'] = 0;
          auditCounts['July'] = 0;
          auditCounts['August'] = 0;
          auditCounts['September'] = 0;
          auditCounts['October'] = 0;
          auditCounts['November'] = 0;
          auditCounts['December'] = 0;

          // Compter le nombre d'audits pour chaque mois
          auditeurAudits.forEach((audit) {
            final date = DateFormat('d-M-yyyy').parse(audit['date']);
            final month = DateFormat('MMMM').format(date);
            auditCounts.update(month, (value) => value + 1, ifAbsent: () => 1);
          });

          // Mettre à jour les données de l'auditeur avec le nombre d'audits pour chaque mois
          setState(() {
            auditeurData[auditeur] = Map.from(auditCounts);
          });
        });

        // Mettre à jour les données de l'histogramme
        _updateChartData(selectedAuditeur ?? auditeursNoms.first);
      }
    }).catchError((error) {
      print('Erreur lors de la récupération des audits : $error');
    });
  }

  void _updateChartData(String auditeur) {
    final data = auditeurData[auditeur]!.entries.map((entry) => HistogramData(entry.key, entry.value)).toList();
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
    if (selectedAuditeur != null) {
      _calculateAuditCounts();
    } else {
      // Gérer le cas où aucun auditeur n'est sélectionné
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Histogramme"),
      ),
      backgroundColor: Color(0xFF060D3A),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Dropdown pour choisir l'auditeur
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
                  "Choisissez l'auditeur",
                  style: TextStyle(fontSize: 18.0),
                ),
                value: selectedAuditeur,
                items: auditeursNoms.map((String nom) {
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
                    selectedAuditeur = value;
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
    home: DebutAuditPage(),
  ));
}
