import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/notifiers/app.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:human_place_app/src/utils/app.dart';
import 'package:provider/provider.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class LoginScreen extends StatefulWidget {
  static final routerName = '/login-screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  //MÉTODO PARA LLEVAR A CABO EL LOGIN
  bool loggedIn = false;
  void _handleLogin(String provider) async {
    try {
      UserCredential? uc;
      if (provider == 'google') {
        uc = await signInWithGoogle();
      } else {
        uc = await signInWithApple();
      }
      if (uc.user != null) {
        loggedIn = true;
        await context.read<AppNotifier>().onLogin(uc.user!.uid);
        Navigator.pushNamedAndRemoveUntil(
          context,
          MainPage.routerName,
          (route) => false,
        );
      }
    } on FirebaseException catch (e) {
      print("Exception: $e");
      //EasyLoading.showToast(e.message);
    } catch (e) {
      print("Exception: $e");
      EasyLoading.showToast('Ha ocurrido un error');
    }
  }

  //MÉTODO PARA LOGUEAR CON GOOGLE

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      GoogleAuthProvider googleAuthProvider = GoogleAuthProvider();

      return FirebaseAuth.instance.signInWithPopup(googleAuthProvider);
    }
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return FirebaseAuth.instance.signInWithCredential(credential);
  }

  //MÉTODO PARA LOGUEAR CON APPLE

  Future<UserCredential> signInWithApple() async {
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      nonce: nonce,
    );

    final oauthCredential = OAuthProvider("apple.com").credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
    );

    return await FirebaseAuth.instance.signInWithCredential(oauthCredential);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // WITGET INICIAL

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        // FONDO DE LA PAGINA

        child: Container(
          height: size.height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  CustomColors.newPinkSecondary,
                  CustomColors.newPurpleSecondary,
                  CustomColors.grey
                ],
                stops: [
                  0.10,
                  0.5,
                  0.5
                ]),
          ),

          // SE UTILIZA UNA COLUMNA PARA SIPONER LA INFORMACION

          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // MOSTRAR LOGO DE HUMAN PLACE

              Container(
                margin: EdgeInsets.all(20),
                height: size.height / 5,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                      'assets/logos/logo-hp-intro.png',
                    ),
                  ),
                ),
              ),

              // CONTENEDOR DE MENSAJES AL USUARIO EN PANTALLA

              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding:
                    EdgeInsets.only(left: 15, right: 15, top: 20, bottom: 20),
                width: size.width - 40,
                decoration: BoxDecoration(
                  border:
                      Border.all(width: 1, color: CustomColors.newGreenPrimary),
                  borderRadius: BorderRadius.circular(20),
                  color: CustomColors.lightGrey.withOpacity(0.9),
                ),
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.centerLeft,
                      child: Text('¡Bienvenid@!',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontSize: 25,
                            fontFamily: 'sen-regular',
                            fontWeight: FontWeight.bold,
                            color: CustomColors.newGreenPrimary,
                          ),
                          textScaler: TextScaler.linear(1.0)),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      child: Text(
                          '¿Te atreves a iniciar este desafío de calidad de vida? Inicia sesión con Google o Apple para comenzar.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'sen-regular',
                            color: Colors.black,
                          ),
                          textScaler: TextScaler.linear(1.0)),
                    ),
                  ],
                ),
              ),

              // ESPACIO EXTRA PARA SEPARACION

              SizedBox(
                height: 50,
              ),

              // BOTONES CONTROLADORES DE LOGIN

              Column(
                children: [
                  // BOTON PARA GOOGLE

                  Container(
                    width: size.width * 7 / 8,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: new BorderRadius.circular(20),
                        ),
                      ),
                      onPressed: () => _handleLogin('google'),
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              CustomColors.newPurpleSecondary,
                              CustomColors.newPinkSecondary
                            ],
                          ),
                          borderRadius: new BorderRadius.circular(20),
                        ),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                height: 25,
                                width: 25,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage(
                                      'assets/icons/google-icon-white.png',
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Text(
                                'Iniciar sesión con Google',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'sen-regular',
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // BOTON PARA APPLE

                  if (Platform.isIOS)
                    SizedBox(
                      height: 15,
                    ),
                  if (Platform.isIOS)
                    Container(
                      width: size.width * 7 / 8,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () => _handleLogin('apple'),
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Colors.black, grey],
                            ),
                            borderRadius: new BorderRadius.circular(20),
                          ),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 25,
                                  width: 25,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage(
                                        'assets/icons/apple-white-logo.png',
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 14,
                                ),
                                Text(
                                  'Iniciar sesión con Apple',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontFamily: 'sen-regular',
                                    fontWeight: FontWeight.w600,
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
