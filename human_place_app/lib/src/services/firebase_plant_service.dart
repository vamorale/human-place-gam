import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebasePlantService {
  final _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebasePlantService(this.userId);

  Future<Map<String, dynamic>?> fetchPlantState() async {
    if (userId.isEmpty) return null;

    final plantDoc = await _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('plant')
        .doc('state')
        .get();

    return plantDoc.exists ? plantDoc.data() : null;
  }

  Future<void> initializePlantState({
    required int growthDays,
    required int protectors,
    required bool isPlantAlive,
  }) async {
    if (userId.isEmpty) return;

    await _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('plant')
        .doc('state')
        .set({
      'growthDays': growthDays,
      'protectors': protectors,
      'isPlantAlive': isPlantAlive,
      'lastWatered': null,
    });
  }

  Future<void> updatePlantState(Map<String, dynamic> updates) async {
    if (userId.isEmpty) return;

    await _firestore
        .collection('usuarios')
        .doc(userId)
        .collection('plant')
        .doc('state')
        .update(updates);
  }
}
