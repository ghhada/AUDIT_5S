import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class Ilot {
  late String key;
  String nom;
  String etat;

  Ilot({required this.key, required this.nom, required this.etat});
}

class IlotsEtats extends StatefulWidget {
  @override
  _IlotsEtatsState createState() => _IlotsEtatsState();
}

class _IlotsEtatsState extends State<IlotsEtats> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Ilot> ilots = [];
  int enCoursCount = 0;
  int certifieCount = 0;
  int nonCertifieCount = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _getIlots();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
        });
      }
    }, onError: (error) {
      print('Error getting ilots: $error');
    });
  }

  void _supprimerIlot(Ilot ilotASupprimer) {
    final databaseReference = FirebaseDatabase.instance.reference().child('ilots');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Voulez-vous vraiment supprimer cet ilot ?"),
          actions: <Widget>[
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Supprimer"),
              onPressed: () {
                Navigator.of(context).pop();
                _confirmerSuppression(ilotASupprimer);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmerSuppression(Ilot ilotASupprimer) {
    final databaseReference = FirebaseDatabase.instance.reference().child('ilots');

    databaseReference.child(ilotASupprimer.key).remove().then((_) {
      setState(() {
        ilots.remove(ilotASupprimer);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ilot supprimé avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la suppression de l'ilot"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _modifierIlot(int index) {
    final ilotAModifier = ilots[index];

    TextEditingController nomController = TextEditingController(text: ilotAModifier.nom);
    TextEditingController etatController = TextEditingController(text: ilotAModifier.etat);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modifier l'ilot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Etat'),
                value: etatController.text.isNotEmpty ? etatController.text : null,
                items: <String>['certifié', 'en cours', 'non certifié']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                    .toList(),
                onChanged: (String? newValue) {
                  etatController.text = newValue!;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Enregistrer"),
              onPressed: () {
                String nom = nomController.text.trim();
                String etat = etatController.text.trim();

                if (nom.isNotEmpty && etat.isNotEmpty) {
                  ilotAModifier.nom = nom;
                  ilotAModifier.etat = etat;
                  _enregistrerModifications(ilotAModifier);
                  setState(() {}); // Rafraîchit l'interface utilisateur
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Veuillez remplir tous les champs"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _enregistrerModifications(Ilot ilot) {
    final databaseReference = FirebaseDatabase.instance.reference().child('ilots');
    databaseReference.child(ilot.key).set({
      'nom': ilot.nom,
      'etat': ilot.etat,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Modifications enregistrées avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'enregistrement des modifications"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _ajouterIlot() {
    TextEditingController nomController = TextEditingController();
    TextEditingController etatController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ajouter un ilot"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Etat'),
                value: etatController.text.isNotEmpty ? etatController.text : null,
                items: <String>['certifié', 'en cours', 'non certifié']
                    .map<DropdownMenuItem<String>>(
                      (String value) => DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  ),
                )
                    .toList(),
                onChanged: (String? newValue) {
                  etatController.text = newValue!;
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Annuler"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Ajouter"),
              onPressed: () {
                String nom = nomController.text.trim();
                String etat = etatController.text.trim();

                if (nom.isNotEmpty && etat.isNotEmpty) {
                  _enregistrerNouvelIlot(nom, etat);
                  setState(() {}); // Rafraîchit l'interface utilisateur
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Veuillez remplir tous les champs"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _enregistrerNouvelIlot(String nom, String etat) {
    final databaseReference = FirebaseDatabase.instance.reference().child('ilots');
    databaseReference.push().set({
      'nom': nom,
      'etat': etat,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nouvel ilot ajouté avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'ajout du nouvel ilot"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Etats des Ilots'),
      ),
      body: _buildListPage(),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterIlot,
        tooltip: 'Ajouter un ilot',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget _buildListPage() {
    return Expanded(
      child: ListView.builder(
        itemCount: ilots.length,
        itemBuilder: (context, index) {
          final ilot = ilots[index];
          return IlotCard(
            ilot: ilot,
            onDelete: () {
              _supprimerIlot(ilot); // Passer l'objet Ilot à supprimer
            },
            onEdit: () {
              _modifierIlot(index);
            },
          );
        },
      ),
    );
  }
}

class IlotCard extends StatelessWidget {
  final Ilot ilot;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const IlotCard({
    required this.ilot,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (ilot.etat) {
      case 'certifié':
        color = Colors.lightGreen[100]!;
        break;
      case 'en cours':
        color = Colors.yellow[100]!;
        break;
      case 'non certifié':
        color = Colors.red[100]!;
        break;
      default:
        color = Colors.grey[200]!;
        break;
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      color: color,
      child: ListTile(
        title: Text(
          'Nom: ${ilot.nom}',
          style: TextStyle(color: Colors.black),
        ),
        subtitle: Text(
          'Etat: ${ilot.etat}',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.black87.withOpacity(0.8),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit),
              color: Colors.black,
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete),
              color: Colors.black,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    home: IlotsEtats(),
  ));
}
