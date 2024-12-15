import 'package:flutter/material.dart';
import '../services/firestore_planta.dart'; // Ajusta según tu estructura
import '../screens/character_screen.dart'; // Para mostrar la recompensa
import '../services/medalla_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void mostrarConfirmacionRiegoModal(
  BuildContext context,
  String userId,
  String? plantId,
) {
  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        title: Text('Confirmar Hábito'),
        content: Text(
            '¿Has practicado tu hábito hoy? Al confirmar, regarás tu planta.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext); // Cerrar el modal
            },
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Cerrar el modal

              try {
                // Instanciar el servicio Firestore
                final firestoreService = FirestoreService();

                // Verificar que el plantId no sea nulo
                if (plantId != null) {
                  // Actualizar los datos de crecimiento y registrar el riego
                  await firestoreService.updatePlantGrowthData(userId, plantId);
                  await firestoreService.registrarRiego(userId);

                  // Verificar desbloqueo de medallas
                  final medallaService = MedallaService();
                  final docRef = FirebaseFirestore.instance
                      .collection('usuarios')
                      .doc(userId)
                      .collection('plant_growth')
                      .doc(plantId);

                  // Obtener los días de crecimiento actualizados
                  final docSnapshot = await docRef.get();
                  if (docSnapshot.exists) {
                    final data = docSnapshot.data() as Map<String, dynamic>;
                    int growthDays = data['mayorDiasLogrados'] ?? 0;

                    // Verificar medallas basadas en los días de crecimiento
                    await medallaService.verificarDesbloqueoMedalla(
                        context, userId, growthDays);
                  }

                   print('Navegando a CharacterScreen');

                  // Mostrar la pantalla de recompensa
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CharacterScreen(
                        imagePath: 'assets/images/personajes/huillin.png', // Imagen del personaje
                        text: '¡Has regado tu planta por hoy! ¡Vuelve mañana!',
                        onActionCompleted: () {
                          Navigator.pop(context); // Volver a la pantalla anterior
                        },
                        rewardImagePath: 'assets/images/planta/riego.png', // Opcional, si quieres mostrar una imagen de recompensa
                      ),
                    ),
                  );
                } else {
                  // Manejar caso de planta no activa
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Debes plantar una semilla antes de regar.'),
                    ),
                  );
                }
              } catch (e) {
                // Manejo de errores
                debugPrint('Error al regar la planta: $e');
              }
            },
            child: Text('Confirmar'),
          ),
        ],
      );
    },
  );
}
