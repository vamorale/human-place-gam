import 'package:flutter/material.dart';

enum CharacterPosition {
  bottom, // Posición predeterminada (parte inferior)
  center, // Posición en el centro de la pantalla
}

class TutorialStep {
  final String message;      // Mensaje del tutorial
  final String imagePath;    // Ruta de la imagen del personaje
  final String targetView;   // Identificador de la vista
  final GlobalKey? targetKey; // Clave para identificar el widget a destacar
  final bool highlightWidget; // Indica si se debe destacar el widget
  final CharacterPosition position;
  final String? characterName;
  final Color? nameColor;
  final List<String>? wordsToHighlight;

  TutorialStep({
    required this.message,
    required this.imagePath,
    required this.targetView,
    this.targetKey,
    this.highlightWidget = false,
    this.position = CharacterPosition.bottom,
    this.characterName,
    this.nameColor,
    this.wordsToHighlight
  });
}
