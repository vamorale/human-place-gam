import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class DialogflowResponse {
  late List<Map<String, dynamic>> _fulfillmentMessages;
  late List<String> _beforeMessages;
  late List<String> _afterMessages;
  late Map<String, dynamic> _diagnosticInfo;

  List<Map<String, dynamic>> get fulfillmentMessages => _fulfillmentMessages;

  List<String> get beforeMessages => _beforeMessages;

  List<String> get afterMessages => _afterMessages;

  Map<String, dynamic> get diagnosticInfo => _diagnosticInfo;

  DialogflowResponse() {
    _fulfillmentMessages = [];
    _beforeMessages = [];
    _afterMessages = [];
    _diagnosticInfo = {};
  }

  DialogflowResponse.fromJson(Map<String, dynamic> json) {
    final queryResult = Map<String, dynamic>.from(json['queryResult']);
    _fulfillmentMessages =
        List<Map<String, dynamic>>.from(queryResult['fulfillmentMessages']);
    _beforeMessages = List<String>.from(json['beforeMessages'] ?? []);
    _afterMessages = List<String>.from(json['afterMessages'] ?? []);
    _diagnosticInfo =
        Map<String, dynamic>.from(queryResult['diagnosticInfo'] ?? {});
  }
}

class DialogflowService {
  static const String _url =
      'https://us-central1-humanplace-nbhp.cloudfunctions.net/dialogflow/query';

