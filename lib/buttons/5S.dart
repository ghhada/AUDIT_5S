import 'package:flutter/material.dart';
import '../audit/DebutAuditPage.dart';

class Button1Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Obtenir la taille de l'écran
    Size screenSize = MediaQuery.of(context).size;

    // Calculer la taille du bouton en fonction de la largeur de l'écran
    double buttonWidth = screenSize.width * 0.8; // 80% de la largeur de l'écran
    double buttonHeight = 60.0; // Hauteur du bouton

    return DebutAuditPage(
      buttonFontSize: 24.0,
      buttonTextPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
      labelTextSize: 24.0,
      containerPadding: EdgeInsets.all(20.0),
      containerBorderWidth: 2.0,
      dropdownIconSize: 30.0,
      dropdownItemFontSize: 24.0,
      //buttonWidth: buttonWidth, // Passer la largeur du bouton
      //buttonHeight: buttonHeight, // Passer la hauteur du bouton
    );
  }
}
