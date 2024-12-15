import 'package:flutter/material.dart';
import '../services/firestore_planta.dart'; // Ajusta según la ubicación de FirestoreService
import '../screens/character_screen.dart'; // Para usar CharacterScreen

void mostrarConversionModal(
  BuildContext context,
  int semillas,
  int protectores,
  String userId,
) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('Convertir Semillas'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/planta/semilla.png', height: 50), // Imagen de semilla
            Text('Semillas disponibles: $semillas'),
            SizedBox(height: 10),
            Image.asset('assets/images/planta/abono.png', height: 50), // Imagen de abono
            Text('Protectores disponibles: $protectores'),
            SizedBox(height: 20),
            Text('¿Convertir 10 semillas en 1 saco de abono?'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Cerrar el modal
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Realizar la conversión
              final firestoreService = FirestoreService();
              final ConversionResult resultado = await firestoreService.convertirSemillasAProtectores(userId);

              Navigator.pop(dialogContext); // Cerrar el modal
              // Mostrar la CharacterScreen con el resultado
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CharacterScreen(
                    imagePath: 'assets/images/personajes/monito.png', // Imagen del personaje
                    text: resultado.message,
                    onActionCompleted: () {
                      Navigator.pop(context); // Volver a la pantalla anterior
                    },
                    rewardImagePath: resultado.success ? 'assets/images/planta/abono.png' : null,
                  ),
                ),
              );
            },
            child: Text('Aceptar'),
          ),
        ],
      );
    },
  );
}