  Future<DialogflowResponse> detectIntent(
    String query, {
    required String sessionId,
    required String userId,
  }) async {
    try {
      final token = await FirebaseAuth.instance.currentUser!.getIdToken();
      final String authToken = "Bearer " + token!;
      final response = await http.post(
        Uri.parse(_url),
        body: json.encode({
          "service": "DialogFlowCX",
          "userId": userId,
          "request": {
            'query': query,
            'sessionId': sessionId,
            'userId': userId,
          }
        }),
        headers: {
          'content-type': 'application/json',
          "Authorization": authToken
        },
      );
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(json.decode(response.body));
        return DialogflowResponse.fromJson(data);
      }
      throw PlatformException(code: 'bad_request', message: 'Missing params');
    } catch (e) {
      throw e;
    }
  }

  List<String> parseOptions(Map<String, dynamic> fields) {
    if (fields.containsKey('options')) {
      final options = Map<String, dynamic>.from(fields['options']);

      final optionValue = Map<String, dynamic>.from(options[options['kind']]);

      if (optionValue.containsKey('values')) {
        final values = List<Map<String, dynamic>>.from(optionValue['values']);

        return values.map((e) => e[e['kind']] as String).toList();
      }
    }
    return [];
  }

  bool hasAudio(Map<String, dynamic> fields) => fields.containsKey('audio');

  String getAudio(Map<String, dynamic> fields) {
    final data = Map<String, dynamic>.from(fields['audio']);
    return data[data['kind']];
  }

  bool hasCard(Map<String, dynamic> fields) => fields.containsKey('card');

  List<String> getCard(Map<String, dynamic> fields) {
    if (fields.containsKey('card')) {
      final campos = Map<String, dynamic>.from(fields['card']);

      final campoValue = Map<String, dynamic>.from(campos[campos['kind']]);

      if (campoValue.containsKey('values')) {
        final values = List<Map<String, dynamic>>.from(campoValue['values']);

        return values.map((e) => e[e['kind']] as String).toList();
      }
    }
    return [];
  }

  bool hasURL(Map<String, dynamic> fields) => fields.containsKey('url');

  String getURL(Map<String, dynamic> fields) {
    final data = Map<String, dynamic>.from(fields['url']);
    return data[data['kind']];
  }

  bool hasImage(Map<String, dynamic> fields) => fields.containsKey('image');

  String getImage(Map<String, dynamic> fields) {
    final data = Map<String, dynamic>.from(fields['image']);
    return data[data['kind']];
  }

  bool hasVideo(Map<String, dynamic> fields) => fields.containsKey('youtube');

  String getVideo(Map<String, dynamic> fields) {
    final data = Map<String, dynamic>.from(fields['youtube']);
    return data[data['kind']];
  }

  bool hasAnimation(Map<String, dynamic> fields) =>
      fields.containsKey('animacion');

  String getAnimation(Map<String, dynamic> fields) {
    final data = Map<String, dynamic>.from(fields['animacion']);
    return data[data['kind']];
  }

  bool hasGif(Map<String, dynamic> fields) => fields.containsKey('gif');

  String getGif(Map<String, dynamic> fields) {
    final data = Map<String, dynamic>.from(fields['gif']);
    return data[data['kind']];
  }

  bool hasWhatsapp(Map<String, dynamic> fields) =>
      fields.containsKey('whatsappChat');

  String getWhatsapp(Map<String, dynamic> fields) {
    final data = Map<String, dynamic>.from(fields['whatsappChat']);
    return data[data['kind']];
  }

  bool hasListTitle(Map<String, dynamic> fields) =>
      fields.containsKey('listTitle');

  List<String> getListTitle(Map<String, dynamic> fields) {
    if (fields.containsKey('listTitle')) {
      final campos = Map<String, dynamic>.from(fields['listTitle']);

      final campoValue = Map<String, dynamic>.from(campos[campos['kind']]);

      if (campoValue.containsKey('values')) {
        final values = List<Map<String, dynamic>>.from(campoValue['values']);

        return values.map((e) => e[e['kind']] as String).toList();
      }
    }
    return [];
  }

  bool hasListDescription(Map<String, dynamic> fields) =>
      fields.containsKey('listDescription');

  List<String> getListDescription(Map<String, dynamic> fields) {
    if (fields.containsKey('listDescription')) {
      final campos = Map<String, dynamic>.from(fields['listDescription']);

      final campoValue = Map<String, dynamic>.from(campos[campos['kind']]);

      if (campoValue.containsKey('values')) {
        final values = List<Map<String, dynamic>>.from(campoValue['values']);

        return values.map((e) => e[e['kind']] as String).toList();
      }
    }
    return [];
  }

  bool hasListImage(Map<String, dynamic> fields) =>
      fields.containsKey('listImage');

  List<String> getListImage(Map<String, dynamic> fields) {
    if (fields.containsKey('listImage')) {
      final campos = Map<String, dynamic>.from(fields['listImage']);

      final campoValue = Map<String, dynamic>.from(campos[campos['kind']]);

      if (campoValue.containsKey('values')) {
        final values = List<Map<String, dynamic>>.from(campoValue['values']);

        return values.map((e) => e[e['kind']] as String).toList();
      }
    }
    return [];
  }

  bool hasMultipleChoice(Map<String, dynamic> fields) =>
      fields.containsKey('multiple');

  List<String> getMultipleChoice(Map<String, dynamic> fields) {
    if (fields.containsKey('multiple')) {
      final campos = Map<String, dynamic>.from(fields['multiple']);

      final campoValue = Map<String, dynamic>.from(campos[campos['kind']]);

      if (campoValue.containsKey('values')) {
        final values = List<Map<String, dynamic>>.from(campoValue['values']);

        return values.map((e) => e[e['kind']] as String).toList();
      }
    }
    return [];
  }

  bool hasSimpleList(Map<String, dynamic> fields) =>
      fields.containsKey('simpleList');

  List<String> getSimpleList(Map<String, dynamic> fields) {
    if (fields.containsKey('simpleList')) {
      final campos = Map<String, dynamic>.from(fields['simpleList']);

      final campoValue = Map<String, dynamic>.from(campos[campos['kind']]);

      if (campoValue.containsKey('values')) {
        final values = List<Map<String, dynamic>>.from(campoValue['values']);

        return values.map((e) => e[e['kind']] as String).toList();
      }
    }
    return [];
  }

  bool endedConversation(Map<String, dynamic> fields) {
    return fields['fields']?.containsKey('end_conversation') ?? false;
  }
}
