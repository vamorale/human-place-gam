import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> createNewPlant(String userId) async {
  final plantRef = FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('plants')
      .doc();

  await plantRef.set({
    'startDate': Timestamp.now(),
    'growthDays': 0,
    'lastWatered': Timestamp.now(),
    'protectors': 1, // Número inicial de protectores
    'isAlive': true,
  });
}

Future<void> updatePlantGrowth(String userId, String plantId) async {
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
      // La planta crece normalmente
      await plantRef.update({
        'growthDays': plantData['growthDays'] + 1,
        'lastWatered': Timestamp.now(),
      });
    } else if (daysSinceLastWatered > 1 && protectors > 0) {
      // Usar un protector
      await plantRef.update({
        'protectors': protectors - 1,
        'lastWatered': Timestamp.now(),
      });
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

Future<void> checkAndCreateNewPlant(String userId, String plantId) async {
  final plantRef = FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('plants')
      .doc(plantId);

  final plantSnapshot = await plantRef.get();

  if (plantSnapshot.exists) {
    final bool isAlive = plantSnapshot.data()!['isAlive'];

    if (!isAlive) {
      print('Creando una nueva planta...');
      await createNewPlant(userId);
    }
  } else {
    print('No se encontró la planta.');
  }
}

Future<void> dailyPlantCheck(String userId) async {
  final plantsRef = FirebaseFirestore.instance
      .collection('usuarios')
      .doc(userId)
      .collection('plants');

  final plantsSnapshot = await plantsRef.get();

  for (var doc in plantsSnapshot.docs) {
    final plantId = doc.id;
    await updatePlantGrowth(userId, plantId);
    await checkAndCreateNewPlant(userId, plantId);
  }
}

