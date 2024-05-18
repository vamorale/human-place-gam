import 'package:cloud_firestore/cloud_firestore.dart';

class Videos {
  late String _url;
  late String _name;
  late String _thumbnailUrl;

  String get url => _url;
  String get name => _name;
  String get thumbnailUrl => _thumbnailUrl;

  Videos.fromJson(Map<String, dynamic> json) {
    _url = json['url'];
    _name = json['name'];
    _thumbnailUrl = json['thumbnailUrl'];
  }

  Videos.fromSnapshot(DocumentSnapshot doc) {
    _url = doc.get('url');
    _name = doc.get('name');
    _thumbnailUrl = doc.get('thumbnailUrl');
  }
}
