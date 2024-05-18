import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:human_place_app/src/models/animacion.dart';
import 'package:human_place_app/src/models/gifs.dart';
import 'package:human_place_app/src/models/images.dart';
import 'package:human_place_app/src/models/lists.dart';
import 'package:human_place_app/src/models/media.dart';
import 'package:human_place_app/src/models/user.dart';
import 'package:human_place_app/src/models/videos.dart';
import 'package:rxdart/rxdart.dart';

enum AppAction {
  FetchMedia,
}

class AppNotifier extends ChangeNotifier {
  late List<Media> _media;
  late List<Animacion> _animacion;
  late List<Images> _images;
  late List<Videos> _videos;
  late List<Gifs> _gifs;
  late List<Lists> _lists;

  late Map<AppAction, bool> _loadings;
  late Map<AppAction, bool> _errors;
  late BehaviorSubject<RemoteMessage> eventBus;

  AppNotifier(this.eventBus) {
    _animacion = [];
    _media = [];
    _images = [];
    _videos = [];
    _gifs = [];
    _lists = [];

    _loadings = {};
    _errors = {};
    AppAction.values.forEach((element) {
      _loadings.addAll({element: false});
      _errors.addAll({element: false});
    });
  }

  bool? hasError(AppAction action) => _errors[action];

  bool? hasLoading(AppAction action) => _loadings[action];

  List<Media> get media => _media;
  List<Animacion> get animacion => _animacion;

  List<Images> get images => _images;
  List<Videos> get videos => _videos;
  List<Gifs> get gifs => _gifs;
  List<Lists> get lists => _lists;

  late User _currentUser;

  User get user => _currentUser;

// Metodo para verificar log in

  Future<void> onLogin(String uid) async {
    final snapshot =
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();
    _currentUser = User.fromJson(snapshot);
    notifyListeners();

    final token = await FirebaseMessaging.instance.getToken();

    await snapshot.reference.set({
      'device_token': token,
    }, SetOptions(merge: true));
  }

  // Metodo para obtener categoria "Media" de firebase

  void fetchMedia() async {
    try {
      _loadings[AppAction.FetchMedia] = true;
      _errors[AppAction.FetchMedia] = false;

      final query = await FirebaseFirestore.instance.collection('media').get();

      _media = query.docs.map((doc) => Media.fromSnapshot(doc)).toList();

      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    } catch (e) {
      _errors[AppAction.FetchMedia] = true;
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    }
  }

  //Metodo para obtener animaciones de firebase

  void fetchAnimacion() async {
    try {
      _loadings[AppAction.FetchMedia] = true;
      _errors[AppAction.FetchMedia] = false;

      final query =
          await FirebaseFirestore.instance.collection('animacion').get();

      _animacion =
          query.docs.map((doc) => Animacion.fromSnapshot(doc)).toList();

      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    } catch (e) {
      _errors[AppAction.FetchMedia] = true;
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    }
  }

  //Metodo para obtener imagenes de firebase

  void fetchImages() async {
    try {
      _loadings[AppAction.FetchMedia] = true;
      _errors[AppAction.FetchMedia] = false;

      final query = await FirebaseFirestore.instance.collection('images').get();

      _images = query.docs.map((doc) => Images.fromSnapshot(doc)).toList();

      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    } catch (e) {
      _errors[AppAction.FetchMedia] = true;
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    }
  }

  // Metodo para obtener videos de firebase

  void fetchVideos() async {
    try {
      _loadings[AppAction.FetchMedia] = true;
      _errors[AppAction.FetchMedia] = false;

      final query = await FirebaseFirestore.instance.collection('videos').get();

      _videos = query.docs.map((doc) => Videos.fromSnapshot(doc)).toList();

      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    } catch (e) {
      _errors[AppAction.FetchMedia] = true;
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    }
  }

  //Metodo para obtener Gifs de Firebase

  void fetchGifs() async {
    try {
      _loadings[AppAction.FetchMedia] = true;
      _errors[AppAction.FetchMedia] = false;

      final query = await FirebaseFirestore.instance.collection('gifs').get();

      _gifs = query.docs.map((doc) => Gifs.fromSnapshot(doc)).toList();

      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    } catch (e) {
      _errors[AppAction.FetchMedia] = true;
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    }
  }

  // Metodo para modificar planificaciones e indicar que se encuentra actualizando

  Future modificarActivo(String uid, String doing) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Planification')
        .get();
    var documentoModificar = query.docs[0].id;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Planification')
        .doc(documentoModificar)
        .update({
      'doing': doing,
    });
  }

  // Metodo para modificar planificaciones e indicar que termino el proceso

  Future modificarTerminado(String uid, String done) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Planification')
        .get();
    var documentoModificar = query.docs[0].id;
    FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('Planification')
        .doc(documentoModificar)
        .update({
      'done': done,
    });
  }

  // Metodo para obtener listas de firebase

  void fetchLists(String uid, String list) async {
    try {
      _loadings[AppAction.FetchMedia] = true;
      _errors[AppAction.FetchMedia] = false;

      final query = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .collection(list)
          .get();
      _lists = query.docs.map((doc) => Lists.fromSnapshot(doc)).toList();
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    } catch (e) {
      _errors[AppAction.FetchMedia] = true;
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    }
  }

  // Metodo para conseguir opciones de un proceso y saber si esta en curso

  void fetchDoingOptions(String uid) async {
    try {
      _loadings[AppAction.FetchMedia] = true;
      _errors[AppAction.FetchMedia] = false;
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    } catch (e) {
      _errors[AppAction.FetchMedia] = true;
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    }
  }

  // Metodo para conseguir opciones de un proceso y saber si a terminado

  void fetchDoneOptions(String uid) async {
    try {
      _loadings[AppAction.FetchMedia] = true;
      _errors[AppAction.FetchMedia] = false;
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    } catch (e) {
      _errors[AppAction.FetchMedia] = true;
      _loadings[AppAction.FetchMedia] = false;
      notifyListeners();
    }
  }
}
