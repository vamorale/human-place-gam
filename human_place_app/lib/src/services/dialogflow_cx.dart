import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

String id_habito = '';

class DialogflowCXResponse {
  // Variables iniciales, idénticas a las llaves del JSON de la Cloud Function
  late int _end; // 1 si es el último mensaje del agente, 0 si no
  late Map<String, dynamic>
      _payload; // Contiene el tipo de elemento y su content para ItemMessage
  late List<String> _options; // Opciones de respuesta rápida
  late List<String> _response; // El texto de respuesta del bot
  late int _statusCode; // El código de estado (200 es que estamos bien)
  late Map<String, dynamic>
      _params; // Los parámetros de la respuesta del agente
  late List<Map<String, dynamic>> _habits; // Los habitos ofrecido por el agente

  // Getters
  int get end => _end;
  Map<String, dynamic> get payload => _payload;
  List<String> get options => _options;
  List<String> get response => _response;
  int get statusCode => _statusCode;
  Map<String, dynamic> get params => _params;
  List<Map<String, dynamic>> get habits => _habits;

  // Constructor
  DialogflowCXResponse() {
    _end = 0;
    _payload = {};
    _options = [];
    _response = [];
    _statusCode = 0;
    _params = {};
    _habits = [];
  }

  // Lector del JSON
  DialogflowCXResponse.fromJson(Map<String, dynamic> json) {
    print('json: ' + json.toString());
    print(json['params']['chat_inicial']);
    print(json['params']['nombre']);
    print(json['id_habito']);
    //Comprobacion de la existencia de "id_habito" en "params", su ausencia causa error en la conexion
    if (json['params']['id_habito'] == null) {
      id_habito = "";
    } else {
      id_habito = json['params']['id_habito'];
    }

    _end = json['end'];
    _payload = Map<String, dynamic>.from(json['payload']);
    _options = List<String>.from(json['payload']['options']);
    _response = List<String>.from(json['respuesta_alt']);
    _statusCode = json['statusCode'];
    _params = Map<String, dynamic>.from(json['params']);
    _habits = List<Map<String, dynamic>>.from(json['habitos_disponibles']);
  }
}

class DialogflowCXService {
  // Link de la Cloud Function desarrollada por Felipe
  static const String _url =
      'https://us-central1-humanplace-nbhp.cloudfunctions.net/hpAPI';

  // Método para enviar mensajes al bot, detectando intents
  Future<DialogflowCXResponse> detectIntent(String query, String sessionId,
      String userId, Map<String, dynamic> habito) async {
    // Se hace un POST a la Cloud Function con el query del usuario y una ID de sesión requerida por el agente
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
            'habito': habito
          }
        }),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": authToken
        },
      );

      // Retornamos un DialogflowCXResponse (clase de arriba) si el código nos indica que la conexión fue exitosa
      print('statusCode: ' + response.statusCode.toString());

      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(json.decode(response.body));
        return DialogflowCXResponse.fromJson(data);
      }
      throw PlatformException(code: 'bad_request', message: 'Missing params');
    } catch (e) {
      print('  <--  Error al hacer el POST  -->');
      throw e;
    }
  }

  // Audios
  bool hasAudio(Map<String, dynamic> fields) => fields.containsKey('audio');
  String getAudio(Map<String, dynamic> fields) {
    return fields['audio'];
  }

  // Cards
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

  // URLs
  bool hasURL(Map<String, dynamic> fields) => fields.containsKey('url');
  String getURL(Map<String, dynamic> fields) {
    return fields['url'];
  }

  // phone
  bool hasPhone(Map<String, dynamic> fields) => fields.containsKey('phone');
  String getPhone(Map<String, dynamic> fields) {
    return fields['phone'];
  }

  // whatsappChat
  bool hasWhatsapp(Map<String, dynamic> fields) =>
      fields.containsKey('whatsappChat');
  String getWhatsapp(Map<String, dynamic> fields) {
    return fields['whatsappChat'];
  }

  // Imágenes
  bool hasImage(Map<String, dynamic> fields) => fields.containsKey('image');
  String getImage(Map<String, dynamic> fields) {
    return fields['image'];
  }

  // Videos
  bool hasVideo(Map<String, dynamic> fields) => fields.containsKey('youtube');
  String getVideo(Map<String, dynamic> fields) {
    return fields['youtube'];
  }

  // Animaciones
  bool hasAnimation(Map<String, dynamic> fields) =>
      fields.containsKey('animacion');
  String getAnimation(Map<String, dynamic> fields) {
    return fields['animacion'];
  }

  // GIFs
  bool hasGif(Map<String, dynamic> fields) => fields.containsKey('gif');
  String getGif(Map<String, dynamic> fields) {
    return fields['gif'];
  }

  // Título de listas
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

  // Descripción de listas
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

  // Imágenes de listas
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

  // Opciones múltiples
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

  // Listas simples
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

  // Hábitos
  bool hasHabits(Map<String, dynamic> fields) =>
      fields['pedir_habito'] == 1; // Revisa la llave params
  List<Map<String, dynamic>> getHabits(Map<String, dynamic> fields) {
    // Revisa el json en general
    return fields['habitos_disponibles'];
  }
}
