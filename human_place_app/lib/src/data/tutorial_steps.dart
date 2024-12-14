import 'package:human_place_app/src/screens/habit_screen.dart';
//import '../routes.dart';
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
    message: "Accede a tu perfil desde este botón, personaliza tu información y encuentra algo especial que alguien ha dejado listo para ti.",
    imagePath: 'assets/images/gato_sam.png',
    targetView: "home", // Identificador único de la vista
    targetKey: profilepageButtonKey,
    highlightWidget: true,
    position: CharacterPosition.bottom,
    characterName: "SAM",
    nameColor: Colors.blueGrey,
    wordsToHighlight: ['perfil', 'algo', 'especial','alguien']
  ),
  TutorialStep(
    message: "Al presionar este botón, se abrirá un menú desplegable donde podrás explorar y conectar con la biblioteca y el contenido disponible en la aplicación.",
    imagePath: 'assets/images/gato_sam.png',
    targetView: "home", // Identificador único de la vista
    targetKey: menuButtonKey,
    highlightWidget: true,
    position: CharacterPosition.bottom,
    characterName: "SAM",
    nameColor: Colors.blueGrey,
    wordsToHighlight: ['menú','biblioteca']
  ),
  TutorialStep(
    message: "En esta sección puedes plantar un hábito. Tendrás algunos amigos que te apoyarán en el cuidado de tu planta.",
    imagePath: 'assets/images/gato_sam.png',
    targetView: "home", // Identificador único de la vista
    targetKey: intentionButtonKey,
    highlightWidget: true,
    position: CharacterPosition.center,
    characterName: "SAM",
    nameColor: Colors.blueGrey,
    wordsToHighlight: ['plantar','un','hábito','amigos'],
    navigateTo: HabitScreen.routerName
  ),
  //HABIT SCREEN
  TutorialStep(
    message: "Este es tu Rincón Verde, donde podrás cuidar una planta relacionada a un hábito.",
    imagePath: 'assets/images/gato_sam.png',
    targetView: "habitscreen", // Identificador único de la vista
    //targetKey: habitSection,
    //highlightWidget: true,
    position: CharacterPosition.bottom,
    nameColor: Colors.blueGrey,
    characterName: "SAM",
    wordsToHighlight: ['Rincón', 'Verde', 'planta', 'hábito']
  ),
  TutorialStep(
    message: "Aquí debes escoger un hábito diario que desees practicar. \n También encontrarás un temporizador para ayudarte a practicar tu hábito.",
    imagePath: 'assets/images/gato_sam.png',
    targetView: "habitscreen", // Identificador único de la vista
    targetKey: habitSection,
    highlightWidget: true,
    position: CharacterPosition.bottom,
    nameColor: Colors.blueGrey,
    characterName: "SAM",
    wordsToHighlight: ['hábito','diario', 'temporizador']
  ),
  TutorialStep(
    message: "¡Hola! Mi nombre es Lyn, soy un huillín y estoy aquí para ayudarte con tu planta. \n Cada vez que presiones el botón 'Regar', regaremos tu planta con agua del río donde vivo. \n ¡Espero verte por aquí todos los días!",
    imagePath: 'assets/images/personajes/huillin.png',
    targetView: "habitscreen", // Identificador único de la vista
    targetKey: pourSection,
    highlightWidget: true,
    position: CharacterPosition.center,
    nameColor: Colors.blue,
    characterName: "Lyn",
    wordsToHighlight: ['huillín','Regar']
  ),
  TutorialStep(
    message: "¡Saludos! Soy Romi, un monito del monte. Te regalaré Semillas que encuentro en el bosque, y podrás convertirlas en Abono. Cada abono protege tu planta cuando no practicas un hábito en un día. \n ¡Ten cuidado de no quedarte sin ellos!",
    imagePath: 'assets/images/personajes/monito.png',
    targetView: "habitscreen", // Identificador único de la vista
    targetKey: seedsSection,
    highlightWidget: true,
    position: CharacterPosition.bottom,
    nameColor: Colors.green,
    characterName: "Romi",
    wordsToHighlight: ['monito', 'del','monte','Semillas','Abono','protege'],
  ),
  //PROFILE SCREEN
  TutorialStep(
    message: "¡Mucho gusto! Soy Aoni, un perro ovejero magallánico, y estaré contigo para impulsarte a cumplir tu meta de crear hábitos saludables.",
    imagePath: 'assets/images/personajes/ovejero.png',
    targetView: "profile",
    //targetKey: profileButtonKey,
    //highlightWidget: true,
    position: CharacterPosition.bottom,
    nameColor: Colors.deepOrange,
    characterName: "Aoni",
    wordsToHighlight: ['Aoni', 'ovejero','magallánico']
  ),
  TutorialStep(
    message: "Esta es tu pantalla de perfil. En la parte superior puedes elegir una imagen de perfil, personalizar tu nombre y definir los pronombres con los que te identificas.",
    imagePath: 'assets/images/personajes/ovejero.png',
    targetView: "profile",
    targetKey: profileButtonKey,
    highlightWidget: true,
    position: CharacterPosition.bottom,
    nameColor: Colors.deepOrange,
    characterName: "Aoni",
    wordsToHighlight: ['pantalla','de','perfil', 'imagen','nombre','pronombres']
  ),
  TutorialStep(
    message: "En la parte inferior encontrarás la sección de Medallas. Cada vez que acumules una cantidad determinada de días de crecimiento con cualquier planta, te otorgaré la medalla correspondiente.\n¡Colecciónalas todas!",
    imagePath: 'assets/images/personajes/ovejero.png',
    targetView: "profile",
    targetKey: medalSection,
    highlightWidget: true,
    position: CharacterPosition.center,
    nameColor: Colors.deepOrange,
    characterName: "Aoni",
    wordsToHighlight: ['Medallas', 'cantidad','determinada','días','cualquier','planta']
  ),
];
