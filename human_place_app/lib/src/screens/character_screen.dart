import 'package:flutter/material.dart';

class CharacterScreen extends StatelessWidget {
  final String imagePath;
  final String text;
  final VoidCallback onActionCompleted;

  const CharacterScreen({
    Key? key,
    required this.imagePath,
    required this.text,
    required this.onActionCompleted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.5), // Fondo traslúcido negro
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 150, height: 150), // Imagen del personaje
            const SizedBox(height: 20),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white, // Texto en blanco
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onActionCompleted,
              child: const Text('Continuar'),
            ),
          ],
        ),
      ),
    );
  }
}
