import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:human_place_app/src/notifiers/app.dart';
import 'package:human_place_app/src/screens/intro_slider.dart';
import 'package:human_place_app/src/screens/login_screen.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  static final routerName = '/';

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //PAGINA AL INICIAR LA APLICACION
  //MUESTRA UNA IMAGEN MIENTRAS SE COMPRUEBA QUE EL USUARIO ESTA LOGEADO

  @override
  Widget build(BuildContext context) {
    // WITGET INICIAL

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FutureBuilder(
        //ESPERAR A LA VERIFICACION
        future: timeout(context),
        builder: (context, data) {
          if (data.connectionState == ConnectionState.done) {
            return Container();
          }

          //MOSTRAR IMAGEN DE FONDO

          return splash(context);
        },
      ),
    );
  }

  //MÉTODO PARA DETERMINAR SI EL USUARIO ESTA LOGEADO O NO Y ACTUAR EN RESPUESTA

  Future<void> timeout(BuildContext context) async {
    //CONTADOR MAX DE 5 SEG PARA HACER ESTE PROCESO
    await Future.delayed(Duration(seconds: 5));

    final showSlider = await SharedPreferences.getInstance().then((value) {
      return value.getBool('show_slider') ?? true;
    });

    //SE OBTIENE EL USUARIO ACTUAL

    final currentUser = FirebaseAuth.instance.currentUser;
    String initialRoute =
        showSlider ? IntroSlider.routerName : LoginScreen.routerName;

    // SI SE VERIFICA EL USUARIO, SE REDIRIGE A LA PAGINA PRINCIPAL
    if (currentUser != null) {
      initialRoute = MainPage.routerName;
      await context.read<AppNotifier>().onLogin(currentUser.uid);
    }

    Navigator.of(context).pushReplacementNamed(initialRoute);
  }

  //WITGET QUE CONTIENE LA IMAGEN DE FONDO

  Widget splash(context) {
    return Container(
        decoration: BoxDecoration(
      image: DecorationImage(
          image: AssetImage('assets/images/splash_screen.png'),
          fit: BoxFit.cover),
    ));
  }
}
