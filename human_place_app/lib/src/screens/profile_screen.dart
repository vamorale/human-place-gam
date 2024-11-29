import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:http/http.dart' as http;

class ProfileScreen extends StatefulWidget {
  static final routerName = '/profile-screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState(); 
}

class _ProfileScreenState extends State<ProfileScreen>{
  final FirebaseAuth auth = FirebaseAuth.instance;
  var response;
  var _url = Uri.parse(
      'https://us-central1-humanplace-nbhp.cloudfunctions.net/testAppAuth');

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
  @override
  Widget build(BuildContext context) {
    
    final User? user = auth.currentUser;
    Size size = MediaQuery.of(context).size;

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
      body: Column(
        children: <Widget>[
          //Texto de abajo
          
          //Imagen de perfil
          Container(
            height: size.height/8,
            margin: EdgeInsets.all(10),
            //width: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.amber
            ),
          ),
          
          Container(
            margin: EdgeInsets.all(10),
            width: size.width,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(            
                    text: "Nombre de usuario:\n",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'sen-regular',
                      fontWeight: FontWeight.bold                  
                    ),
                  ),
                  TextSpan(            
                    text: user!.displayName,
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontFamily: 'sen-regular',
                      fontWeight: FontWeight.bold                  
                    ),
                  )
                ]
              ),
            ),
          ),
          
          Container(
            margin: EdgeInsets.all(10),
            width: size.width,
            child: RichText(
              textAlign: TextAlign.center,
              text: TextSpan(
                children: <TextSpan>[
                  TextSpan(
                    text: "Correo en uso:\n",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: 'sen-regular',
                      fontWeight: FontWeight.bold                  
                    ),
                  ),
                  TextSpan(
                    text: user.email,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                      fontWeight: FontWeight.bold
                    ),
                  )
                ]           
              ),
            ),
          ),
          const Divider(
            height: 10,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.white,
          ),
          Container(
            margin: EdgeInsets.all(10),
            width: size.width,
            height: 50,
            child: Text(
              "Protectores de racha",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontFamily: 'sen-regular'                  
              ),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/logos/perfil-1.png"),
                  radius: 30,
                )
              ),
              Expanded(
                child: CircleAvatar(
                  backgroundImage: AssetImage("assets/logos/perfil-1.png"),
                  radius: 30,
                )
              ),            
            ],
          ),
          SizedBox(height: 20),

          const Divider(
            height: 10,
            thickness: 1,
            indent: 20,
            endIndent: 20,
            color: Colors.white,
          ),

          Container(
            margin: EdgeInsets.all(10),
            width: size.width,
            height: 50,
            child: Text(
                  "Medallas",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontFamily: 'sen-regular'                  
                  ),
                ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/logos/perfil-1.png"),
                    radius: 35,
                ),
              ),
              Expanded(
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/logos/perfil-1.png"),
                    radius: 35,
                  )
              ),
              Expanded(
                  child: CircleAvatar(
                    backgroundImage: AssetImage("assets/logos/perfil-1.png"),
                    radius: 35,
                  )
              ),
              Expanded(
                child: CircleAvatar(
                    backgroundImage: AssetImage("assets/logos/perfil-1.png"),
                    radius: 35,
                  )
              ),
              
            ],

          ),
        ],
      ),
    );
  }
}