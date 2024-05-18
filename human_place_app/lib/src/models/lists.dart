import 'package:cloud_firestore/cloud_firestore.dart';

class Lists {
  late String _lists;

  String get lists => _lists;

  Lists.fromJson(Map<String, dynamic> json) {
    _lists = json['list'];
  }

  Lists.fromSnapshot(DocumentSnapshot doc) {
    _lists = doc.get('list');
  }
}
