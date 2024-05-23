import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

import '../HOME_LOGIN/homelogin.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool passwordVisible = false;
  final databaseReference = FirebaseDatabase.instance.reference();

  Future<void> _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    DataSnapshot snapshot = await databaseReference.child('rapporteurs').get();
    bool userFound = false;

    if (snapshot.exists) {
      Map<dynamic, dynamic> rapporteurs = snapshot.value as Map<dynamic, dynamic>;
      rapporteurs.forEach((key, value) {
        if (value['email'] == email && value['motDePasse'] == password) {
          userFound = true;
        }
      });
    }

    if (userFound) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeLogin()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Email ou mot de passe incorrect'),
        ),
      );
    }
  }

  Future<void> _forgotPassword() async {
    TextEditingController forgotPasswordController = TextEditingController();
    bool forgotPasswordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Mot de passe oublié"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: forgotPasswordController,
                    obscureText: !forgotPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Nouveau mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(
                          forgotPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            forgotPasswordVisible = !forgotPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    // Récupérer les informations entrées par l'utilisateur
                    String email = emailController.text;
                    String newPassword = forgotPasswordController.text;

                    // Vérifier si les informations sont correctes dans la base de données
                    DataSnapshot snapshot = await databaseReference.child('rapporteurs').get();
                    bool userFound = false;

                    if (snapshot.exists) {
                      Map<dynamic, dynamic> rapporteurs = snapshot.value as Map<dynamic, dynamic>;
                      rapporteurs.forEach((key, value) {
                        if (value['email'] == email) {
                          userFound = true;
                          // Mettre à jour le mot de passe dans la base de données
                          databaseReference.child('rapporteurs').child(key).update({'motDePasse': newPassword});
                        }
                      });
                    }

                    if (userFound) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mot de passe mis à jour avec succès'),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Email incorrect'),
                        ),
                      );
                    }

                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },
                  child: Text('Enregistrer'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },
                  child: Text('Annuler'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _createAccount() async {
    TextEditingController createEmailController = TextEditingController();
    TextEditingController createPasswordController = TextEditingController();
    TextEditingController nameController = TextEditingController();
    TextEditingController domainController = TextEditingController();
    bool createAccountPasswordVisible = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Créer un compte"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: 'Nom'),
                  ),
                  TextField(
                    controller: createEmailController,
                    decoration: InputDecoration(labelText: 'Email'),
                  ),
                  TextField(
                    controller: createPasswordController,
                    obscureText: !createAccountPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      suffixIcon: IconButton(
                        icon: Icon(
                          createAccountPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () {
                          setState(() {
                            createAccountPasswordVisible = !createAccountPasswordVisible;
                          });
                        },
                      ),
                    ),
                  ),
                  TextField(
                    controller: domainController,
                    decoration: InputDecoration(labelText: 'Service'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    String name = nameController.text;
                    String email = createEmailController.text;
                    String password = createPasswordController.text;
                    String domain = domainController.text;

                    // Ajouter l'utilisateur à la base de données
                    databaseReference.child('rapporteurs').push().set({
                      'nom': name,
                      'email': email,
                      'motDePasse': password,
                      'domaine': domain
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Compte créé avec succès'),
                      ),
                    );

                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },
                  child: Text('Enregistrer'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer la boîte de dialogue
                  },
                  child: Text('Annuler'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        color: Color(0xFF060D3A),
        child: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.8,
            child: Card(
              elevation: 8.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email, color: Colors.orange),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    TextField(
                      controller: passwordController,
                      obscureText: !passwordVisible,
                      decoration: InputDecoration(
                        labelText: 'Mot de passe',
                        prefixIcon: Icon(Icons.lock, color: Colors.orange),
                        suffixIcon: IconButton(
                          icon: Icon(
                            passwordVisible ? Icons.visibility : Icons.visibility_off,
                            color: Colors.orange,
                          ),
                          onPressed: () {
                            setState(() {
                              passwordVisible = !passwordVisible;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: _createAccount,
                          child: Text('Créer un compte', style: TextStyle(color: Colors.orange)),
                        ),
                        TextButton(
                          onPressed: _forgotPassword,
                          child: Text('Mot de passe oublié?', style: TextStyle(color: Colors.orange)),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0),
                    ElevatedButton(
                      onPressed: _login,
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.orange),
                      ),
                      child: Text('Se connecter', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
