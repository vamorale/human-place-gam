import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/notifiers/app.dart';
import 'package:human_place_app/src/routes.dart';
import 'package:human_place_app/src/screens/about_app.dart';
import 'package:human_place_app/src/screens/habit_screen.dart';
import 'package:human_place_app/src/screens/home_screen.dart';
import 'package:human_place_app/src/utils/widget_utils.dart';
import 'package:human_place_app/src/screens/profile_screen.dart';
import 'package:human_place_app/src/services/firebase.dart';
import 'package:human_place_app/src/services/plantas_control.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../logic/tutorial_logic.dart';
//import 'package:rive/rive.dart' as rive;

enum StateDay { Day, Night }

final GlobalKey intentionButtonKey = GlobalKey();
final GlobalKey mainButtonsKey = GlobalKey();
final GlobalKey profilepageButtonKey = GlobalKey();
final GlobalKey menuButtonKey = GlobalKey();

class MainPage extends StatefulWidget {
  static final routerName = '/main-page';

  MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  // DECLARACION DE VARIABLES A UTILIZAR

  // AVATAR
  String? _avatarPath;

  //OTRAS VARIABLES

  var animacionDia;
  String uid = FirebaseAuth.instance.currentUser!.uid;

  CollectionReference nameRef =
      FirebaseFirestore.instance.collection('usuarios');

  final FirebaseAuth auth = FirebaseAuth.instance;
  var userName;
  final PlantasFunctionService plantasService = PlantasFunctionService();

  final userId = FirebaseAuth.instance.currentUser!.uid;
  late StateDay stateDay;

  //MÉTODOS
  //

  //MÉTODO PARA OBTENER LA HORA DEL DIA

  String get HoraDia {
    DateTime now = DateTime.now();

    if (now.hour > 5 && now.hour < 20) {
      stateDay = StateDay.Day;
      print(stateDay);
      return 'sesión del día';
    } else {
      stateDay = StateDay.Night;
      print(stateDay);
      return 'sesión nocturna';
    }
  }

