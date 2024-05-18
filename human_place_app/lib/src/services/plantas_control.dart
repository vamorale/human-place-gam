import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class PlantasFunctionResponse {
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
  PlantasFunctionResponse() {
    _end = 0;
    _payload = {};
    _options = [];
    _response = [];
    _statusCode = 0;
    _params = {};
    _habits = [];
  }

  // Lector del JSON
  PlantasFunctionResponse.fromJson(Map<String, dynamic> json) {
    _habits = List<Map<String, dynamic>>.from(json['plantas']);
  }
}

class PlantasFunctionService {
  // Link de la Cloud Function desarrollada por Felipe
  static const String _url =
      'https://us-central1-humanplace-nbhp.cloudfunctions.net/hpAPI';

  // Método para enviar mensajes al bot, detectando intents
  Future<PlantasFunctionResponse> detectPlantas(String userId) async {
    // Se hace un POST a la Cloud Function con el query del usuario y una ID de sesión requerida por el agente

    final token = await FirebaseAuth.instance.currentUser!.getIdToken();

    final String authToken = "Bearer " + token!;

    try {
      final response = await http.post(
        Uri.parse(_url),
        body: json.encode({
          "service": "plantasData",
          'userId': userId,
          "request": {"uid": userId}
        }),
        headers: {
          'Content-Type': 'application/json',
          "Authorization": authToken
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      // Retornamos un PlantasFunctionResponse (clase de arriba) si el código nos indica que la conexión fue exitosa
      if (response.statusCode == 200) {
        final data = Map<String, dynamic>.from(json.decode(response.body));
        print(data);
        return PlantasFunctionResponse.fromJson(data);
      }
      throw PlatformException(code: 'bad_request', message: 'Missing params');
    } catch (e) {
      print('  <--  Error al hacer el POST  -->');
      throw e;
    }
  }
}
