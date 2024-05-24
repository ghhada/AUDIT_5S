import 'package:emailjs/emailjs.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

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

  Future<List<String>> getEmails() async {
    List<String> emailList = [];
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('rapporteurs');

    DatabaseEvent event = await ref.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        emailList.add(value['email']);
      });
    }

    return emailList; // Retourner la liste des emails
  }

  Future<bool> sendEmail() async {
    List<String> emailList = await getEmails();
    try {
      for (String email in emailList) {
        await EmailJS.send(
          'service_ebsbi4h',
          'template_qq3cocf',
          {
            'user_email': email,
            'user_message': 'un nouveau rapporteur crée',
          },
          const Options(
            publicKey: 'ff5kQ9thcCqQ5cQeE',
            privateKey: 'PFPpaNq5ROgw575fq5Kb9',
          ),
        );
      }
      print('SUCCESS!');
      return true;
    } catch (error) {
      if (error is EmailJSResponseStatus) {
        print('ERROR... ${error.status}: ${error.text}');
      }
      print(error.toString());
      return false;
    }
  }
  Future<List<String>> getEmails1() async {
    List<String> emailList = [];
    DatabaseReference ref = FirebaseDatabase.instance.ref().child('rapporteurs');

    DatabaseEvent event = await ref.once();
    DataSnapshot snapshot = event.snapshot;

    if (snapshot.value != null) {
      Map<dynamic, dynamic> values = snapshot.value as Map<dynamic, dynamic>;
      values.forEach((key, value) {
        emailList.add(value['email']);
      });
    }

    return emailList; // Retourner la liste des emails
  }

  Future<bool> sendEmail1(String email,String newPassword) async {
    try {
      await EmailJS.send(
        'service_ebsbi4h',
        'template_qq3cocf',
        {
          'user_email': email,
          'user_message': 'Votre mot de passe est changé. Nouveau mot de passe : $newPassword',
        },
        const Options(
          publicKey: 'ff5kQ9thcCqQ5cQeE',
          privateKey: 'PFPpaNq5ROgw575fq5Kb9',
        ),
      );
      print('SUCCESS!');
      return true;
    } catch (error) {
      if (error is EmailJSResponseStatus) {
        print('ERROR... ${error.status}: ${error.text}');
      }
      print(error.toString());
      return false;
    }
  }

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



  Future<void> _forgotPassword(BuildContext context) async {
    TextEditingController emailController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
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
                controller: newPasswordController,
                decoration: InputDecoration(labelText: 'Nouveau mot de passe'),
                obscureText: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String email = emailController.text;
                String newPassword = newPasswordController.text;

                try {
                  // Envoyer l'e-mail de réinitialisation (facultatif, peut être ignoré si inutile)
                  await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Email de réinitialisation envoyé à $email'),
                    ),
                  );

                  // Rechercher l'utilisateur dans la base de données
                  DatabaseReference ref = FirebaseDatabase.instance.ref().child('rapporteurs');
                  DatabaseEvent event = await ref.once();
                  DataSnapshot snapshot = event.snapshot;

                  if (snapshot.value != null) {
                    Map<dynamic, dynamic> rapporteurs = snapshot.value as Map<dynamic, dynamic>;
                    String? userIdToUpdate;

                    rapporteurs.forEach((key, value) {
                      if (value['email'] == email) {
                        userIdToUpdate = key;
                      }
                    });

                    if (userIdToUpdate != null) {
                      // Mettre à jour le mot de passe dans la base de données Firebase Realtime
                      await ref.child(userIdToUpdate!).update({'motDePasse': newPassword});
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Mot de passe mis à jour dans la base de données'),
                        ),
                      );

                      // Envoyer un e-mail de confirmation
                      bool emailSent = await sendEmail1(email,newPassword);
                      if (emailSent) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Email de confirmation envoyé'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Erreur lors de l\'envoi de l\'email de confirmation'),
                          ),
                        );
                      }
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Utilisateur non trouvé dans la base de données'),
                        ),
                      );
                    }
                  }
                } catch (error) {
                  print("Erreur lors de l'envoi de l'e-mail de réinitialisation : $error");
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Erreur lors de l'envoi de l'e-mail de réinitialisation"),
                    ),
                  );
                }

                Navigator.of(context).pop(); // Fermer la boîte de dialogue
              },
              child: Text('Envoyer'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Annuler l'action et fermer la boîte de dialogue
              },
              child: Text('Annuler'),
            ),
          ],
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

                    Navigator.of(context).pop();
                    sendEmail();
                  },
                  child: Text('Enregistrer'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
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
                          onPressed: () {
                            // Code pour créer un compte
                            _createAccount();
                          },
                          child: Text('Créer un compte', style: TextStyle(color: Colors.orange)),
                        ),
                        TextButton(
                          onPressed: () {
                            _forgotPassword(context);
                          },
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
