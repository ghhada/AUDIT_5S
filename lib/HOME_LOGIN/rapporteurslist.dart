import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Rapporteur {
  late String key;
  String nom;
  String email;
  String domaine;

  Rapporteur({required this.key, required this.nom, required this.email, required this.domaine});
}

class RapporteursList extends StatefulWidget {
  @override
  _RapporteursListState createState() => _RapporteursListState();
}

class _RapporteursListState extends State<RapporteursList> {
  List<Rapporteur> rapporteurs = [];

  @override
  void initState() {
    super.initState();
    _getRapporteurs();
  }

  void _getRapporteurs() {
    final databaseReference = FirebaseDatabase.instance.reference().child('rapporteurs');
    databaseReference.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        final rapporteur = Rapporteur(
          key: event.snapshot.key!,
          nom: values['nom'] ?? '',
          email: values['email'] ?? '',
          domaine: values['domaine'] ?? '',
        );
        setState(() {
          rapporteurs.add(rapporteur);
        });
      }
    });
  }

  void _supprimerRapporteur(int index) {
    final rapporteurASupprimer = rapporteurs[index];
    final databaseReference = FirebaseDatabase.instance.reference().child('rapporteurs');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Voulez-vous vraiment supprimer ce rapporteur ?"),
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
                _confirmerSuppression(index);
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmerSuppression(int index) {
    final rapporteurASupprimer = rapporteurs[index];
    final databaseReference = FirebaseDatabase.instance.reference().child('rapporteurs');

    databaseReference.child(rapporteurASupprimer.key).remove().then((_) {
      setState(() {
        rapporteurs.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Rapporteur supprimé avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la suppression du rapporteur"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _modifierRapporteur(int index) {
    final rapporteurAModifier = rapporteurs[index];

    TextEditingController nomController = TextEditingController(text: rapporteurAModifier.nom);
    TextEditingController emailController = TextEditingController(text: rapporteurAModifier.email);
    TextEditingController domaineController = TextEditingController(text: rapporteurAModifier.domaine);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modifier le rapporteur"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: domaineController,
                decoration: InputDecoration(labelText: 'Domaine'),
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
                String email = emailController.text.trim();
                String domaine = domaineController.text.trim();

                if (nom.isNotEmpty && email.isNotEmpty && domaine.isNotEmpty) {
                  rapporteurAModifier.nom = nom;
                  rapporteurAModifier.email = email;
                  rapporteurAModifier.domaine = domaine;
                  _enregistrerModifications(rapporteurAModifier);
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

  void _enregistrerModifications(Rapporteur rapporteur) {
    final databaseReference = FirebaseDatabase.instance.reference().child('rapporteurs');
    databaseReference.child(rapporteur.key).set({
      'nom': rapporteur.nom,
      'email': rapporteur.email,
      'domaine': rapporteur.domaine,
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

  void _ajouterRapporteur() {
    TextEditingController nomController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController domaineController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ajouter un rapporteur"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: nomController,
                decoration: InputDecoration(labelText: 'Nom'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: domaineController,
                decoration: InputDecoration(labelText: 'Domaine'),
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
                String email = emailController.text.trim();
                String domaine = domaineController.text.trim();

                if (nom.isNotEmpty && email.isNotEmpty && domaine.isNotEmpty) {
                  _enregistrerNouveauRapporteur(nom, email, domaine);
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

  void _enregistrerNouveauRapporteur(String nom, String email, String domaine) {
    final databaseReference = FirebaseDatabase.instance.reference().child('rapporteurs');
    databaseReference.push().set({
      'nom': nom,
      'email': email,
      'domaine': domaine,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nouveau rapporteur ajouté avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'ajout du nouveau rapporteur"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des Rapporteurs'),
      ),
      body: ListView.builder(
        itemCount: rapporteurs.length,
        itemBuilder: (context, index) {
          final rapporteur = rapporteurs[index];
          return RapporteurCard(
            rapporteur: rapporteur,
            onDelete: () {
              _supprimerRapporteur(index);
            },
            onEdit: () {
              _modifierRapporteur(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterRapporteur,
        tooltip: 'Ajouter un rapporteur',
        child: Icon(Icons.add),
        backgroundColor: Colors.orange, // Modifier la couleur du bouton flottant en orange
      ),
      backgroundColor: Color(0xFF060D3A), // Modifier la couleur de l'arrière-plan
    );
  }
}

class RapporteurCard extends StatelessWidget {
  final Rapporteur rapporteur;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const RapporteurCard({
    required this.rapporteur,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    switch (rapporteur.domaine) {
      case 'Domaine 1':
        color = Colors.lightBlue[100]!;
        textColor = Colors.black;
        break;
      case 'Domaine 2':
        color = Colors.lightGreen[100]!;
        textColor = Colors.black;
        break;
      case 'Domaine 3':
        color = Colors.orange[100]!;
        textColor = Colors.black;
        break;
      default:
        color = Colors.grey[200]!;
        textColor = Colors.black;
        break;
    }

    return Card(
      elevation: 4,
      margin: EdgeInsets.all(8),
      color: color,
      child: ListTile(
        title: Text(
          'Nom: ${rapporteur.nom}',
          style: TextStyle(color: textColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: ${rapporteur.email}',
              style: TextStyle(color: textColor),
            ),
            Text(
              'Service: ${rapporteur.domaine}',
              style: TextStyle(
                color: textColor.withOpacity(0.8),
              ),
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange), // Modifier icône en orange
              onPressed: onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.orange), // Supprimer icône en orange
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: RapporteursList(),
  ));
}
