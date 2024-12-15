import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/character_screen.dart';

class ConversionResult {
  final bool success;
  final String message;

  ConversionResult({required this.success, required this.message});
}

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
        //'protectors': protectors,
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

  Future<void> verificarDesbloqueo(String userId) async {
    try {
      // Referencia al documento del usuario
      final userDoc = _firestore.collection('usuarios').doc(userId);

      // Obtener el documento actual
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        print("El documento del usuario no existe.");
        return;
      }

      // Obtener las fechas de riego
      Map<String, dynamic> data = docSnapshot.data()!;
      if (!data.containsKey('personajeDesbloqueado')) {
        await userDoc.update({'personajeDesbloqueado': false});
      }
      List<dynamic> fechasRiego = data['fechasRiego'] ?? [];

      if (fechasRiego.length < 5) return;

      // Convertir a DateTime y ordenar
      List<DateTime> fechas =
          fechasRiego.map((e) => (e as Timestamp).toDate()).toList();
      fechas.sort();

      // Verificar si son consecutivas
      bool cincoDiasConsecutivos = true;
      for (int i = 1; i < 5; i++) {
        if (fechas[i].difference(fechas[i - 1]).inDays != 1) {
          cincoDiasConsecutivos = false;
          break;
        }
      }

      if (cincoDiasConsecutivos) {
        await userDoc.update({'personajeDesbloqueado': true});
        int semillasActuales = data['semillas'] ?? 0;
        await userDoc.update({'semillas': semillasActuales + 5});
        print("¡Personaje desbloqueado!");
      }
    } catch (e) {
      print("Error al verificar el desbloqueo: $e");
    }
  }

  Future<void> registrarRiego(String userId) async {
    try {
      // Referencia al documento del usuario
      final userDoc = _firestore.collection('usuarios').doc(userId);

      // Obtener el documento actual
      final docSnapshot = await userDoc.get();

      if (!docSnapshot.exists) {
        print("El documento del usuario no existe.");
        return;
      }

      // Obtener las fechas de riego
      final data = docSnapshot.data();
      List<dynamic> fechasRiego = data?['fechasRiego'] ?? [];

      // Verificar si ya regó hoy
      DateTime hoy = DateTime.now();
      if (fechasRiego.isNotEmpty) {
        DateTime ultimaFecha = (fechasRiego.last as Timestamp).toDate();
        if (hoy.difference(ultimaFecha).inDays == 0) {
          print("Ya regaste hoy.");
          return;
        }
      }

      // Agregar la fecha de riego actual
      fechasRiego.add(Timestamp.fromDate(hoy));
      await userDoc.update({'fechasRiego': fechasRiego});

      // Verificar desbloqueo del personaje
      await verificarDesbloqueo(userId);

      print("Riego registrado correctamente.");
    } catch (e) {
      print("Error al registrar el riego: $e");
    }
  }

  Future<void> checkPlantStatus(String userId, BuildContext context) async {
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

      final dynamic lastWateredRaw = plantData['lastWateringDate'];

      if (lastWateredRaw == null || lastWateredRaw is! Timestamp) {
        print('El campo lastWatered es null o no es un Timestamp válido.');
        return; // Maneja el caso según sea necesario
      }

      final DateTime lastWatered = (lastWateredRaw).toDate();
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
          Navigator.push(
    context, // Necesitas pasar el contexto desde el widget que llama a esta función
    MaterialPageRoute(
      builder: (context) => CharacterScreen(
        imagePath: 'assets/images/gato_sam.png', // Cambia por la ruta de tu imagen
        text: 'Tu planta se ha secado. ¿Intentamos de nuevo? \n ¡No te rindas!',
        onActionCompleted: () {
          Navigator.pop(context); // Vuelve a la pantalla anterior
        },
      ),
    ),
  );
          return;
        }
      }

      // Calcular días actuales
      final int diasActuales =
          DateTime.now().difference(lastWatered).inDays + 1;

      // Actualizar datos del usuario
      await actualizarMayorDiasLogrados(userId, diasActuales);
      /* await actualizarSemillas(
          userId, 10);  */ // Ejemplo: 10 semillas ganadas por riego

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

  Future<ConversionResult> convertirSemillasAProtectores(String userId) async {
    try {
      final userDoc =
          FirebaseFirestore.instance.collection('usuarios').doc(userId);
      final userSnapshot = await userDoc.get();

      if (!userSnapshot.exists) {
        print('El usuario no existe.');
        return ConversionResult(
            success: false, message: 'El usuario no existe.');
      }

      final userData = userSnapshot.data() as Map<String, dynamic>;

      // Obtener los valores actuales de semillas y protectores
      final int semillasActuales = userData['semillas'] ?? 0;
      final int protectoresActuales = userData['protectores'] ?? 0;

      // Verificar si ya tiene el máximo de protectores
      if (protectoresActuales >= 2) {
        print('Ya tienes el máximo de 2 protectores.');
        return ConversionResult(
            success: false, message: 'Ya tienes el máximo de 2 protectores.');
      }

      // Verificar si el usuario tiene al menos 10 semillas
      if (semillasActuales < 10) {
        print('No tienes suficientes semillas para convertir.');
        return ConversionResult(
            success: false, message: 'No tienes suficientes semillas.');
      }

      // Actualizar semillas y protectores
      await userDoc.update({
        'semillas': semillasActuales - 10,
        'protectores': protectoresActuales + 1,
      });

      print("Conversión completada: 10 semillas -> 1 saco de abono.");
      return ConversionResult(
          success: true, message: '¡Has ganado un saco de abono!');
    } catch (e) {
      print("Error al convertir semillas a protectores: $e");
      return ConversionResult(
          success: false, message: 'Ocurrió un error. Inténtalo nuevamente.');
    }
  }

  Future<int> updatePlantGrowthData(
      String userId, String? existingplantid) async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    // Referencia al documento del usuario
    final docRef = _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('plant_growth')
        .doc(existingplantid);

    try {
      final docSnapshot = await docRef.get();
      if (!docSnapshot.exists) return 0;

      // Incrementar días de crecimiento
      final data = docSnapshot.data() as Map<String, dynamic>;
      int growthDays = data['growthDays'] ?? 0;

      growthDays += 1; // Incrementar los días
      await docRef.update({
        'growthDays': growthDays,
        'lastWateringDate': FieldValue.serverTimestamp(),
      });

      print("Días de crecimiento actualizados.");

      // Verificar desbloqueo de medallas
      return growthDays;
    } catch (e) {
      print("Error al actualizar datos de crecimiento: $e");
      return 0;
    }

    /*  // Obtener el documento actual
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
    } */
  }
}
