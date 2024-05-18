import 'package:cloud_firestore/cloud_firestore.dart';

class Animacion {
  late String _title;
  late String _url;

  String get title => _title;

  String get url => _url;

  Animacion.fromJson(Map<String, dynamic> json) {
    _title = json['title'];
    _url = json['url'];
  }

  Animacion.fromSnapshot(DocumentSnapshot doc) {
    _title = doc.get('title');
    _url = doc.get('url');
  }
}
