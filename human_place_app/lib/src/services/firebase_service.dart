import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FirebaseService {
  static Future<void> updatePlantGrowth(String userId) async {
    final plantRef = FirebaseFirestore.instance.collection('users').doc(userId);

    final plantSnapshot = await plantRef.get();

    if (plantSnapshot.exists) {
      final data = plantSnapshot.data()!;
      final plantData = data['plants'];
      final Timestamp lastWatered = plantData['lastWatered'];
      final bool isAlive = plantData['isAlive'];
      final int protectors = plantData['protectors'];

      final DateTime currentDate = DateTime.now();
      final DateTime lastWateredDate = lastWatered.toDate();
      final int daysSinceLastWatered =
          currentDate.difference(lastWateredDate).inDays;

      if (!isAlive) return;

      if (daysSinceLastWatered <= 1) {
        await plantRef.update({
          'plants.growthDays': plantData['growthDays'] + 1,
          'plants.lastWatered': Timestamp.now(),
        });
      } else if (daysSinceLastWatered > 1 && protectors > 0) {
        await plantRef.update({
          'plants.protectors': protectors - 1,
          'plants.lastWatered': Timestamp.now(),
        });
      } else if (daysSinceLastWatered > 2) {
        await plantRef.update({'plants.isAlive': false});
      }
    }
  }

  static Future<void> saveNotificationTime(String userId, TimeOfDay time) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    await userRef.update({
      'notificationTime': {'hour': time.hour, 'minute': time.minute},
    });
  }

  static Future<TimeOfDay?> loadNotificationTime(String userId) async {
    final userRef = FirebaseFirestore.instance.collection('users').doc(userId);
    final snapshot = await userRef.get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      if (data['notificationTime'] != null) {
        return TimeOfDay(
          hour: data['notificationTime']['hour'],
          minute: data['notificationTime']['minute'],
        );
      }
    }
    return null;
  }
}
