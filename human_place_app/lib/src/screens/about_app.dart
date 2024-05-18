import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:human_place_app/src/colors.dart';
//import 'package:human_place_app/src/screens/home_screen.dart';
//import 'package:human_place_app/src/routes.dart';
import 'package:human_place_app/src/screens/login_screen.dart';
import 'package:http/http.dart' as http;

class AboutPage extends StatefulWidget {
  static final routerName = '/about-page';

  @override
  _AboutPageState createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;

  // Funcion utilizada para probar POST a CloudFuntions con autenticacion

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
    final mail = user!.email;

    //WITGET INICIAL
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: CustomColors.grey,
      //APPBAR: Actualmente vacia
      appBar: AppBar(
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      //BODY: Utiliza un Stack() para poder generar el diseño de forma manual
      body: Center(
        child: Stack(
          children: [
            //IMAGEN CON DISEÑO DECORATIVO

            Container(
              width: size.width,
              height: size.height,
              alignment: Alignment.bottomCenter,
              child: RotatedBox(
                quarterTurns: 2,
                child: Image(
                  image: AssetImage('assets/images/banner-intro.png'),
                ),
              ),
            ),
            //LOGO DE LA APLICACION

            Column(
              children: [
                Spacer(),
                Container(
                  width: size.width / 1.1,
                  height: size.height / 3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage(
                        'assets/logos/humanplaceLogo.png',
                      ),
                    ),
                  ),
                ),
                //MUESTRA DE TEXTO (AÑO)

                Container(
                  alignment: Alignment.topCenter,
                  width: double.infinity,
                  height: 100,
                  child: Text('2021',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                      textScaler: TextScaler.linear(1.0)),
                ),
                Spacer(),

                // MOSTRAR CORREO DE LA CUENTA EN USO
                Container(
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(5),
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Correo en uso:\n ',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black),
                              ),
                              TextSpan(
                                text: mail,
                                style: TextStyle(
                                    fontSize: 14,
                                    color: gradientGreen,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // BOTON DE BORRAR CUENTA (NECESARIO PARA IPHONE)
                      Card(
                        color: CustomColors.newGreenPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          splashColor: CustomColors.primary.withAlpha(30),
                          onTap: () async {
                            EasyLoading.show(status: "Espere por favor...");
                            await FirebaseAuth.instance.currentUser?.delete();
                            await FirebaseAuth.instance.signOut();
                            EasyLoading.dismiss();
                            Navigator.pushNamedAndRemoveUntil(context,
                                LoginScreen.routerName, (route) => false);
                          },
                          child: SizedBox(
                            width: 250,
                            height: 50,
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(10),
                              child: Text('Borrar cuenta',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.lightGrey),
                                  textScaler: TextScaler.linear(1.0)),
                            ),
                          ),
                        ),
                      ),

                      //DEBUG
                      //BOTON TEST CON FIN DE LLEGAR A UNA PAGINA DE PRUEBA
                      //PARA COMPROBAR EL FUNCINAMIENTO CORRECTO DEL CHAT

                      /*Card(
                        color: CustomColors.newGreenPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          splashColor: CustomColors.primary.withAlpha(30),
                          onTap: () {
                            Navigator.pushNamed(context, HomeScreen.routerName,
                                arguments: {index = 0, mode = 0});
                          },
                          child: SizedBox(
                            width: 250,
                            height: 50,
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(10),
                              child: Text('test',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.lightGrey),
                                  textScaler: TextScaler.linear(1.0)),
                            ),
                          ),
                        ),
                      ),*/

                      //DEBUG
                      //BOTON CON LA UTILIDAD DE HACER UNA SOLICITUD POST A LAS
                      //CLOUD FUNTION PARA ASISTIR A LOS DESARROLLADORES DE LAS
                      //MISMAS AL MOMENTO DE PROBAR FUNCIONAMIENTO DE OAUTH.

                      /*
                      Card(
                        color: CustomColors.newGreenPrimary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: InkWell(
                          splashColor: CustomColors.primary.withAlpha(30),
                          onTap: () {
                            gettest();
                          },
                          child: SizedBox(
                            width: 250,
                            height: 50,
                            child: Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.all(10),
                              child: Text('Felipe test',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: CustomColors.lightGrey),
                                  textScaler: TextScaler.linear(1.0)),
                            ),
                          ),
                        ),
                      ),*/
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
