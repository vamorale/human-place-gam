import '../models/tutorial_step.dart';
import '../screens/main_page.dart'; // Importa las claves definidas en las vistas
import '../screens/profile_screen.dart'; // Más vistas si es necesario
import 'package:flutter/material.dart';

final List<TutorialStep> tutorialSteps = [
  TutorialStep(
    message: "¡Te damos la bienvenida a Human Place! \n Soy SAM, tu asistente virtual y estoy aquí para guiarte dentro de la aplicación.",
    imagePath: 'assets/images/gato_sam.png',
    targetView: "home", // Identificador único de la vista
    targetKey: null,
    highlightWidget: false,
    position: CharacterPosition.bottom,
    wordsToHighlight: ['asistente','virtual']
  ),
  TutorialStep(
    message: "En el paisaje detrás de mí puedes acceder a distintas herramientas. \n En algunas secciones podrás acceder a nuestro chat, donde estaré disponible para conversar contigo y brindarte la ayuda que necesites. \n ¡Te invito a explorarlas!",
    imagePath: 'assets/images/gato_sam.png',
    targetView: "home", // Identificador único de la vista
    targetKey: mainButtonsKey,
    highlightWidget: true,
    position: CharacterPosition.bottom,
    characterName: "SAM",
    nameColor: Colors.blueGrey,
    wordsToHighlight: ['herramientas','chat']
  ),
  TutorialStep(
    message: "En esta sección puedes plantar un hábito. Tendrás algunos amigos que te apoyarán en el cuidado de tu planta.",
    imagePath: 'assets/images/gato_sam.png',
    targetView: "home", // Identificador único de la vista
    targetKey: intentionButtonKey,
    highlightWidget: true,
    position: CharacterPosition.bottom,
    characterName: "SAM",
    nameColor: Colors.blueGrey,
    wordsToHighlight: ['herramientas','chat']
  ),
  TutorialStep(
    message: "Este es un botón importante en la pantalla de inicio.",
    imagePath: 'assets/images/personajes/huillin.png',
    targetView: "home", // Identificador único de la vista
    targetKey: profilepageButtonKey,
    highlightWidget: true,
    position: CharacterPosition.bottom,
    nameColor: Colors.blue,
    characterName: "Lyn",
    wordsToHighlight: ['importante']
  ),
  TutorialStep(
    message: "Este es un botón importante en la pantalla de inicio.",
    imagePath: 'assets/images/personajes/huillin.png',
    targetView: "home", // Identificador único de la vista
    targetKey: menuButtonKey,
    highlightWidget: true,
    position: CharacterPosition.bottom
  ),
  
  TutorialStep(
    message: "Este es un botón importante en la pantalla de inicio.",
    imagePath: 'assets/images/personajes/huillin.png',
    targetView: "home", // Identificador único de la vista
    targetKey: intentionButtonKey,
    highlightWidget: true,
    position: CharacterPosition.center
  ),
  TutorialStep(
    message: "Configura tu perfil aquí.",
    imagePath: 'assets/images/personajes/huillin.png',
    targetView: "profile",
    targetKey: profileButtonKey,
    highlightWidget: true,
    position: CharacterPosition.bottom
  ),
];
