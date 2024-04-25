import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:fl_chart/fl_chart.dart' as fl;

class Ilot {
  late String key;
  String nom;
  String etat;

  Ilot({required this.key, required this.nom, required this.etat});
}

enum ChartType {
  BarChart,
  PieChart,
}

class AllDataPage extends StatefulWidget {
  @override
  _AllDataPageState createState() => _AllDataPageState();
}

class _AllDataPageState extends State<AllDataPage> {
  List<Ilot> ilots = [];
  int enCoursCount = 0;
  int certifieCount = 0;
  int nonCertifieCount = 0;
  int totalIlots = 0;
  double enCoursPercentage = 0.0;
  double certifiePercentage = 0.0;
  double nonCertifiePercentage = 0.0;

  ChartType _selectedChartType = ChartType.BarChart;

  @override
  void initState() {
    super.initState();
    _getIlots();
  }

  Future<void> _getIlots() async {
    final databaseReference = FirebaseDatabase.instance.reference().child('ilots');
    databaseReference.onValue.listen((event) {
      if (event.snapshot.value != null) {
        Map<dynamic, dynamic> values = event.snapshot.value as Map<dynamic, dynamic>;
        setState(() {
          ilots.clear();
          enCoursCount = 0;
          certifieCount = 0;
          nonCertifieCount = 0;
          totalIlots = 0;
          values.forEach((key, value) {
            final ilot = Ilot(
              key: key,
              nom: value['nom'] ?? '',
              etat: value['etat'] ?? '',
            );
            ilots.add(ilot);
            // Compter les catégories
            if (ilot.etat == 'en cours') {
              enCoursCount++;
            } else if (ilot.etat == 'certifié') {
              certifieCount++;
            } else if (ilot.etat == 'non certifié') {
              nonCertifieCount++;
            }
          });
          totalIlots = ilots.length;
          enCoursPercentage = (enCoursCount / totalIlots) * 100;
          certifiePercentage = (certifieCount / totalIlots) * 100;
          nonCertifiePercentage = (nonCertifieCount / totalIlots) * 100;
        });
      }
    }, onError: (error) {
      print('Error getting ilots: $error');
    });
  }

  List<charts.Series<Ilot, String>> _createDataChartsFlutter() {
    final data = [
      Ilot(key: 'Certifié', nom: '', etat: certifieCount.toString()),
      Ilot(key: 'En cours', nom: '', etat: enCoursCount.toString()),
      Ilot(key: 'Non certifié', nom: '', etat: nonCertifieCount.toString()),
    ];

    return [
      charts.Series<Ilot, String>(
        id: 'Ilots',
        data: data,
        domainFn: (Ilot ilot, _) => ilot.key,
        measureFn: (Ilot ilot, _) => int.parse(ilot.etat),
        colorFn: (Ilot ilot, _) {
          switch (ilot.key) {
            case 'Certifié':
              return charts.ColorUtil.fromDartColor(Colors.lightGreen[100]!);
            case 'En cours':
              return charts.ColorUtil.fromDartColor(Colors.yellow[100]!);
            case 'Non certifié':
              return charts.ColorUtil.fromDartColor(Colors.red[100]!);
            default:
              return charts.ColorUtil.fromDartColor(Colors.lightGreen[100]!);
          }
        },
        labelAccessorFn: (Ilot ilot, _) => '${ilot.key}: ${ilot.etat}',
        // Définir le BarLabelDecorator avec le labelStyle blanc
        insideLabelStyleAccessorFn: (Ilot ilot, _) {
          final color = charts.ColorUtil.fromDartColor(Colors.white);
          return charts.TextStyleSpec(color: color);
        },
      ),
    ];

  }

  List<fl.PieChartSectionData> _createDataFLChart() {
    return [
      fl.PieChartSectionData(
        color: Colors.lightGreen.shade200,
        value: certifiePercentage,
        title: '${certifiePercentage.toStringAsFixed(2)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      fl.PieChartSectionData(
        color: Colors.yellow.shade200,
        value: enCoursPercentage,
        title: '${enCoursPercentage.toStringAsFixed(2)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
      fl.PieChartSectionData(
        color: Colors.red.shade200,
        value: nonCertifiePercentage,
        title: '${nonCertifiePercentage.toStringAsFixed(2)}%',
        radius: 50,
        titleStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    ];
  }

  Widget _buildChartWidget() {
    if (ilots.isEmpty) {
      // If the list of ilots is empty, display a message or an empty placeholder
      return Center(
        child: Text(
          'No data available',
          style: TextStyle(fontSize: 16.0, color: Colors.white), // Texte en blanc
        ),
      );
    } else {
      return Expanded(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: SizedBox(
                height: 300, // Hauteur du BarChart
                child: charts.BarChart(
                  _createDataChartsFlutter(),
                  animate: true,
                  barGroupingType: charts.BarGroupingType.grouped, // Ajuster la largeur de la barre
                  // Définir le BarLabelDecorator pour afficher les étiquettes à l'extérieur des barres
                  barRendererDecorator: charts.BarLabelDecorator<String>(
                    labelPosition: charts.BarLabelPosition.outside,
                    labelAnchor: charts.BarLabelAnchor.end,
                    outsideLabelStyleSpec: charts.TextStyleSpec(
                      fontSize: 12,
                      color: charts.ColorUtil.fromDartColor(Colors.white), // Texte en blanc
                    ),
                  ),
                  domainAxis: charts.OrdinalAxisSpec(
                    renderSpec: charts.SmallTickRendererSpec(
                      // Style des étiquettes de l'axe des domaines
                      labelStyle: charts.TextStyleSpec(
                        fontSize: 14,
                        color: charts.ColorUtil.fromDartColor(Colors.white), // Texte en blanc
                      ),
                      // Style des lignes de la grille
                      lineStyle: charts.LineStyleSpec(
                        color: charts.ColorUtil.fromDartColor(Colors.white.withOpacity(0.5)), // Couleur de la ligne de grille
                      ),
                    ),
                  ),
                  primaryMeasureAxis: charts.NumericAxisSpec(
                    renderSpec: charts.GridlineRendererSpec(
                      // Style des nombres sur l'axe des ordonnées
                      labelStyle: charts.TextStyleSpec(
                        fontSize: 14,
                        color: charts.ColorUtil.fromDartColor(Colors.white), // Texte en blanc
                      ),
                      // Style des lignes de la grille
                      lineStyle: charts.LineStyleSpec(
                        color: charts.ColorUtil.fromDartColor(Colors.white.withOpacity(0.5)), // Couleur de la ligne de grille
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 300, // Hauteur du PieChart
                child: Stack(
                  children: [
                    AspectRatio(
                      aspectRatio: 1.0,
                      child: fl.PieChart(
                        fl.PieChartData(
                          sections: _createDataFLChart(),
                          borderData: fl.FlBorderData(show: false),
                          centerSpaceRadius: 40,
                          sectionsSpace: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }


  Widget _buildChartLabel(String label, double percentage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Texte en blanc
          ),
        ),
        Text(
          '${percentage.toStringAsFixed(2)}%',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white, // Texte en blanc
          ),
        ),
      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Graphiques des Ilots'),
      ),
      body: ilots.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Container(
        color: Color(0xFF060D3A),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Graphiques des Ilots',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 20),
              _buildChartWidget(),
            ],
          ),
        ),
      ),
    );
  }



}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    home: AllDataPage(),
  ));
}