  void initState() {
    this.getName();
    _loadAvatar();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkTutorialForView(context, "home");
    });
  }

  Future<void> _loadAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _avatarPath = prefs.getString('selectedAvatar');
    });
  }

  //MÉTODO PARA OBTENER EL NOMBRE DEL USUSARIO

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

  //MÉTODO PARA GENERAR TEXTO DE BIENVENIDA DICHO POR SAM

  void inputData() {
    final User? user = auth.currentUser;
    print('user: ' + user.toString());
    final uid = user!.displayName;
    userName = uid;
    print(userName);
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    Size size = MediaQuery.of(context).size;

    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      checkTutorialForView(context, "mainpage");
    }); */

    //var urlAnimacionMain;
    var activeColorGradLight;
    var activeColorGradDark;

    //DECLARAR COLORES SEGUN LA HORA DEL DIA

    if (HoraDia == 'sesión del día') {
      activeColorGradLight = CustomColors.newPinkSecondary;
      activeColorGradDark = CustomColors.newPurpleSecondary;
    } else {
      activeColorGradLight = CustomColors.newPinkSecondary;
      activeColorGradDark = CustomColors.newPurpleSecondary;
    }

    context.read<AppNotifier>().fetchAnimacion();

    return Consumer<AppNotifier>(
      builder: (context, state, _) {
        // SE CARGAN LAS ANIMACIONES

        if (state.hasLoading(AppAction.FetchMedia) == true) {
          return const Text('');
        }
        if (state.hasError(AppAction.FetchMedia) == true) {
          return Center(child: Text('Error al cargar la animación'));
        }
        for (var i = 0; i < state.animacion.length; i++) {
          if (state.animacion[i].title == 'animacion inicio') {
            //urlAnimacionMain = state.animacion[i].url;
            //animacionDia = 'dia ' + getSession.THISsession.toString();
          }
          if (state.animacion[i].title == 'plantas') {
            //urlAnimacionPlantas = state.animacion[i].url;

            //animacionDia = 'dia ' + getSession.THISsession.toString();
          }
        }
        //Se precarga la imagen de la nuve para la galeria de plantas
        precacheImage(AssetImage("assets/images/Cloud.png"), context);
        precacheImage(AssetImage("assets/images/CloudNight.png"), context);

        // WITGET INICIAL

        return Scaffold(
            resizeToAvoidBottomInset: false,
            extendBodyBehindAppBar: true,
            backgroundColor: CustomColors.grey,

            //APPBAR: CONTIENE MENU DEPLEGABLE
            //PARA NAVEGAR A OTRAS PAGINAS

            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,

              //ICONBUTTON: BOTÓN PARA ACCEDER AL PERFIL DEL USUARIO

              leading: Container(
                
                margin: EdgeInsets.only(top: 10, left: 10),
                padding: EdgeInsets.all(0),
                
                child: IconButton(
                  key: profilepageButtonKey,
                  
                  onPressed: () =>
                      {Navigator.pushNamed(context, ProfileScreen.routerName)},
                  icon: _avatarPath != null
                      ? CircleAvatar(
                          backgroundImage: AssetImage(_avatarPath!),
                          radius: 50,
                        )
                      : CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 40),
                        ),
                  style: IconButton.styleFrom(
                    elevation: 1,
                    padding: EdgeInsets.all(0),
                    side: BorderSide(width: 2, color: Colors.black),
                    fixedSize: Size.square(45),
                  ),
                ),
              ),

              actions: [
                // CONTENEDOR CON MENU DESPLEGABLE

                Container(
                  margin: EdgeInsets.only(right: 10, top: 10),
                  width: 45,
                  height: 45,
                  child: PopupMenuButton(
                    
                  key: menuButtonKey,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    /* color: Colors.white, */
                    onSelected: (opcion) {
                      if (opcion == 'info') {
                        Navigator.pushNamed(context, AboutPage.routerName);
                      } else {
                        Navigator.pushNamed(context, HomeScreen.routerName,
                            arguments: {index = 1, mode = 1});
                      }
                    },
                    itemBuilder: (context) => [
                      // LISTA DE OPCIONES EN EL MENU DESPLEGABLE}

                      // NAVEGACION A "ACERCA DE..."

                      PopupMenuItem(
                        value: 'info',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.info,
                              color: Colors.black,
                            ),
                            Text(' Acerca de',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),

                      // NAVEGACION A "BIBLIOTECA"

                      PopupMenuItem(
                        value: 'biblio',
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.local_library,
                              color: Colors.black,
                            ),
                            Text(' Biblioteca',
                                style: TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold))
                          ],
                        ),
                      ),
                    ],

                    // BOTON DE HUMAN PLACE PARA DESPLEGAR MENU

                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        /* image: DecorationImage(
                           image: const AssetImage(
                            'assets/logos/brand_new_logo_hp.png',
                          ), 
                        ), */
                      ),
                      child: Icon(
                        Icons.menu,
                        color: CustomColors.newPinkSecondary,
                        size: 30,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // BODY:
            // SE UTILIZA UNA COLUMNA Y STACK PARA HACER LA ESTRUCTURA

            body: Center(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomLeft,
                    children: [
                      // ANIMACION DEL PAISAJE DE FONDO

                      Container(
                        width: size.width,
                        height: size.height,
                        child: Image(
                            image: stateDay == StateDay.Day
                                ? AssetImage('assets/images/bg.png')
                                : AssetImage('assets/images/night.png'),
                            fit: BoxFit.fill),
                      ),

                      /*child: rive.RiveAnimation.network(
                          urlAnimacionMain,
                          artboard: 'observatorio',
                          antialiasing: false,
                          fit: BoxFit.fill,
                          placeHolder: Container(
                              width: size.width,
                              height: size.height,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage(
                                        'assets/images/bg-blurred.png'),
                                    fit: BoxFit.fill),
                              )),
                        ),
                      ), */

                      // IMAGEN DE SAM

                      Container(
                        margin: EdgeInsets.only(left: 18),
                        width: 100,
                        height: size.height / 3,
                        child: Image(
                            image: AssetImage('assets/images/gato_sam.png')),
                      ),

                      //Easter Egg

                      Visibility(
                        visible: false,
                        child: Positioned(
                            left: 5,
                            top: size.height / 4.7,
                            child: Container(
                              width: 40,
                              child: Image(
                                  image: AssetImage(
                                      "assets/images/personajes/tucuquere.png")),
                            )),
                      ),

                      //LISTA DE ESPACIOS INTERACTUABLES DEL PAISAJE
                      //NOTA: ESTA LISTA CONTIENE EL MENSAJE DE SAM

                      Container(
                        width: size.width,
                        height: size.height,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            // ESPACIO INTERACTUABLE DEL PAISAJE
                            //UTILIZADO PARA NAVEGAR A "HERRAMIENTAS ATENCION"
                            SizedBox(
                              height: 70,
                            ),

                            Column(key: mainButtonsKey, children: [
                              Container(
                                margin: EdgeInsets.fromLTRB(
                                    size.width / 12, 10, size.width / 12, 10),
                                padding: EdgeInsets.all(5),
                                width: size.width,
                                height: size.height / 7,
                                child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.cloud,
                                      size: 30,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, HomeScreen.routerName,
                                          arguments: {index = 2, mode = 4});
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.lightBlueAccent
                                            .withOpacity(0.7),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                    label: ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      title: Text(
                                        'Herramientas de atención',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'sen-regular',
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Meditaciones, reformula tus pensamientos, define tu propósito y más.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'sen-regular'),
                                      ),
                                    )),
                              ),
                              //Spacer(),

                              // ESPACIO INTERACTUABLE DEL PAISAJE
                              //UTILIZADO PARA NAVEGAR A "HERRAMIENTAS DEl PROPÓSITO"

                              Container(
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.symmetric(
                                    horizontal: size.width / 12, vertical: 10),
                                width: size.width,
                                height: size.height / 7,
                                child: Tooltip(
                                  message: '¡Próximamente!',
                                  decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.8),
                                      borderRadius:
                                          BorderRadius.all(Radius.circular(5))),
                                  triggerMode: TooltipTriggerMode.tap,
                                  height: 20,
                                  margin: EdgeInsets.all(10),
                                  preferBelow: true,
                                  showDuration: Duration(seconds: 2),
                                  child: ElevatedButton.icon(
                                      icon: Icon(
                                        Icons.landscape,
                                        size: 30,
                                        color: Colors.black54,
                                      ),
                                      onPressed: null,
                                      /* () {
                                      Navigator.pushNamed(
                                          context, HomeScreen.routerName,
                                          arguments: {index = 2, mode = 6});
                                    },*/
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              Colors.blueGrey.withOpacity(0.9),
                                          //foregroundColor: Colors.white,
                                          disabledBackgroundColor:
                                              Colors.blueGrey.withOpacity(0.8),
                                          //disabledForegroundColor: Colors.amberAccent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20))),
                                      label: ListTile(
                                        contentPadding:
                                            EdgeInsets.symmetric(horizontal: 5),
                                        title: Text(
                                          'Herramientas del propósito',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'sen-regular',
                                              fontWeight: FontWeight.bold),
                                        ),
                                        subtitle: Text(
                                          'Define tu objetivo diario o a largo plazo.',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 14,
                                              fontFamily: 'sen-regular'),
                                        ),
                                      )),
                                ),
                              ),

                              // ESPACIO INTERACTUABLE DEL PAISAJE
                              //UTILIZADO PARA NAVEGAR A "HERRAMIENTAS DE LAS COMUNIDADES"
                              Container(
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.symmetric(
                                    horizontal: size.width / 12, vertical: 10),
                                width: size.width,
                                height: size.height / 7,
                                child: ElevatedButton.icon(
                                    icon: Icon(
                                      Icons.forest,
                                      size: 30,
                                      color: Colors.black54,
                                    ),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, HomeScreen.routerName,
                                          arguments: {index = 2, mode = 3});
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.greenAccent.withOpacity(0.7),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                    label: ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      title: Text(
                                        'Herramientas de las comunidades',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'sen-regular',
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Encuentra apoyo y participa del estudio de salud mental.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'sen-regular'),
                                      ),
                                    )),
                              ),

                              // ESPACIO INTERACTUABLE DEL PAISAJE
                              //UTILIZADO PARA NAVEGAR A "HERRAMIENTAS DE INTENCION"

                              Container(
                                key: intentionButtonKey,
                                padding: EdgeInsets.all(5),
                                margin: EdgeInsets.symmetric(
                                    horizontal: size.width / 12, vertical: 10),
                                width: size.width,
                                height: size.height / 7,
                                child: ElevatedButton.icon(
                                    icon: Icon(Icons.compost,
                                        size: 30, color: Colors.black54),
                                    onPressed: () {
                                      Navigator.pushNamed(
                                          context, HabitScreen.routerName);
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            Colors.lightGreen.withOpacity(0.7),
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(20))),
                                    label: ListTile(
                                      contentPadding:
                                          EdgeInsets.symmetric(horizontal: 5),
                                      title: Text(
                                        'Herramientas de intención',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'sen-regular',
                                            fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Text(
                                        'Planta tus hábitos y practícalos en una conversación.',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontFamily: 'sen-regular'),
                                      ),
                                    )),
                              ),
                            ]),

                            //Spacer(),

                            // MENSAJE DE SAM DE BIENVENIDA

                            Container(
                              alignment: Alignment.topCenter,
                              padding: EdgeInsets.only(bottom: 5),
                              margin: EdgeInsets.only(
                                  top: 10, left: size.width / 6),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(20),
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20)),
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: [
                                      activeColorGradDark,
                                      activeColorGradLight
                                    ],
                                  ),
                                ),
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, HomeScreen.routerName,
                                        arguments: {index = 2, mode = 0});
                                  },
                                  icon: Icon(
                                    MdiIcons.messageFastOutline,
                                    size: 30,
                                    color: Colors.white,
                                  ),
                                  label: Text(
                                    '¡Hola, ' + userName + '!',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontFamily: 'sen-regular',
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ));
      },
    );
  }
}
