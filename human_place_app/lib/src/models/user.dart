import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  late String _id;

  String get id => _id;

  User.fromJson(DocumentSnapshot snapshot) {
    _id = snapshot.id;
  }
}
