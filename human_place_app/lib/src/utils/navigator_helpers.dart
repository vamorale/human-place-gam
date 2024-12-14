import 'package:flutter/material.dart';
import '../screens/character_screen.dart';

void showCustomScreen({
  required BuildContext context,
  required String imagePath,
  required String message,
  required VoidCallback onActionCompleted,
  String? rewardImagePath, // Imagen opcional del premio
}) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (context) => CharacterScreen(
        imagePath: imagePath,
        text: message,
        onActionCompleted: onActionCompleted,
        rewardImagePath: rewardImagePath, // Pasa la imagen del premio
      ),
    ),
  );
}
