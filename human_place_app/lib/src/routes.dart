import 'package:flutter/material.dart';
import 'package:human_place_app/src/screens/habit_screen.dart';
import 'package:human_place_app/src/screens/home_screen.dart';
import 'package:human_place_app/src/screens/intro_slider.dart';
import 'package:human_place_app/src/screens/login_screen.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:human_place_app/src/screens/about_app.dart';
//import 'package:human_place_app/src/screens/pages/Guide_page.dart';
//import 'package:human_place_app/src/screens/plants-gallery.dart';
import 'package:human_place_app/src/screens/splash_screen.dart';
import 'package:human_place_app/src/screens/profile_screen.dart';

int index = 0;
int mode = 0;
int session = 0;

// Lista de rutas de la App
// NOTA: El navegador lee de arriba a abajo de forma ordenada
// En caso de no indicar una ruta especifica a la que navegar

final routes = {
  SplashScreen.routerName: (BuildContext context) => SplashScreen(),
  IntroSlider.routerName: (BuildContext context) => IntroSlider(),
  LoginScreen.routerName: (BuildContext context) => LoginScreen(),
  HomeScreen.routerName: (BuildContext context) => HomeScreen(index, mode),
  MainPage.routerName: (BuildContext context) => MainPage(),
  AboutPage.routerName: (BuildContext context) => AboutPage(),
  //GaleriaPlantas.routerName: (BuildContext context) => GaleriaPlantas(),
  //GuidePage.routerName: (BuildContext context) => GuidePage(),
  ProfileScreen.routerName: (BuildContext context) => ProfileScreen(),
  HabitScreen.routerName: (BuildContext context) => HabitScreen()
};
