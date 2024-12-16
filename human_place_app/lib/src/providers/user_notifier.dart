import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserNotifier extends ChangeNotifier {
  String _avatarUrl = '';

  String get avatarUrl => _avatarUrl;

  Future<void> updateAvatarUrl(String newUrl) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      // Actualiza en Firebase
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .update({'avatar': newUrl});

      // Actualiza en el estado local
      _avatarUrl = newUrl;
      notifyListeners(); // Notifica a los widgets que dependan del estado
    }
  }

  Future<void> fetchAvatarUrl() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid != null) {
      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      final data = doc.data();
      if (data != null && data.containsKey('avatar')) {
        _avatarUrl = data['avatar'];
        notifyListeners(); // Notifica a los widgets que dependan del estado
      }
    }
  }
}
