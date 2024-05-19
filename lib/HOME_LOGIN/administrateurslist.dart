import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdministrateursList extends StatefulWidget {
  @override
  _AdministrateursListState createState() => _AdministrateursListState();
}

class _AdministrateursListState extends State<AdministrateursList> {
  User? _currentUser; // Utilisez un objet User pour stocker l'utilisateur actuel

  @override
  void initState() {
    super.initState();
    _loadCurrentUser(); // Chargez l'utilisateur actuel au démarrage du widget
  }

  Future<void> _loadCurrentUser() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;
      setState(() {
        _currentUser = currentUser;
      });
    } catch (e) {
      print("Error loading current user: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Informations sur l\'administrateur'),
      ),
      body: _currentUser == null
          ? Center(
        child: CircularProgressIndicator(), // Affichez une icône de chargement si l'utilisateur est nul
      )
          : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: Text('Nom: ${_currentUser!.displayName ?? "Non disponible"}'),
            subtitle: Text('Email: ${_currentUser!.email ?? "Non disponible"}'),
          ),
          ListTile(
            title: Text('UID: ${_currentUser!.uid}'),
            subtitle: Text('Téléphone: ${_currentUser!.phoneNumber ?? "Non disponible"}'),
          ),
          // Ajoutez d'autres détails de l'utilisateur si nécessaire
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: AdministrateursList(),
  ));
}
