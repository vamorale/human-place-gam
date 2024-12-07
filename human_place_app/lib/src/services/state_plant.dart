import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> checkPlantStatus(String userId, String plantId) async {
  final plantRef = FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('plants')
      .doc(plantId);

  final plantSnapshot = await plantRef.get();

  if (plantSnapshot.exists) {
    final plantData = plantSnapshot.data()!;
    final Timestamp lastWatered = plantData['lastWatered'];
    final bool isAlive = plantData['isAlive'];
    final int protectors = plantData['protectors'];

    final DateTime currentDate = DateTime.now();
    final DateTime lastWateredDate = lastWatered.toDate();
    final int daysSinceLastWatered =
        currentDate.difference(lastWateredDate).inDays;

    if (!isAlive) {
      print('La planta ya está muerta.');
      return;
    }

    if (daysSinceLastWatered <= 1) {
      // La planta sigue viva y está creciendo
      await plantRef.update({
        'growthDays': plantData['growthDays'] + 1,
        'lastWatered': Timestamp.now(),
      });
      print('La planta creció. Días de crecimiento: ${plantData['growthDays'] + 1}');
    } else if (daysSinceLastWatered > 1 && protectors > 0) {
      // Usar un protector
      await plantRef.update({
        'protectors': protectors - 1,
        'lastWatered': Timestamp.now(),
      });
      print('Se utilizó un protector. Protectores restantes: ${protectors - 1}');
    } else if (daysSinceLastWatered > 2) {
      // La planta muere
      await plantRef.update({
        'isAlive': false,
      });
      print('La planta ha muerto.');
    }
  } else {
    print('No se encontró la planta.');
  }
}
