import 'package:cloud_firestore/cloud_firestore.dart';

class Gifs {
  late String _url;
  late String _name;

  String get url => _url;

  String get name => _name;

  Gifs.fromJson(Map<String, dynamic> json) {
    _url = json['url'];
    _name = json['name'];
  }

  Gifs.fromSnapshot(DocumentSnapshot doc) {
    _url = doc.get('url');
    _name = doc.get('name');
  }
}
