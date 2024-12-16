import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:http/http.dart' as http;
import '../logic/tutorial_logic.dart';
import '../utils/avatar_state.dart';

final GlobalKey profileButtonKey = GlobalKey();
final GlobalKey medalSection = GlobalKey();
final Map<String, String> pronounMap = {
  '0': 'Femenino (ella)',
  '1': 'Masculino (él)',
  'No binario': 'No binario (elle)',
  'Sin especificar': 'Sin especificar', // Opcional para valores por defecto
};

class ProfileScreen extends StatefulWidget {
  static final routerName = '/profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  var response;
  var _url = Uri.parse(
      'https://us-central1-humanplace-nbhp.cloudfunctions.net/testAppAuth');
  CollectionReference nameRef =
      FirebaseFirestore.instance.collection('usuarios');
  final currentUser = FirebaseAuth.instance.currentUser!;
  String uid = FirebaseAuth.instance.currentUser!.uid;
  String? _selectedPronoun;
  var userName;

  String? _selectedAvatar;

  Future gettest() async {
    User? user = await auth.currentUser;
// ID token del usuario logueado APROVADO
    String? tokenuser = await user!.getIdToken();

    String? uiduser = user.uid;

    print("-------------");
    print(tokenuser);
    print("-------------");
    print(uiduser);
    print("-------------");

    tokenuser = "Bearer " + tokenuser.toString();

    print(tokenuser);

    response = await http.post(
      _url,
      body: json.encode(
          {'uid': uiduser.toString(), 'Authorization': tokenuser.toString()}),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': tokenuser.toString()
      },
    );
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }

  void initState() {
    super.initState();
    _loadPronoun();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkTutorialForView(context, "profile");
    });
  }

  Future<void> _loadPronoun() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();
      final genero = userDoc.data()?['genero'];
      setState(() {
        // Validar si el campo `genero` existe, de lo contrario, mostrar "Sin especificar"
        _selectedPronoun = pronounMap[genero] ?? 'Sin especificar';
      });
    } catch (e) {
      print("Error al cargar el pronombre: $e");
      setState(() {
        _selectedPronoun = 'Sin especificar';
      });
    }
  }

  Future<void> _savePronoun(String value) async {
    try {
      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .update({'genero': value});
      setState(() {
        _selectedPronoun = pronounMap[value];
      });
    } catch (e) {
      print("Error al guardar el pronombre: $e");
    }
  }

  void _showPronounDialog() async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Selecciona tu pronombre'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: Text('Femenino (ella)'),
                onTap: () => Navigator.of(context).pop('0'),
              ),
              ListTile(
                title: Text('Masculino (él)'),
                onTap: () => Navigator.of(context).pop('1'),
              ),
              ListTile(
                title: Text('No binario (elle)'),
                onTap: () => Navigator.of(context).pop('No binario'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancelar'),
            ),
          ],
        );
      },
    );

    if (selected != null) {
      await _savePronoun(selected); // Guardar el pronombre en Firestore
    }
  }

  Future<void> _saveSelectedAvatar(String avatarUrl) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .update({'avatar': avatarUrl});

    AvatarState.updateAvatar(avatarUrl);
  }

  void _showAvatarDialog() async {
    final String? selected = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('avatars')
              .doc('list')
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data!.data() == null) {
              return AlertDialog(
                title: Text('Error'),
                content: Text('No se pudieron cargar los avatares.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Cerrar'),
                  ),
                ],
              );
            }

            final data = snapshot.data!.data() as Map<String, dynamic>;
            final avatars =
                List<String>.from(data['avatars']); // Obtiene la lista de URLs

            return AlertDialog(
              title: Text('Selecciona un avatar'),
              content: SizedBox(
                width: double.maxFinite,
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10.0,
                    mainAxisSpacing: 10.0,
                  ),
                  itemCount: avatars.length,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop(avatars[index]);
                      },
                      child: Image.network(
                        avatars[index],
                        fit: BoxFit.cover,
                      ),
                    );
                  },
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancelar'),
                ),
              ],
            );
          },
        );
      },
    );

    if (selected != null) {
      /* setState(() {
        _selectedAvatar = selected;
      }); */
      await _saveSelectedAvatar(selected); // Guardar el avatar seleccionado
      //Navigator.pop(context);
    }
  }

  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //backgroundColor: Colors.pinkAccent,
        title: Text(
          "Editar $field",
          style: const TextStyle(color: Colors.black),
        ),
        content: TextField(
            autofocus: true,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
                hintText: "Ingresa el nuevo $field",
                hintStyle: TextStyle(color: Colors.black54)),
            onChanged: (value) {
              newValue = value;
            }),
        actions: [
          TextButton(
            child: Text(
              'Cancelar',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: Text(
              'Guardar',
              style: TextStyle(color: Colors.purple),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );
    if (newValue.trim().length > 0) {
      await nameRef.doc(uid).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        //backgroundColor: Colors.purple[900],
        resizeToAvoidBottomInset: false,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          centerTitle: true,
          title: SizedBox(
            child: Text(
              "Mi perfil",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontFamily: 'sen-regular',
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          automaticallyImplyLeading: false,
          
          backgroundColor: Colors.transparent,
          toolbarHeight: 60,
          elevation: 0,
          actions: [
            Container(
              margin: EdgeInsets.only(right: 10, top: 10),
              width: 50,
              height: 50,
              child: FloatingActionButton(
                backgroundColor: Colors.transparent,
                elevation: 0,
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Container(
                  width: 50,
                  height: 50,
                  child: Icon(Icons.home,
                      size: 35, color: Color.fromARGB(255, 234, 234, 234)),
                  decoration: BoxDecoration(
                      color: Colors.black,
                      shape: BoxShape.circle,
                      gradient: RadialGradient(radius: 0.6, stops: [
                        0.4,
                        0.8
                      ], colors: [
                        CustomColors.newPinkSecondary,
                        CustomColors.newPurpleSecondary,
                      ])),
                ),
              ),
            ),
          ],
        ),
        body: Stack(
          children: [
            Container(
          //alignment: Alignment.bottomCenter,
          decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, // Punto inicial del degradado
            end: Alignment.bottomRight, // Punto final del degradado
            colors: [
              Colors.pink, // Primer color
              Colors.purple, // Segundo color
            ],
          ),
        ),
            ),
            SafeArea(
              child: Column(
                children: [
                  //SizedBox(height: 50,),
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection("usuarios")
                .doc(uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                final userData = snapshot.data!.data() as Map<String, dynamic>;
                final avatarUrl = userData['avatar'];
                return Column(
                  children: <Widget>[
                    Column(
                      key: profileButtonKey,
                      children: [
                        SizedBox(
                          height: 15,
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            if (avatarUrl != null)
                              CircleAvatar(
                                backgroundImage: NetworkImage(avatarUrl),
                                radius: 50,
                              )
                            else
                              CircleAvatar(
                                radius: 50,
                                child: Icon(Icons.person, size: 50),
                              ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: _showAvatarDialog,
                              child: Text('Seleccionar Avatar'),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                width: size.width,
                                child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: "Nombre de usuario:",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: 'sen-regular',
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                              SizedBox(height: 10),
                              Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: size.width - 80,
                                child: ElevatedButton(
                                  onPressed: () => editField('nombre'),
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Opacity(
                                          opacity: 0,
                                          child: Icon(Icons.edit),
                                        ),
                                        Text(
                                          "${userData['nombre']}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontFamily: 'sen-regular',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(Icons.edit,
                                            size: 15, color: Colors.black),
                                      ]),
                                ),
                              ),
                            ]),
                        SizedBox(
                          height: 5,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                alignment: Alignment.center,
                                width: size.width,
                                child: RichText(
                                    textAlign: TextAlign.center,
                                    text: TextSpan(
                                      text: "Pronombre:",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontFamily: 'sen-regular',
                                          fontWeight: FontWeight.bold),
                                    )),
                              ),
                              SizedBox(height: 10),
                              Container(
                                alignment: Alignment.center,
                                height: 40,
                                width: size.width - 80,
                                child: ElevatedButton(
                                  onPressed: _showPronounDialog,
                                  child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: <Widget>[
                                        Opacity(
                                          opacity: 0,
                                          child: Icon(Icons.edit),
                                        ),
                                        Text(
                                          "${_selectedPronoun ?? 'Cargando...'}",
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 15,
                                              fontFamily: 'sen-regular',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        SizedBox(width: 10),
                                        Icon(Icons.edit,
                                            size: 15, color: Colors.black),
                                      ]),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(
                      height: 10,
                      thickness: 1,
                      indent: 20,
                      endIndent: 20,
                      color: Colors.white,
                    ),

                    //SECCION MEDALLAS

                    Container(
                      key: medalSection,
                      //color: Colors.blueGrey,
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 145, 54, 21),
                          border: Border.all(
                              color: Color.fromARGB(255, 78, 23, 3), width: 3),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black54,
                                spreadRadius: 2,
                                blurRadius: 10,
                                offset: Offset(0, 5))
                          ]),
                      child: Column(
                        children: <Widget>[
                          //TITULO
                          Container(
                            //margin: EdgeInsets.all(10),
                            width: size.width,
                            height: 50,
                            child: Text(
                              "Medallas",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontFamily: 'sen-regular'),
                            ),
                          ),
                          StreamBuilder<QuerySnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('usuarios')
                                .doc(uid) // El ID del usuario actual
                                .collection('medallas')
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return CircularProgressIndicator();
                              }
                              if (snapshot.hasError) {
                                return Text('Error al cargar las medallas');
                              }
                              if (!snapshot.hasData ||
                                  snapshot.data!.docs.isEmpty) {
                                return Text(
                                  'No se encontraron medallas.',
                                  style: TextStyle(color: Colors.white),
                                );
                              }

                              final medallas = snapshot.data!.docs;

                              return Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: medallas.map((medalla) {
                                  final data =
                                      medalla.data() as Map<String, dynamic>;
                                  final bool alcanzada =
                                      data['alcanzada'] ?? false;
                                  final int dias = int.tryParse(medalla.id) ??
                                      0; // ID como entero
                                  final dynamic fechaData = data['fecha'];
                                  DateTime? fecha;

                                  if (fechaData is Timestamp) {
                                    fecha = fechaData
                                        .toDate(); // Convertir Timestamp a DateTime
                                  } else if (fechaData is String) {
                                    try {
                                      fecha = DateTime.parse(
                                          fechaData); // Convertir String a DateTime
                                    } catch (e) {
                                      print(
                                          'Error al parsear la fecha como String: $e');
                                      fecha = null;
                                    }
                                  }

                                  // Imagen de la medalla según el ID
                                  final Map<int, String> medallasAssets = {
                                    1: "assets/images/badge-ovejero/medalla_1.png",
                                    3: "assets/images/badge-ovejero/medalla_3.png",
                                    5: "assets/images/badge-ovejero/medalla_5.png",
                                    7: "assets/images/badge-ovejero/medalla_7.png",
                                  };

                                  final String medallaImage =
                                      medallasAssets[dias] ??
                                          "assets/images/default_badge.png";

                                  return Tooltip(
                                    message: alcanzada
                                        ? (fecha != null
                                            ? 'Lograda el ${fecha.day}/${fecha.month}/${fecha.year}'
                                            : 'Lograda en una fecha desconocida')
                                        : 'Alcanza $dias días de práctica',
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurpleAccent,
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5)),
                                    ),
                                    triggerMode: TooltipTriggerMode.tap,
                                    child: Stack(
                                      children: [
                                        CircleAvatar(
                                          backgroundImage:
                                              AssetImage(medallaImage),
                                          radius: 35,
                                        ),
                                        if (!alcanzada)
                                          Container(
                                            width:
                                                70, // Tamaño del CircleAvatar
                                            height: 70,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.black.withOpacity(
                                                  0.8), // Oscurecer
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.lock,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Error${snapshot.error}"),
                );
              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            })]))]));
}}
