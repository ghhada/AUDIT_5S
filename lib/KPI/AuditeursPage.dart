import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart' as fl;

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
  int totalAudits = 0;


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

          // Récupérer le mois actuel
          final currentMonth = DateFormat('MMMM').format(DateTime.now());

          // Compter le nombre d'audits pour chaque mois jusqu'à ce mois
          auditeurAudits.forEach((audit) {
            final date = DateFormat('d-M-yyyy').parse(audit['date']);
            final month = DateFormat('MMMM').format(date);
            if (DateFormat('yyyy').format(date) == DateFormat('yyyy').format(DateTime.now())) {
              auditCounts.update(month, (value) => value + 1, ifAbsent: () => 1);
            }

          });

          // Mettre à jour les données de l'auditeur avec le nombre d'audits pour chaque mois
          setState(() {
            auditeurData[auditeur] = Map.from(auditCounts);
          });
        });

        // Calculer le nombre total d'audits par an jusqu'à ce mois
        totalAudits = auditeurData[selectedAuditeur!]!.values.reduce((value, element) => value + element);

        // Mettre à jour les données de l'histogramme
        _updateChartData(selectedAuditeur!);
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
        title: const Text("KPI à propos les auditeurs"),
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
                  onTap:() {
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
            // Affichage du Pie Chart et du nombre total d'audits

            // Ajouter ce code après l'affichage du BarChart
// Affichage de la première PieChart
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Nombre total d\'audits par an : $totalAudits',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      SizedBox(
                        height: 200, // Définir une hauteur fixe pour le PieChart
                        child: fl.PieChart(
                          fl.PieChartData(
                            sectionsSpace: 0,
                            sections: totalAudits > 0 ? [
                              fl.PieChartSectionData(
                                value: (totalAudits / 11) * 100, // Audits soldés
                                color: Colors.green,
                                radius: 50,
                                title: '${((totalAudits / 11) * 100).toStringAsFixed(2)}%', // Affichage du pourcentage
                                titleStyle: TextStyle(color: Colors.white), // Couleur du texte des pourcentages
                              ),
                              fl.PieChartSectionData(
                                value: ((totalAudits - (totalAudits / 11)) / totalAudits) * 100, // Audits non soldés
                                color: Colors.red,
                                radius: 50,
                                title: '${(((totalAudits - (totalAudits / 11)) / totalAudits) * 100).toStringAsFixed(2)}%', // Affichage du pourcentage
                                titleStyle: TextStyle(color: Colors.white), // Couleur du texte des pourcentages
                              ),
                            ] : [
                              fl.PieChartSectionData(
                                value: 100, // En cas de zéro audits
                                color: Colors.grey,
                                radius: 50,
                                title: '0%', // Affichage du pourcentage
                                titleStyle: TextStyle(color: Colors.white), // Couleur du texte des pourcentages
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  color: Colors.green,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Audits soldés',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  color: Colors.red,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Audits non soldés',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

// Affichage de la deuxième PieChart
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Pourcentage d\'audits par rapport au ${DateFormat('MMMM').format(DateTime.now())}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 20),
                  Stack(
                    children: [
                      SizedBox(
                        height: 200, // Définir une hauteur fixe pour le PieChart
                        child: fl.PieChart(
                          fl.PieChartData(
                            sectionsSpace: 0,
                            sections: totalAudits > 0 ? [
                              fl.PieChartSectionData(
                                value: (totalAudits / DateTime.now().month) * 100, // Pourcentage par rapport au mois actuel
                                color: Colors.blue,
                                radius: 50,
                                title: '${((totalAudits / DateTime.now().month) * 100).toStringAsFixed(2)}%', // Affichage du pourcentage
                                titleStyle: TextStyle(color: Colors.white), // Couleur du texte des pourcentages
                              ),
                              fl.PieChartSectionData(
                                value: (100 - (totalAudits / DateTime.now().month) * 100), // Reste du pourcentage
                                color: Colors.grey,
                                radius: 50,
                                title: '${(100 - (totalAudits / DateTime.now().month) * 100).toStringAsFixed(2)}%', // Affichage du pourcentage
                                titleStyle: TextStyle(color: Colors.white), // Couleur du texte des pourcentages
                              ),
                            ] : [
                              fl.PieChartSectionData(
                                value: 100, // En cas de zéro audits
                                color: Colors.grey,
                                radius: 50,
                                title: '0%', // Affichage du pourcentage
                                titleStyle: TextStyle(color: Colors.white), // Couleur du texte des pourcentages
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 0,
                        top: 0,
                        bottom: 0,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  color: Colors.blue,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Audits du ${DateFormat('MMMM').format(DateTime.now())}', // Affichage dynamique du nom du mois actuel
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  height: 10,
                                  width: 10,
                                  color: Colors.grey,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Autres mois',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
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

