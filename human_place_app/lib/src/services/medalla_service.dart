import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../screens/character_screen.dart';

class MedallaService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> verificarDesbloqueoMedalla(
    BuildContext context,
    String userId,
    int growthDays,
  ) async {
    // IDs de las medallas según los días necesarios
    final Map<String, int> medallas = {
      '1': 1,
      '3': 3,
      '5': 5,
      '7': 7,
    };

    for (var entry in medallas.entries) {
      String medallaId = entry.key;
      int diasRequeridos = entry.value;

      if (growthDays == diasRequeridos) {
        // Desbloquear la medalla
        await desbloquearMedalla(userId, medallaId);

        // Mostrar la CharacterScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CharacterScreen(
              imagePath: 'assets/images/badge-ovejero/medalla_$medallaId.png', // Imagen de la medalla
              text:
                  '¡Has desbloqueado la medalla de $diasRequeridos días y ganado 5 semillas!',
              onActionCompleted: () {
                Navigator.pop(context); // Volver a la pantalla anterior
              },
              rewardImagePath: 'assets/images/planta/semilla.png', // Imagen de las semillas
            ),
          ),
        );
      }
    }
  }

  Future<void> desbloquearMedalla(String userId, String medallaId) async {
  try {
    final medallaDoc = _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('medallas')
        .doc(medallaId);

    final usuarioDoc = _firestore.collection('usuarios').doc(userId);

    // Obtener el documento de la medalla
    final medallaSnapshot = await medallaDoc.get();
    if (!medallaSnapshot.exists) {
      print("La medalla con ID $medallaId no existe.");
      return;
    }

    // Verificar si la medalla ya fue alcanzada
    final medallaData = medallaSnapshot.data() as Map<String, dynamic>;
    if (medallaData['alcanzada'] == true) {
      print("La medalla ya fue alcanzada.");
      return;
    }

    // Actualizar la medalla como alcanzada
    await medallaDoc.update({
      'alcanzada': true,
      'fecha': FieldValue.serverTimestamp(),
    });

    print("Medalla $medallaId desbloqueada.");

    // Incrementar las semillas del usuario (excepto para la medalla del día 1)
    if (medallaId != '1') {
      final usuarioSnapshot = await usuarioDoc.get();
      if (usuarioSnapshot.exists) {
        final usuarioData = usuarioSnapshot.data() as Map<String, dynamic>;
        int semillas = usuarioData['semillas'] ?? 0;

        semillas += 5; // Añadir 5 semillas

        // Actualizar las semillas en Firebase
        await usuarioDoc.update({'semillas': semillas});

        print("Se han añadido 5 semillas.");
      }
    } else {
      print("La medalla del día 1 no otorga semillas.");
    }
  } catch (e) {
    print("Error al desbloquear la medalla: $e");
  }
}
}
