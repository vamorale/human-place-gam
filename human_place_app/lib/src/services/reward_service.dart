import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/navigator_helpers.dart';

Future<void> otorgarSemillas(BuildContext context) async {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  if (userId == null) {
    throw Exception("Usuario no autenticado");
  }

  final userDoc = FirebaseFirestore.instance.collection('usuarios').doc(userId);
  final userSnapshot = await userDoc.get();

  if (userSnapshot.exists) {
    final data = userSnapshot.data();
    final DateTime hoy = DateTime.now();
    final DateTime ultimaFechaIngreso = data?['ultimaFechaIngreso']?.toDate() ?? DateTime(2000);

    final int semillasActuales = (data?['semillas'] ?? 0) as int;

    if (hoy.difference(ultimaFechaIngreso).inDays > 0) {
      final int nuevasSemillas = semillasActuales + 5;
      await userDoc.update({
        'semillas': nuevasSemillas, // Actualiza o inicializa el campo semillas
        'ultimaFechaIngreso': Timestamp.fromDate(hoy), // Actualiza la fecha de ingreso
      });

      // Mostrar pantalla de recompensa con imagen del premio
      showCustomScreen(
        context: context,
        imagePath: 'assets/images/personajes/monito.png',
        message: '¡Has ganado 5 semillas!',
        rewardImagePath: 'assets/images/planta/semilla.png', // Imagen del premio
        onActionCompleted: () {
          Navigator.of(context).pop();
        },
      );
    } else {
      print("El usuario ya recibió sus semillas hoy");
    }
  } else {
    // Si el documento no existe, lo creamos con los campos iniciales
    await userDoc.set({
      'semillas': 5,
      'ultimaFechaIngreso': Timestamp.fromDate(DateTime.now()),
    });

    // Mostrar pantalla de recompensa con imagen del premio
    showCustomScreen(
      context: context,
      imagePath: 'assets/images/personajes/monito.png',
      message: '¡Has ganado 5 semillas!',
      rewardImagePath: 'assets/images/planta/semilla.png',
      onActionCompleted: () {
        Navigator.of(context).pop();
      },
    );
  }
}
