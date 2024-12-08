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

  Future<void> updatePlantGrowthData(String userId,String? existingplantid) async {
    try {
      // Referencia al documento del usuario
      final docRef = _firestore.collection('usuarios').doc(userId).collection('plant_growth').doc(existingplantid);

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
}
