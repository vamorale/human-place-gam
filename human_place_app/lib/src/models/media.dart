import 'package:cloud_firestore/cloud_firestore.dart';

class Media {
  late String _url;
  late String _name;
  late String _description;
  late String _duration;

  String get url => _url;

  String get name => _name;

  String get description => _description;

  String get duration => _duration;

  Media.fromJson(Map<String, dynamic> json) {
    _url = json['url'];
    _name = json['name'];
    _description = json['description'];
    _duration = json['duration'];
  }

  Media.fromSnapshot(DocumentSnapshot doc) {
    _url = doc.get('url');
    _name = doc.get('name');
    _description = doc.get('description');
    _duration = doc.get('duration');
  }
}
