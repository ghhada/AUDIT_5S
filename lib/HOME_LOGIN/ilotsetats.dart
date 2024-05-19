import 'package:flutter/material.dart';
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

class _IlotsEtatsState extends State<IlotsEtats> {
  List<Ilot> ilots = [];

  @override
  void initState() {
    super.initState();
    _getIlots();
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

  void _supprimerIlot(String key) {
    final databaseReference = FirebaseDatabase.instance.reference().child('ilots');

    databaseReference.child(key).remove().then((_) {
      setState(() {
        ilots.removeWhere((ilot) => ilot.key == key);
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

  void _modifierIlot(String key, String nouveauNom, String nouvelEtat) {
    final databaseReference = FirebaseDatabase.instance.reference().child('ilots');
    databaseReference.child(key).update({
      'nom': nouveauNom,
      'etat': nouvelEtat,
    }).then((_) {
      // Mettre à jour l'état local des îlots
      setState(() {
        final ilotIndex = ilots.indexWhere((ilot) => ilot.key == key);
        if (ilotIndex != -1) {
          ilots[ilotIndex].nom = nouveauNom;
          ilots[ilotIndex].etat = nouvelEtat;
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Ilot modifié avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la modification de l'ilot"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('États des Ilots'),
      ),
      body: ListView.builder(
        itemCount: ilots.length,
        itemBuilder: (context, index) {
          final ilot = ilots[index];
          return IlotCard(
            ilot: ilot,
            onUpdate: (etat) => _modifierIlot(ilot.key, ilot.nom, etat), // Utiliser le nom actuel de l'îlot
            onDelete: () => _supprimerIlot(ilot.key),
            onEdit: () => _modifierIlotDialog(context, ilot), // Utiliser une boîte de dialogue pour la modification
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterIlot,
        tooltip: 'Ajouter un ilot',
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Color(0xFF060D3A),
    );
  }

  void _ajouterIlot() {
    TextEditingController _nomController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ajouter un nouvel îlot'),
          content: TextField(
            controller: _nomController,
            decoration: InputDecoration(
              labelText: 'Nom de l\'îlot',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                String nouveauNom = _nomController.text.trim();
                if (nouveauNom.isNotEmpty) {
                  final databaseReference = FirebaseDatabase.instance.reference().child('ilots');
                  String nouvelEtat = 'non certifié';

                  databaseReference.push().set({
                    'nom': nouveauNom,
                    'etat': nouvelEtat,
                  }).then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Nouvel îlot ajouté avec succès"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(context).pop();
                  }).catchError((error) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Erreur lors de l'ajout de l'îlot"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Veuillez saisir le nom de l'îlot"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  void _modifierIlotDialog(BuildContext context, Ilot ilot) {
    TextEditingController _nomController = TextEditingController(text: ilot.nom);
    String _selectedEtat = ilot.etat;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Modifier l\'îlot'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(
                  labelText: 'Nouveau nom de l\'îlot',
                ),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedEtat,
                onChanged: (newValue) {
                  setState(() {
                    _selectedEtat = newValue!;
                  });
                },
                items: <String>['certifié', 'en cours', 'non certifié'].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                String nouveauNom = _nomController.text.trim();
                if (nouveauNom.isNotEmpty) {
                  _modifierIlot(ilot.key, nouveauNom, _selectedEtat);
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Veuillez saisir le nouveau nom de l'îlot"),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              child: Text('Enregistrer'),
            ),
          ],
        );
      },
    );
  }
}

class IlotCard extends StatefulWidget {
  final Ilot ilot;
  final Function(String) onUpdate;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const IlotCard({
    required this.ilot,
    required this.onUpdate,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _IlotCardState createState() => _IlotCardState();
}

class _IlotCardState extends State<IlotCard> {
  late String selectedEtat;

  @override
  void initState() {
    super.initState();
    selectedEtat = widget.ilot.etat;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      color: Color(0xFF232D61),
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Nom d\'îlot: ${widget.ilot.nom}',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, fontFamily: 'Roboto', color: Colors.white),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: widget.onEdit,
                      color: Colors.orange,
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline),
                      onPressed: widget.onDelete,
                      color: Colors.red,
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children: [
                ChoiceChip(
                  label: Text('Certifié'),
                  selected: selectedEtat == 'certifié',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() => selectedEtat = 'certifié');
                      widget.onUpdate('certifié');
                    }
                  },
                  selectedColor: Colors.green,
                ),
                ChoiceChip(
                  label: Text('En cours'),
                  selected: selectedEtat == 'en cours',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() => selectedEtat = 'en cours');
                      widget.onUpdate('en cours');
                    }
                  },
                  selectedColor: Colors.orange,
                ),
                ChoiceChip(
                  label: Text('Non certifié'),
                  selected: selectedEtat == 'non certifié',
                  onSelected: (bool selected) {
                    if (selected) {
                      setState(() => selectedEtat = 'non certifié');
                      widget.onUpdate('non certifié');
                    }
                  },
                  selectedColor: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


void main() {
  runApp(MaterialApp(
    home: IlotsEtats(),
  ));
}
