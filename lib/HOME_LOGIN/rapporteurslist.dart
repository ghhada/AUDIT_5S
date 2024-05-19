import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Rapporteur {
  late String key;
  String nom;
  String email;
  String domaine;
  String motDePasse;

  Rapporteur({required this.key, required this.nom, required this.email, required this.domaine, required this.motDePasse});
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
          motDePasse: values['motDePasse'] ?? '',
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
    TextEditingController motDePasseController = TextEditingController(text: rapporteurAModifier.motDePasse);
    bool _passwordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                  TextField(
                    controller: motDePasseController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
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
                    String motDePasse = motDePasseController.text.trim();

                    if (nom.isNotEmpty && email.isNotEmpty && domaine.isNotEmpty) {
                      rapporteurAModifier.nom = nom;
                      rapporteurAModifier.email = email;
                      rapporteurAModifier.domaine = domaine;
                      rapporteurAModifier.motDePasse = motDePasse;
                      _enregistrerModifications(rapporteurAModifier, index);

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
      },
    );
  }

  void _enregistrerModifications(Rapporteur rapporteur, int index) {
    final databaseReference = FirebaseDatabase.instance.reference().child('rapporteurs');
    databaseReference.child(rapporteur.key).update({
      'nom': rapporteur.nom,
      'email': rapporteur.email,
      'domaine': rapporteur.domaine,
      'motDePasse': rapporteur.motDePasse, // Mettre à jour le mot de passe dans la base de données
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Modifications enregistrées avec succès"),
          backgroundColor: Colors.green,
        ),
      );

      // Mise à jour de la liste des rapporteurs une fois les modifications enregistrées
      setState(() {
        rapporteurs[index] = rapporteur;
      });
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
    TextEditingController motDePasseController = TextEditingController();
    bool _passwordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
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
                  TextField(
                    controller: motDePasseController,
                    obscureText: !_passwordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(_passwordVisible ? Icons.visibility : Icons.visibility_off),
                        onPressed: () {
                          setState(() {
                            _passwordVisible = !_passwordVisible;
                          });
                        },
                      ),
                    ),
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
                    String motDePasse = motDePasseController.text.trim();

                    if (nom.isNotEmpty && email.isNotEmpty && domaine.isNotEmpty) {
                      _enregistrerNouveauRapporteur(nom, email, domaine, motDePasse);
                      setState(() {});
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
      },
    );
  }

  void _enregistrerNouveauRapporteur(String nom, String email, String domaine, String motDePasse) {
    final databaseReference = FirebaseDatabase.instance.reference().child('rapporteurs');
    databaseReference.push().set({
      'nom': nom,
      'email': email,
      'domaine': domaine,
      'motDePasse': motDePasse,
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
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Color(0xFF060D3A),
    );
  }
}

class RapporteurCard extends StatefulWidget {
  final Rapporteur rapporteur;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const RapporteurCard({
    required this.rapporteur,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  _RapporteurCardState createState() => _RapporteurCardState();
}

class _RapporteurCardState extends State<RapporteurCard> {
  bool _passwordVisible = false;

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    switch (widget.rapporteur.domaine) {
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
          'Nom: ${widget.rapporteur.nom}',
          style: TextStyle(color: textColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: ${widget.rapporteur.email}',
              style: TextStyle(color: textColor),
            ),
            Text(
              'Service: ${widget.rapporteur.domaine}',
              style: TextStyle(
                color: textColor.withOpacity(0.8),
              ),
            ),
            Row(
              children: [
                Text(
                  'Mot de passe: ${_passwordVisible ? widget.rapporteur.motDePasse : '********'}',
                  style: TextStyle(color: textColor),
                ),
                IconButton(
                  icon: Icon(_passwordVisible ? Icons.visibility_off : Icons.visibility),
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Colors.orange),
              onPressed: widget.onEdit,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.orange),
              onPressed: widget.onDelete,
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
