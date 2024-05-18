import 'package:cloud_firestore/cloud_firestore.dart';

class Images {
  late String _url;
  late String _name;

  String get url => _url;

  String get name => _name;

  Images.fromJson(Map<String, dynamic> json) {
    _url = json['url'];
    _name = json['name'];
  }

  Images.fromSnapshot(DocumentSnapshot doc) {
    _url = doc.get('url');
    _name = doc.get('name');
  }
}
