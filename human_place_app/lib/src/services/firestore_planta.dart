import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> addPlantGrowthData({
    required String userId,
    required int growthDays,
    required DateTime wateringStartDate,
    required DateTime lastWateringDate,
    required int protectors,
    required bool isAlive,
  }) async {
    try {
      // Referencia a la colección
      final collectionRef = _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('plant_growth');

      // Obtener el número de documentos actuales
      final snapshot = await collectionRef.get();
      final count = snapshot.size;

      // Generar el nuevo ID
      final newId = 'planta${count + 1}';

      // Agregar el documento con los datos
      await collectionRef.doc(newId).set({
        'growthDays': growthDays,
        'wateringStartDate': wateringStartDate.toIso8601String(),
        'lastWateringDate': lastWateringDate.toIso8601String(),
        'protectors': protectors,
        'isAlive': isAlive,
      });

      print('Datos de crecimiento añadidos correctamente con ID: $newId');
      return newId; // Retorna el ID generado
    } catch (e) {
      print('Error al guardar los datos: $e');
      throw e; // Lanza el error para manejarlo en el lugar de la llamada
    }
  }

  Future<bool> verificarDatoFirestore(String collectionName, String documentId,
      String fieldName, dynamic value) async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(documentId)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null && data.containsKey(fieldName)) {
          return data[fieldName] == value;
        }
      }
      return false; // El campo o el valor no existen
    } catch (e) {
      print("Error al verificar el dato: $e");
      return false; // Error al consultar
    }
  }

  Future<void> updatePlantGrowthData(
      String userId, String? existingplantid) async {
    try {
      // Referencia al documento del usuario
      final docRef = _firestore
          .collection('usuarios')
          .doc(userId)
          .collection('plant_growth')
          .doc(existingplantid);

      // Obtener el documento actual
      final docSnapshot = await docRef.get();

      if (docSnapshot.exists) {
        // Obtener datos actuales
        final data = docSnapshot.data();
        if (data != null && data.containsKey('growthDays')) {
          // Incrementar growthDays y actualizar lastWateringDate
          await docRef.update({
            'growthDays': data['growthDays'] + 1,
            'lastWateringDate': FieldValue.serverTimestamp(),
          });
        } else {
          print("El campo 'growthDays' no existe en el documento.");
        }
      } else {
        print("El documento no existe.");
      }
    } catch (e) {
      print("Error al actualizar los datos de crecimiento de la planta: $e");
    }
  }

  Future<void> checkPlantStatus(String userId) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('usuarios').doc(userId);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print('El usuario no existe.');
        return null;
      }

      final userData = userSnapshot.data() as Map<String, dynamic>;
      final String? plantaActiva = userData['plantaActiva'] as String?;

      if (plantaActiva == null || plantaActiva.isEmpty) {
        print('No hay una planta activa.');
        return;
      }

      final plantDoc = userDoc.collection('plant_growth').doc(plantaActiva);
      final plantSnapshot = await plantDoc.get();

      if (!plantSnapshot.exists) {
        print('La planta activa no existe.');
        return;
      }

      final plantData = plantSnapshot.data() as Map<String, dynamic>;

      if (!(plantData['isAlive'] as bool)) {
        print('La planta ya está muerta.');
        return;
      }

      final DateTime lastWatered = DateTime.parse(plantData['lastWatered']);
      final DateTime now = DateTime.now();
      final DateTime yesterday = now.subtract(Duration(days: 1));

      if (lastWatered.isBefore(yesterday) &&
          !isSameDay(lastWatered, yesterday)) {
        final int protectores = userData['protectores'] ?? 0;

        if (protectores > 0) {
          print('Usando un protector.');
          await userDoc.update({'protectores': protectores - 1});
          await plantDoc.update({'lastWatered': now.toIso8601String()});
        } else {
          print('La planta ha muerto.');
          await plantDoc.update({'isAlive': false});
          await userDoc.update({'plantaActiva': null});
          return;
        }
      }

      // Calcular días actuales
      final int diasActuales =
          DateTime.now().difference(lastWatered).inDays + 1;

      // Actualizar datos del usuario
      await actualizarMayorDiasLogrados(userId, diasActuales);
      await actualizarSemillas(
          userId, 10); // Ejemplo: 10 semillas ganadas por riego

      print('Estado de la planta actualizado. Días actuales: $diasActuales.');
    } catch (e) {
      print('Error al verificar el estado de la planta: $e');
    }
  }

  Future<void> actualizarMayorDiasLogrados(
      String userId, int diasActuales) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('usuarios').doc(userId);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print('El usuario no existe.');
        return;
      }

      final userData = userSnapshot.data() as Map<String, dynamic>;

      // Obtener el valor actual de mayorDiasLogrados
      final int mayorDiasLogrados = userData['mayorDiasLogrados'] ?? 0;

      // Actualizar mayorDiasLogrados si los días actuales son mayores
      if (diasActuales > mayorDiasLogrados) {
        await userDoc.update({'mayorDiasLogrados': diasActuales});
        print('Actualizado mayorDiasLogrados a $diasActuales.');
      } else {
        print('mayorDiasLogrados no requiere actualización.');
      }
    } catch (e) {
      print('Error al actualizar mayorDiasLogrados: $e');
    }
  }

  bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> updateMedallas(String userId, int daysAchieved) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('usuarios').doc(userId);
      final medallasRef = userDoc.collection('medallas');

      // Define las medallas disponibles
      final List<int> medallas = [1, 3, 5, 7];

      for (int medalla in medallas) {
        if (daysAchieved >= medalla) {
          final medallaDoc = medallasRef.doc(medalla.toString());
          final medallaSnapshot = await medallaDoc.get();

          if (!medallaSnapshot.exists ||
              !(medallaSnapshot.data()?['alcanzada'] ?? false)) {
            // Si la medalla no ha sido alcanzada, la marcamos como conseguida
            await medallaDoc.set({
              'alcanzada': true,
              'fecha': DateTime.now().toIso8601String(),
            });
            print('Medalla de $medalla días conseguida.');
          } else {
            print('Medalla de $medalla días ya fue alcanzada.');
          }
        }
      }
    } catch (e) {
      print('Error al actualizar las medallas: $e');
    }
  }

  Future<void> actualizarSemillas(String userId, int semillasGanadas) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('usuarios').doc(userId);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print('El usuario no existe.');
        return;
      }

      final userData = userSnapshot.data() as Map<String, dynamic>;

      // Obtener las semillas actuales
      final int semillasActuales = userData['semillas'] ?? 0;
      final int nuevasSemillas = semillasActuales + semillasGanadas;

      // Actualizar el valor de las semillas
      await userDoc.update({'semillas': nuevasSemillas});
      print('Actualizado semillas a $nuevasSemillas.');
    } catch (e) {
      print('Error al actualizar semillas: $e');
    }
  }
  Future<void> convertirSemillasAProtectores(String userId) async {
  try {
    final userDoc = FirebaseFirestore.instance.collection('usuarios').doc(userId);
    final userSnapshot = await userDoc.get();

    if (!userSnapshot.exists) {
      print('El usuario no existe.');
      return;
    }

    final userData = userSnapshot.data() as Map<String, dynamic>;

    // Obtener los valores actuales de semillas y protectores
    final int semillasActuales = userData['semillas'] ?? 0;
    final int protectoresActuales = userData['protectores'] ?? 0;

    // Verificar si ya tiene el máximo de protectores
    if (protectoresActuales >= 2) {
      print('Ya tienes el máximo de 2 protectores.');
      return;
    }

    // Verificar si el usuario tiene al menos 10 semillas
    if (semillasActuales < 10) {
      print('No tienes suficientes semillas para convertir.');
      return;
    }

    // Actualizar semillas y protectores
    await userDoc.update({
      'semillas': semillasActuales - 10,
      'protectores': protectoresActuales + 1,
    });

    print('10 semillas convertidas en 1 protector. Protectores actuales: ${protectoresActuales + 1}');
  } catch (e) {
    print('Error al convertir semillas a protectores: $e');
  }
}

}

