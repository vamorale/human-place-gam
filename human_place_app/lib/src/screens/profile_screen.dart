import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:human_place_app/src/services/firebase.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:http/http.dart' as http;

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
  var userName;
  
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
    this.getName();
    super.initState();
  }
void getName() {
    nameRef.doc(uid).get().then((value) {
      var fields = value;
      setState(() {
        userName = fields['nombre'];
        if (userName == 'null') {
          userName = 'Usuario';
        }
      });
    }).catchError((err) {
      final User? user = auth.currentUser;
      print('user: ' + user!.displayName.toString());
      final uid = user.displayName.toString().split(" ");
      userName = uid[0];
      FirestoreService().updateUserName(userName);
    });
  }
  Future<void>editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey,
        title: Text(
          "Editar $field",
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: "Ingresa el nuevo $field",
            hintStyle: TextStyle(color: Colors.grey)
          ),
          onChanged: (value) {
            newValue = value;
          }),
          actions: [
            TextButton(
              child: Text(
                'Cancelar',
                style: TextStyle(
                color: Colors.white
                ),
              ),
              onPressed: () => Navigator.pop(context),
            ),

            TextButton(
              child: Text(
                'Guardar',
                style: TextStyle(
                color: Colors.white
                ),
              ),
              onPressed: () => Navigator.of(context).pop(newValue),
            ),
          ],
        ),
      );
      if (newValue.trim().length > 0){
        await nameRef.doc(uid).update({field: newValue});
      }
  }


  @override
  Widget build(BuildContext context) {
    final User? user = auth.currentUser;
    Size size = MediaQuery.of(context).size;
    //late int opacidad;

    return Scaffold(
      backgroundColor: Colors.pinkAccent,
      appBar: AppBar(
        centerTitle: true,
        title: SizedBox(
          child: Text(
            "Perfil",
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
        /* leading: Container(
            margin: EdgeInsets.only(top: 10, left: 10),
            padding: EdgeInsets.all(0),           
            child: IconButton(
              onPressed: null, 
              icon: CircleAvatar(
                backgroundImage: AssetImage("assets/logos/perfil-1.png"),
                radius: 50,
              ),
              style: IconButton.styleFrom(
                //elevation: 1,
                padding: EdgeInsets.all(0),
                side: BorderSide(width: 2, color: Colors.black),
                fixedSize: Size.square(60),
              ),
            ),
          ), */
        actions: [
          Container(
            margin: EdgeInsets.only(right: 10, top: 10),
            width: 50,
            height: 50,
            child: FloatingActionButton(
              backgroundColor: Colors.transparent,
              elevation: 0,
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  MainPage.routerName,
                  (route) => false,
                );
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
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection("usuarios").doc(uid).snapshots(),
        builder: (context,snapshot){
          if(snapshot.hasData){
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            return Column(
            children: <Widget>[
          //Texto de abajo

          //Imagen de perfil
          Container(
            height: size.height / 9,
            margin: EdgeInsets.all(10),
            //width: 80,
            decoration:
                BoxDecoration(shape: BoxShape.circle, color: Colors.amber),
          ),

          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  alignment: Alignment.center,
                  //margin: EdgeInsets.all(10),
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          Icon(Icons.edit, size: 15, color: Colors.black),
                        ]),
                  ),
                ),
              ]),

          Container(
            margin: EdgeInsets.all(10),
            width: size.width,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(children: <TextSpan>[
                TextSpan(
                  text: "Correo en uso:\n",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'sen-regular',
                      fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: user?.email,
                  style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                )
              ]),
            ),
          ),
          const Divider(
            height: 10,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.white,
          ),

          //SECCION ABONOS
          Container(
            margin: EdgeInsets.all(5),
            width: size.width,
            //height: 50,
            child: Text(
              "Abonos",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white, fontSize: 25, fontFamily: 'sen-regular'),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(10, 1, 10, 1),
            width: size.width,
            //height: 50,
            child: Text(
              "Protegen tu planta cuando no practicas un hábito diario",
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white, fontSize: 15, fontFamily: 'sen-regular'),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(left: 50),
                  child:
                    Image(image: AssetImage("assets/images/planta/abono.png")),
              )),
              /* Container(
                  child: Container(
                  width: 80,
                  child:
                    Image(image: AssetImage("assets/images/planta/abono.png")),
              )), */
              Expanded(
                child: Container(
                  width: 80,
                  height: 80,
                  margin: EdgeInsets.only(right: 50),
                  child:
                    Image(image: AssetImage("assets/images/planta/abono.png")),
              )),
            ],
          ),

          SizedBox(height: 20),

          /* const Divider(
            height: 10,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.white,
          ),
 */
          //SECCION MEDALLAS

          Container(
            //color: Colors.blueGrey,
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: const Color.fromARGB(255, 145, 54, 21),
                border:
                    Border.all(color: Color.fromARGB(255, 78, 23, 3), width: 3),
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
                Row(
                  children: <Widget>[
                    //Medalla cobre
                    Expanded(
                      child: Tooltip(
                        message: 'Alcanza 1 día de práctica',
                        decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        triggerMode: TooltipTriggerMode.tap,
                        height: 20,
                        margin: EdgeInsets.all(10),
                        preferBelow: true,
                        showDuration: Duration(seconds: 2),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                  "assets/images/badge-ovejero/badge-1-cupper.png"),
                              foregroundColor: Colors.black,
                              radius: 35,
                            ),
                            Container(
                              width: 70, // Tamaño del CircleAvatar
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black
                                    .withOpacity(0.9), // Oscurecer con gris
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //Medalla plata
                    Expanded(
                      child: Tooltip(
                        message: 'Alcanza 3 días de práctica',
                        decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        triggerMode: TooltipTriggerMode.tap,
                        height: 20,
                        margin: EdgeInsets.all(10),
                        preferBelow: true,
                        showDuration: Duration(seconds: 2),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                  "assets/images/badge-ovejero/badge-2-silver.png"),
                              foregroundColor: Colors.black,
                              radius: 35,
                            ),
                            Container(
                              width: 70, // Tamaño del CircleAvatar
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black
                                    .withOpacity(0.9), // Oscurecer con gris
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //Medalla oro
                    Expanded(
                      child: Tooltip(
                        message: 'Alcanza 5 días de práctica',
                        decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        triggerMode: TooltipTriggerMode.tap,
                        height: 20,
                        margin: EdgeInsets.all(10),
                        preferBelow: true,
                        showDuration: Duration(seconds: 2),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                  "assets/images/badge-ovejero/badge-3-gold.png"),
                              foregroundColor: Colors.black,
                              radius: 35,
                            ),
                            Container(
                              width: 70, // Tamaño del CircleAvatar
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black
                                    .withOpacity(0.9), // Oscurecer con gris
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    //Medalla diamante
                    Expanded(
                      child: Tooltip(
                        message: 'Alcanza 7 días de práctica',
                        decoration: BoxDecoration(
                            color: Colors.deepPurpleAccent,
                            borderRadius: BorderRadius.all(Radius.circular(5))),
                        triggerMode: TooltipTriggerMode.tap,
                        height: 20,
                        margin: EdgeInsets.all(10),
                        preferBelow: true,
                        showDuration: Duration(seconds: 2),
                        child: Stack(
                          children: [
                            CircleAvatar(
                              backgroundImage: AssetImage(
                                  "assets/images/badge-ovejero/badge-4-diamond.png"),
                              foregroundColor: Colors.black,
                              radius: 35,
                            ),
                            Container(
                              width: 70, // Tamaño del CircleAvatar
                              height: 70,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.black
                                    .withOpacity(0.9), // Oscurecer con gris
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
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
          return const Center(child: CircularProgressIndicator(),);
        }
      )
    );
  }
}
