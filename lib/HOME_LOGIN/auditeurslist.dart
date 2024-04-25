import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class Auditeur {
  late String key;
  String nom;
  String email;
  String service;

  Auditeur({required this.key, required this.nom, required this.email, required this.service});
}

class AuditeursListWidget extends StatefulWidget {
  @override
  _AuditeursListWidgetState createState() => _AuditeursListWidgetState();
}

class _AuditeursListWidgetState extends State<AuditeursListWidget> {
  List<Auditeur> auditeurs = [];

  @override
  void initState() {
    super.initState();
    _getAuditeurs();
  }

  void _getAuditeurs() {
    final databaseReference = FirebaseDatabase.instance.reference().child('auditeurs');
    databaseReference.onChildAdded.listen((event) {
      Map<dynamic, dynamic>? values = event.snapshot.value as Map?;
      if (values != null) {
        final auditeur = Auditeur(
          key: event.snapshot.key!,
          nom: values['nom'] ?? '',
          email: values['email'] ?? '',
          service: values['service'] ?? '',
        );
        setState(() {
          auditeurs.add(auditeur);
        });
      }
    });
  }

  void _supprimerAuditeur(int index) {
    final auditeurASupprimer = auditeurs[index];
    final databaseReference = FirebaseDatabase.instance.reference().child('auditeurs');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmation"),
          content: Text("Voulez-vous vraiment supprimer cet auditeur ?"),
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
    final auditeurASupprimer = auditeurs[index];
    final databaseReference = FirebaseDatabase.instance.reference().child('auditeurs');

    databaseReference.child(auditeurASupprimer.key).remove().then((_) {
      setState(() {
        auditeurs.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Auditeur supprimé avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de la suppression de l'auditeur"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  void _modifierAuditeur(int index) {
    final auditeurAModifier = auditeurs[index];

    TextEditingController nomController = TextEditingController(text: auditeurAModifier.nom);
    TextEditingController emailController = TextEditingController(text: auditeurAModifier.email);
    TextEditingController serviceController = TextEditingController(text: auditeurAModifier.service);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Modifier l'auditeur"),
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
                controller: serviceController,
                decoration: InputDecoration(labelText: 'Service'),
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
                String service = serviceController.text.trim();

                if (nom.isNotEmpty && email.isNotEmpty && service.isNotEmpty) {
                  auditeurAModifier.nom = nom;
                  auditeurAModifier.email = email;
                  auditeurAModifier.service = service;
                  _enregistrerModifications(auditeurAModifier);
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

  void _enregistrerModifications(Auditeur auditeur) {
    final databaseReference = FirebaseDatabase.instance.reference().child('auditeurs');
    databaseReference.child(auditeur.key).set({
      'nom': auditeur.nom,
      'email': auditeur.email,
      'service': auditeur.service,
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

  void _ajouterAuditeur() {
    TextEditingController nomController = TextEditingController();
    TextEditingController emailController = TextEditingController();
    TextEditingController serviceController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Ajouter un auditeur"),
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
                controller: serviceController,
                decoration: InputDecoration(labelText: 'Service'),
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
                String service = serviceController.text.trim();

                if (nom.isNotEmpty && email.isNotEmpty && service.isNotEmpty) {
                  _enregistrerNouvelAuditeur(nom, email, service);
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

  void _enregistrerNouvelAuditeur(String nom, String email, String service) {
    final databaseReference = FirebaseDatabase.instance.reference().child('auditeurs');
    databaseReference.push().set({
      'nom': nom,
      'email': email,
      'service': service,
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Nouvel auditeur ajouté avec succès"),
          backgroundColor: Colors.green,
        ),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur lors de l'ajout du nouvel auditeur"),
          backgroundColor: Colors.red,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des auditeurs'),
      ),
      body: ListView.builder(
        itemCount: auditeurs.length,
        itemBuilder: (context, index) {
          final auditeur = auditeurs[index];
          return AuditeurCard(
            auditeur: auditeur,
            onDelete: () {
              _supprimerAuditeur(index);
            },
            onEdit: () {
              _modifierAuditeur(index);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _ajouterAuditeur,
        tooltip: 'Ajouter un auditeur',
        child: Icon(Icons.add),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: Color(0xFF060D3A),
    );
  }
}

class AuditeurCard extends StatelessWidget {
  final Auditeur auditeur;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const AuditeurCard({
    required this.auditeur,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    Color color;
    Color textColor;
    switch (auditeur.service) {
      case 'Service 1':
        color = Colors.lightBlue[100]!;
        textColor = Colors.black;
        break;
      case 'Service 2':
        color = Colors.lightGreen[100]!;
        textColor = Colors.black;
        break;
      case 'Service 3':
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
          'Nom: ${auditeur.nom}',
          style: TextStyle(color: textColor),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Email: ${auditeur.email}',
              style: TextStyle(color: textColor),
            ),
            Text(
              'Service: ${auditeur.service}',
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
    home: AuditeursListWidget(),
  ));
}
