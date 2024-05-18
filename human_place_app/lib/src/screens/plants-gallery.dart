import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/screens/home_screen.dart';
import 'package:human_place_app/src/routes.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:rive/rive.dart' as rive;
import '../notifiers/app.dart';
import '../services/plantas_control.dart';

class GaleriaPlantas extends StatefulWidget {
  static final routerName = '/galeria-plantas';
  @override
  _GaleriaPlantasState createState() => _GaleriaPlantasState();
}

class _GaleriaPlantasState extends State<GaleriaPlantas> {
  // DECLARACION DE VARIABLES

  late Color indicadorScrollDiurno;
  late Color indicadorScrollNocturno;
  late String imagennube;

  late DateTime fecha;

  Color colorSuperior = Colors.transparent;
  Color colorInferior = Colors.transparent;

  final FirebaseAuth auth = FirebaseAuth.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final PlantasFunctionService plantasService = PlantasFunctionService();

  var plantas;

  //Controladores de los Scrolls de la galeria

  ScrollController scrollControllerdiurnos = ScrollController();
  ScrollController scrollControllernocturnos = ScrollController();

  //MÉTODO PARA OBTENER LISTA DE PLANTAS DEL USUARIO

  Future getPlantas() async {
    plantas = await plantasService.detectPlantas(userId);
  }

  @override
  Widget build(BuildContext context) {
    //DECLARACION DE VARIABLES

    Size size = MediaQuery.of(context).size;
    List<Widget> plantasDiurnas = [];
    List<Widget> plantasNocturnas = [];

    //OBTENCION DE HORA DEL DISPOSITIVO PARA DETERMINAR COLORES DEL FONDO

    fecha = DateTime.now();
    print("Hora actual:" + fecha.hour.toString());
    print("Minuto actual:" + fecha.minute.toString());
    if (fecha.hour >= 8 && fecha.hour < 20) {
      colorSuperior = Color(0xff185180);
      colorInferior = Color(0xff95C2B8);
      imagennube = 'assets/images/Cloud.png';
    } else {
      colorSuperior = Color.fromARGB(255, 25, 14, 45);
      colorInferior = Color.fromARGB(255, 20, 29, 94);
      imagennube = 'assets/images/CloudNight.png';
    }
    var urlAnimacionPlantas;
    context.read<AppNotifier>().fetchAnimacion();

    return Consumer<AppNotifier>(builder: (context, state, _) {
      // SE CARGAN LAS ANIMACIONES

      if (state.hasLoading(AppAction.FetchMedia) == true) {
        return const Text('');
      }
      if (state.hasError(AppAction.FetchMedia) == true) {
        return Center(child: Text('Error al cargar la animación'));
      }

      //MÉTODO PAARA ENTREGAR IMAGEN CORRECTA DE LA ETAPA DE LAS PLANTAS

      String imageEtapa(String etapa) {
        switch (etapa) {
          case 'germinacion':
            return 'assets/images/germinacion.png';

          case 'crecimiento':
            return 'assets/images/crecimiento.png';

          case 'reproduccion':
            return 'assets/images/reproduccion.png';

          case 'muerte':
            return 'assets/images/muerte.png';

          default:
            return '';
        }
      }

      //MÉTODO PARA DETERMINAR SI SE PUEDE O NO REGAR LA PLANTA

      bool regarDisponible(int disponible) {
        switch (disponible) {
          case 1:
            return true;
          case 0:
            return false;

          default:
            return false;
        }
      }

      // EN CASO DE EXITO SE INICIA

      for (var i = 0; i < state.animacion.length; i++) {
        if (state.animacion[i].title == 'plantas') {
          // DECLARAR LINK PARA LAS ANIMACIONES DE LAS PLANTAS
          urlAnimacionPlantas = 'assets/animationsRive/plantas.riv';

          // WITGET INICIAL

          return FutureBuilder(
            // SE EMPIEZAN A OBTENER LAS PLANTAS DEL USUARIO EN SU ESTADO
            // Y EN SU CORRESPONDIENTE HORA EN QUE SE ADOPTO

            future: getPlantas(),
            builder: (context, snapshot) {
              // POR CADA PLANTA EN LA LISTA DE PLANTAS DEL USUARIO SE REVISA:
              //- TIPO DE PLANTA
              //- SI ES DIURNA O NOCTURNA
              //
              // FINALMENTE SE AÑADE LA VISUALIZACION DE LAS PLANTAS IDENTIFICADAS
              // A UNA LISTA DE WITGET QUE SE MOSTRARAN EN LA PAGINA

              if (snapshot.connectionState == ConnectionState.done) {
                for (var i = 0; i < plantas.habits.length; i++) {
                  // SE COMPRUEBA SI LA PLANTA ES:
                  //- TOMATE
                  //- CEBOLLIN
                  //- REPOLLO

                  switch (plantas.habits[i]['planta']) {
                    // SE IDENTIFICA TOMATE
                    case 'Tomate':
                      print(plantas.habits);

                      // VERSION DE LA PLANTA DIURNA

                      if (plantas.habits[i]['horario'] == 'Diurno') {
                        // SE AÑADE A LA LISTA DE WITGETS A MOSTRAR

                        plantasDiurnas.add(
                          // WITGET BASE DE LA PLANTA
                          // SE UTILIZA UN STACK COMO BASE PARA VISUALIZAR LAS PLANTAS

                          Container(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // MOSTRAR ESTADO ACTUAL DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: size.height / 1.5,
                                      alignment: Alignment.center,
                                      child: rive.RiveAnimation.asset(
                                        urlAnimacionPlantas,
                                        artboard: 'Tomate',
                                        animations: [
                                          plantas.habits[i]['etapa_animacion']
                                                  .toString() +
                                              '_idle'
                                        ],
                                        antialiasing: false,
                                        fit: BoxFit.scaleDown,
                                        placeHolder: Image(
                                          image: AssetImage(
                                              'assets/images/growing.gif'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 2 / 21,
                                    )
                                  ],
                                ),

                                // MOSTRAR MACETA

                                Container(
                                  height: (size.height * 4 / 15),
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        'assets/images/maceta-galeria.png'),
                                  ),
                                ),

                                // MOSTRAR BOTON Y INDICADOR DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //TEXTO DESCRIPTIVO DE LA PLANTA, MUESTRA:
                                    //-DIA ACTUAL DE LA PLANTA
                                    //-TIPO DE PLANTA
                                    //-ICONO DEL ESTADO ACTUAL DE LA PLANTA

                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.cyan
                                                  ]),
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(40)),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                'Día ' +
                                                    plantas.habits[i]
                                                            ['riegos_totales']
                                                        .toString() +
                                                    " de tu planta de " +
                                                    plantas.habits[i]['planta']
                                                        .toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // BOTON DE "REGAR PLANTA"
                                    // APARECE SOLO CUANDO SE PUEDE REGAR:
                                    //-UNA VEZ AL DIA
                                    //-NO MAS VECES A LA SEMANA DE LO PERMITIDO
                                    // POR LA PLANTA

                                    Visibility(
                                      maintainSize: true,
                                      maintainAnimation: true,
                                      maintainState: true,
                                      visible: regarDisponible(
                                          plantas.habits[i]['regable']),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 20, bottom: 30),
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20)),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                CustomColors.newPurpleSecondary,
                                                CustomColors.newPinkSecondary,
                                              ],
                                            ),
                                          ),
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                        bottomRight:
                                                            Radius.circular(20),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                20)),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  HomeScreen.routerName,
                                                  arguments: {
                                                    index = 2,
                                                    mode = 5
                                                  });
                                            },
                                            icon: Image(
                                                width: 40,
                                                height: 40,
                                                image: AssetImage(
                                                  imageEtapa(plantas.habits[i]
                                                      ['etapa_actual']),
                                                )),
                                            label: Text(
                                              'Regar ahora',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontFamily: 'sen-regular',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: size.width,
                                        alignment: Alignment.centerRight,
                                        margin: EdgeInsets.only(
                                            bottom: 10, right: 15),
                                        child: Text('  '))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // VERSION DE LA PLANTA NOCTURNA

                      else {
                        // SE AÑADE A LA LISTA DE WITGETS A MOSTRAR

                        plantasNocturnas.add(
                          // WITGET BASE DE LA PLANTA
                          // SE UTILIZA UN STACK COMO BASE PARA VISUALIZAR LAS PLANTAS

                          Container(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // MOSTRAR ESTADO ACTUAL DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: size.height / 1.5,
                                      alignment: Alignment.center,
                                      child: rive.RiveAnimation.asset(
                                        urlAnimacionPlantas,
                                        artboard: 'Tomate',
                                        animations: [
                                          plantas.habits[i]['etapa_animacion']
                                                  .toString() +
                                              '_idle'
                                        ],
                                        antialiasing: false,
                                        fit: BoxFit.scaleDown,
                                        placeHolder: Image(
                                          image: AssetImage(
                                              'assets/images/growing.gif'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height * 2 / 21,
                                    )
                                  ],
                                ),

                                // MOSTRAR MACETA

                                Container(
                                  height: (size.height * 4 / 15),
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        'assets/images/maceta-galeria.png'),
                                  ),
                                ),

                                // MOSTRAR BOTON Y INDICADOR DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //TEXTO DESCRIPTIVO DE LA PLANTA, MUESTRA:
                                    //-DIA ACTUAL DE LA PLANTA
                                    //-TIPO DE PLANTA
                                    //-ICONO DEL ESTADO ACTUAL DE LA PLANTA

                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.deepPurple,
                                                    Colors.black
                                                  ]),
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(40)),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                'Día ' +
                                                    plantas.habits[i]
                                                            ['riegos_totales']
                                                        .toString() +
                                                    " de tu planta de " +
                                                    plantas.habits[i]['planta']
                                                        .toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // BOTON DE "REGAR PLANTA"
                                    // APARECE SOLO CUANDO SE PUEDE REGAR:
                                    //-UNA VEZ AL DIA
                                    //-NO MAS VECES A LA SEMANA DE LO PERMITIDO
                                    // POR LA PLANTA

                                    Visibility(
                                      maintainSize: true,
                                      maintainAnimation: true,
                                      maintainState: true,
                                      visible: regarDisponible(
                                          plantas.habits[i]['regable']),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 20, bottom: 30),
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20)),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                CustomColors.newPurpleSecondary,
                                                CustomColors.newPinkSecondary,
                                              ],
                                            ),
                                          ),
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                        bottomRight:
                                                            Radius.circular(20),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                20)),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  HomeScreen.routerName,
                                                  arguments: {
                                                    index = 2,
                                                    mode = 5
                                                  });
                                            },
                                            icon: Image(
                                              width: 40,
                                              height: 40,
                                              image: AssetImage(
                                                imageEtapa(plantas.habits[i]
                                                    ['etapa_actual']),
                                              ),
                                            ),
                                            label: Text(
                                              'Regar ahora',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontFamily: 'sen-regular',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: size.width,
                                        alignment: Alignment.centerRight,
                                        margin: EdgeInsets.only(
                                            bottom: 10, right: 15),
                                        child: Text('  '))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      ;

                      break;

                    // SE IDENTIFICA REPOLLO

                    case 'Repollo':

                      // VERSION DE LA PLANTA DIURNA

                      if (plantas.habits[i]['horario'] == 'Diurno') {
                        // SE AÑADE A LA LISTA DE WITGETS A MOSTRAR

                        plantasDiurnas.add(
                          // WITGET BASE DE LA PLANTA
                          // SE UTILIZA UN STACK COMO BASE PARA VISUALIZAR LAS PLANTAS

                          Container(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // MOSTRAR ESTADO ACTUAL DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: size.height / 1.5,
                                      alignment: Alignment.center,
                                      child: rive.RiveAnimation.asset(
                                        urlAnimacionPlantas,
                                        artboard: 'Repollo',
                                        animations: [
                                          plantas.habits[i]['etapa_animacion']
                                              .toString()
                                        ],
                                        antialiasing: false,
                                        fit: BoxFit.scaleDown,
                                        placeHolder: Image(
                                          image: AssetImage(
                                              'assets/images/growing.gif'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height / 10,
                                    )
                                  ],
                                ),

                                // MOSTRAR MACETA

                                Container(
                                  height: (size.height * 4 / 15),
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        'assets/images/maceta-galeria.png'),
                                  ),
                                ),

                                // MOSTRAR BOTON Y INDICADOR DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //TEXTO DESCRIPTIVO DE LA PLANTA, MUESTRA:
                                    //-DIA ACTUAL DE LA PLANTA
                                    //-TIPO DE PLANTA
                                    //-ICONO DEL ESTADO ACTUAL DE LA PLANTA

                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.cyan
                                                  ]),
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(40)),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                'Día ' +
                                                    plantas.habits[i]
                                                            ['riegos_totales']
                                                        .toString() +
                                                    " de tu planta de " +
                                                    plantas.habits[i]['planta']
                                                        .toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // BOTON DE "REGAR PLANTA"
                                    // APARECE SOLO CUANDO SE PUEDE REGAR:
                                    //-UNA VEZ AL DIA
                                    //-NO MAS VECES A LA SEMANA DE LO PERMITIDO
                                    // POR LA PLANTA

                                    Visibility(
                                      maintainSize: true,
                                      maintainAnimation: true,
                                      maintainState: true,
                                      visible: regarDisponible(
                                          plantas.habits[i]['regable']),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 20, bottom: 30),
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20)),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                CustomColors.newPurpleSecondary,
                                                CustomColors.newPinkSecondary,
                                              ],
                                            ),
                                          ),
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                        bottomRight:
                                                            Radius.circular(20),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                20)),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  HomeScreen.routerName,
                                                  arguments: {
                                                    index = 2,
                                                    mode = 5
                                                  });
                                            },
                                            icon: Image(
                                              width: 40,
                                              height: 40,
                                              image: AssetImage(
                                                imageEtapa(plantas.habits[i]
                                                    ['etapa_actual']),
                                              ),
                                            ),
                                            label: Text(
                                              'Regar ahora',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontFamily: 'sen-regular',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: size.width,
                                        alignment: Alignment.centerRight,
                                        margin: EdgeInsets.only(
                                            bottom: 10, right: 15),
                                        child: Text('  '))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // VERSION DE LA PLANTA NOCTURNA

                      else {
                        // SE AÑADE A LA LISTA DE WITGETS A MOSTRAR

                        plantasNocturnas.add(
                          // WITGET BASE DE LA PLANTA
                          // SE UTILIZA UN STACK COMO BASE PARA VISUALIZAR LAS PLANTAS

                          Container(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // MOSTRAR ESTADO ACTUAL DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: size.height / 1.5,
                                      alignment: Alignment.center,
                                      child: rive.RiveAnimation.asset(
                                        urlAnimacionPlantas,
                                        artboard: 'Repollo',
                                        animations: [
                                          plantas.habits[i]['etapa_animacion']
                                              .toString()
                                        ],
                                        antialiasing: false,
                                        fit: BoxFit.scaleDown,
                                        placeHolder: Image(
                                          image: AssetImage(
                                              'assets/images/growing.gif'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height / 10,
                                    )
                                  ],
                                ),

                                // MOSTRAR MACETA

                                Container(
                                  height: (size.height * 4 / 15),
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        'assets/images/maceta-galeria.png'),
                                  ),
                                ),

                                // MOSTRAR BOTON Y INDICADOR DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //TEXTO DESCRIPTIVO DE LA PLANTA, MUESTRA:
                                    //-DIA ACTUAL DE LA PLANTA
                                    //-TIPO DE PLANTA
                                    //-ICONO DEL ESTADO ACTUAL DE LA PLANTA

                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.deepPurple,
                                                    Colors.black
                                                  ]),
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(40)),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                'Día ' +
                                                    plantas.habits[i]
                                                            ['riegos_totales']
                                                        .toString() +
                                                    " de tu planta de " +
                                                    plantas.habits[i]['planta']
                                                        .toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // BOTON DE "REGAR PLANTA"
                                    // APARECE SOLO CUANDO SE PUEDE REGAR:
                                    //-UNA VEZ AL DIA
                                    //-NO MAS VECES A LA SEMANA DE LO PERMITIDO
                                    // POR LA PLANTA

                                    Visibility(
                                      maintainSize: true,
                                      maintainAnimation: true,
                                      maintainState: true,
                                      visible: regarDisponible(
                                          plantas.habits[i]['regable']),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 20, bottom: 30),
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20)),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                CustomColors.newPurpleSecondary,
                                                CustomColors.newPinkSecondary,
                                              ],
                                            ),
                                          ),
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                        bottomRight:
                                                            Radius.circular(20),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                20)),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  HomeScreen.routerName,
                                                  arguments: {
                                                    index = 2,
                                                    mode = 5
                                                  });
                                            },
                                            icon: Image(
                                              width: 40,
                                              height: 40,
                                              image: AssetImage(
                                                imageEtapa(plantas.habits[i]
                                                    ['etapa_actual']),
                                              ),
                                            ),
                                            label: Text(
                                              'Regar ahora',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontFamily: 'sen-regular',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: size.width,
                                        alignment: Alignment.centerRight,
                                        margin: EdgeInsets.only(
                                            bottom: 10, right: 15),
                                        child: Text('  '))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      ;

                      break;

                    // SE IDENTIFICA CEBOLLIN

                    case 'Cebollín':

                      // VERSION DE LA PLANTA DIURNA

                      if (plantas.habits[i]['horario'] == 'Diurno') {
                        // SE AÑADE A LA LISTA DE WITGETS A MOSTRAR

                        plantasDiurnas.add(
                          // WITGET BASE DE LA PLANTA
                          // SE UTILIZA UN STACK COMO BASE PARA VISUALIZAR LAS PLANTAS

                          Container(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // MOSTRAR ESTADO ACTUAL DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: size.height / 1.5,
                                      alignment: Alignment.center,
                                      child: rive.RiveAnimation.asset(
                                        urlAnimacionPlantas,
                                        artboard: 'Cebollín',
                                        animations: [
                                          plantas.habits[i]['etapa_animacion']
                                                  .toString() +
                                              '_idle'
                                        ],
                                        antialiasing: false,
                                        fit: BoxFit.scaleDown,
                                        placeHolder: Image(
                                          image: AssetImage(
                                              'assets/images/growing.gif'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height / 15,
                                    )
                                  ],
                                ),

                                // MOSTRAR MACETA

                                Container(
                                  height: (size.height * 4 / 15),
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        'assets/images/maceta-galeria.png'),
                                  ),
                                ),

                                // MOSTRAR BOTON Y INDICADOR DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //TEXTO DESCRIPTIVO DE LA PLANTA, MUESTRA:
                                    //-DIA ACTUAL DE LA PLANTA
                                    //-TIPO DE PLANTA
                                    //-ICONO DEL ESTADO ACTUAL DE LA PLANTA

                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.blue,
                                                    Colors.cyan
                                                  ]),
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(40)),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                'Día ' +
                                                    plantas.habits[i]
                                                            ['riegos_totales']
                                                        .toString() +
                                                    " de tu planta de " +
                                                    plantas.habits[i]['planta']
                                                        .toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // BOTON DE "REGAR PLANTA"
                                    // APARECE SOLO CUANDO SE PUEDE REGAR:
                                    //-UNA VEZ AL DIA
                                    //-NO MAS VECES A LA SEMANA DE LO PERMITIDO
                                    // POR LA PLANTA

                                    Visibility(
                                      maintainSize: true,
                                      maintainAnimation: true,
                                      maintainState: true,
                                      visible: regarDisponible(
                                          plantas.habits[i]['regable']),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 20, bottom: 30),
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20)),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                CustomColors.newPurpleSecondary,
                                                CustomColors.newPinkSecondary,
                                              ],
                                            ),
                                          ),
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                        bottomRight:
                                                            Radius.circular(20),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                20)),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  HomeScreen.routerName,
                                                  arguments: {
                                                    index = 2,
                                                    mode = 5
                                                  });
                                            },
                                            icon: Image(
                                              width: 40,
                                              height: 40,
                                              image: AssetImage(
                                                imageEtapa(plantas.habits[i]
                                                    ['etapa_actual']),
                                              ),
                                            ),
                                            label: Text(
                                              'Regar ahora',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontFamily: 'sen-regular',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: size.width,
                                        alignment: Alignment.centerRight,
                                        margin: EdgeInsets.only(
                                            bottom: 10, right: 15),
                                        child: Text('  '))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      // VERSION DE LA PLANTA NOCTURNA

                      else {
                        // SE AÑADE A LA LISTA DE WITGETS A MOSTRAR

                        plantasNocturnas.add(
                          // WITGET BASE DE LA PLANTA
                          // SE UTILIZA UN STACK COMO BASE PARA VISUALIZAR LAS PLANTAS

                          Container(
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                // MOSTRAR ESTADO ACTUAL DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      height: size.height / 1.5,
                                      alignment: Alignment.center,
                                      child: rive.RiveAnimation.asset(
                                        urlAnimacionPlantas,
                                        artboard: 'Cebollín',
                                        animations: [
                                          plantas.habits[i]['etapa_animacion']
                                                  .toString() +
                                              '_idle'
                                        ],
                                        antialiasing: false,
                                        fit: BoxFit.scaleDown,
                                        placeHolder: Image(
                                          image: AssetImage(
                                              'assets/images/growing.gif'),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: size.height / 15,
                                    )
                                  ],
                                ),

                                // MOSTRAR MACETA

                                Container(
                                  height: (size.height * 4 / 15),
                                  child: Image(
                                    fit: BoxFit.fill,
                                    image: AssetImage(
                                        'assets/images/maceta-galeria.png'),
                                  ),
                                ),

                                // MOSTRAR BOTON Y INDICADOR DE LA PLANTA

                                Column(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    //TEXTO DESCRIPTIVO DE LA PLANTA, MUESTRA:
                                    //-DIA ACTUAL DE LA PLANTA
                                    //-TIPO DE PLANTA
                                    //-ICONO DEL ESTADO ACTUAL DE LA PLANTA

                                    Stack(
                                      alignment: Alignment.center,
                                      children: [
                                        Center(
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                            decoration: BoxDecoration(
                                              color: Colors.grey,
                                              gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    Colors.deepPurple,
                                                    Colors.black
                                                  ]),
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(40)),
                                            ),
                                            child: Container(
                                              padding: EdgeInsets.all(5),
                                              child: Text(
                                                'Día ' +
                                                    plantas.habits[i]
                                                            ['riegos_totales']
                                                        .toString() +
                                                    " de tu planta de " +
                                                    plantas.habits[i]['planta']
                                                        .toString(),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // BOTON DE "REGAR PLANTA"
                                    // APARECE SOLO CUANDO SE PUEDE REGAR:
                                    //-UNA VEZ AL DIA
                                    //-NO MAS VECES A LA SEMANA DE LO PERMITIDO
                                    // POR LA PLANTA

                                    Visibility(
                                      maintainSize: true,
                                      maintainAnimation: true,
                                      maintainState: true,
                                      visible: regarDisponible(
                                          plantas.habits[i]['regable']),
                                      child: Container(
                                        margin: EdgeInsets.only(
                                            top: 20, bottom: 30),
                                        alignment: Alignment.topCenter,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20)),
                                            gradient: LinearGradient(
                                              begin: Alignment.centerLeft,
                                              end: Alignment.centerRight,
                                              colors: [
                                                CustomColors.newPurpleSecondary,
                                                CustomColors.newPinkSecondary,
                                              ],
                                            ),
                                          ),
                                          child: ElevatedButton.icon(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Colors.transparent,
                                              elevation: 0,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    new BorderRadius.only(
                                                        topLeft:
                                                            Radius.circular(20),
                                                        topRight:
                                                            Radius.circular(20),
                                                        bottomRight:
                                                            Radius.circular(20),
                                                        bottomLeft:
                                                            Radius.circular(
                                                                20)),
                                              ),
                                            ),
                                            onPressed: () {
                                              Navigator.pushNamed(context,
                                                  HomeScreen.routerName,
                                                  arguments: {
                                                    index = 2,
                                                    mode = 5
                                                  });
                                            },
                                            icon: Image(
                                              width: 40,
                                              height: 40,
                                              image: AssetImage(
                                                imageEtapa(plantas.habits[i]
                                                    ['etapa_actual']),
                                              ),
                                            ),
                                            label: Text(
                                              'Regar ahora',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontFamily: 'sen-regular',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                        width: size.width,
                                        alignment: Alignment.centerRight,
                                        margin: EdgeInsets.only(
                                            bottom: 10, right: 15),
                                        child: Text('  '))
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }
                      ;

                      break;
                    default:
                  }
                }

                // SE VERIFICA LA CANTIDAD DE PLANTAS DIURNAS Y NOCTURNAS
                // SI HAY MAS DE UNA PLANTA POR GRUPO SE HARA VISIBLE UN
                // INDICADOR DE QUE SE PUEDE HACER SCROLL PARA VER MAS PLANTAS

                if (plantasDiurnas.length > 1) {
                  indicadorScrollDiurno = Colors.white;
                } else {
                  indicadorScrollDiurno = Colors.transparent;
                }
                if (plantasNocturnas.length > 1) {
                  indicadorScrollNocturno = Colors.white;
                } else {
                  indicadorScrollNocturno = Colors.transparent;
                }

                // WITGET INICIAL

                return Center(
                  child: DefaultTabController(
                    length: 2,
                    child: Scaffold(
                      extendBody: true,
                      extendBodyBehindAppBar: true,

                      // APPBAR: CONTIENE TITULO Y BOTON "HOME"

                      appBar: AppBar(
                        automaticallyImplyLeading: false,
                        title: Container(
                          alignment: Alignment.bottomLeft,
                          child: Text('Galería de plantas',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontFamily: 'sen-regular',
                                  fontWeight: FontWeight.bold),
                              textScaler: TextScaler.linear(1.0)),
                        ),
                        iconTheme: IconThemeData(
                          color: Colors.black,
                        ),
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        actions: [
                          // BOTON "HOME"

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
                                child: Icon(MdiIcons.home,
                                    size: 35,
                                    color: Color.fromARGB(255, 234, 234, 234)),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    shape: BoxShape.circle,
                                    gradient:
                                        RadialGradient(radius: 0.6, stops: [
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

                      //BODY: UTILIZA UN STACK APRA MOSTRAR LAS LISTAS DE PLANTAS
                      // DEL USUARIO ACTUAL JUNTO A DECORACIONES DE LA INTERFAZ

                      body: Stack(
                        children: [
                          // COLOREADO DEL FONDO

                          Container(
                            width: size.width,
                            height: size.height,
                            decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    stops: [0.2, 0.8],
                                    colors: [colorSuperior, colorInferior])),
                            //child: Image(
                            //    fit: BoxFit.fill,
                            //    image:
                            //        AssetImage('assets/images/bg_galeria.png')),
                          ),

                          // VISUALIZADOR DE PLANTAS

                          TabBarView(
                            children: [
                              //EN CASO DE NO HABER PLANTAS DIURNAS

                              plantasDiurnas.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // MOSTRAR MENSAJE DE QUE NO EXISTEN HABITOS DIURNOS

                                          Text('Sin hábitos diurnos creados',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                              textScaler:
                                                  TextScaler.linear(1.0)),

                                          // MOSTRAR BOTON PARA "CREAR HABITO"

                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 20, bottom: 30),
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    CustomColors
                                                        .newPurpleSecondary,
                                                    CustomColors
                                                        .newPinkSecondary,
                                                  ],
                                                ),
                                              ),
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pushNamed(context,
                                                      HomeScreen.routerName,
                                                      arguments: {
                                                        index = 2,
                                                        mode = 5
                                                      });
                                                },
                                                icon: Icon(
                                                  MdiIcons.plus,
                                                  size: 30,
                                                  color: Colors.white,
                                                ),
                                                label: Text(
                                                  'Crear hábito',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontFamily: 'sen-regular',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  // EN CASO DE HABER PLANTAS DIURNAS

                                  : Center(

                                      //MOSTRAR LISTA DE PLANTAS HACIENDO USO DE "PAGESCROLL"
                                      //PARA ANCLAR LAS VISTAS DE LAS PLANTAS

                                      child: Stack(
                                      alignment: Alignment.bottomRight,
                                      children: [
                                        RawScrollbar(
                                          mainAxisMargin: size.height / 4,
                                          crossAxisMargin: 10,
                                          trackBorderColor: Colors.black87,
                                          thumbColor:
                                              CustomColors.newPinkSecondary,
                                          thumbVisibility: true,
                                          controller: scrollControllerdiurnos,
                                          child: ListView.builder(
                                            // Ajustar el Padding de los elementos a 0 les obliga a utilizar toda la pagina
                                            // permitiendo que el Scroll funcione correctamente
                                            controller: scrollControllerdiurnos,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 0),
                                            physics: PageScrollPhysics(),
                                            itemCount: plantasDiurnas.length,
                                            itemBuilder: (BuildContext context,
                                                int index) {
                                              // SE RETORNAN LAS PLANTAS CON UN INDICADOR DE SCROOLL
                                              // EL INDICADOR ES INVISIBLE SI SOLO HAY 1 PLANTA

                                              return Stack(
                                                alignment:
                                                    Alignment.bottomRight,
                                                children: [
                                                  Container(
                                                      width: size.width,
                                                      height: size.height,
                                                      child: plantasDiurnas[
                                                          index]),
                                                ],
                                              );
                                            },
                                          ),
                                        ),
                                        /*Container(
                                          margin: EdgeInsets.only(
                                              bottom: 20, right: 20),
                                          height: 75,
                                          width: 25,
                                          child: Column(
                                            children: [
                                              Icon(
                                                MdiIcons.arrowUpBold,
                                                size: 25,
                                                color: indicadorScrollDiurno,
                                              ),
                                              Icon(
                                                MdiIcons.sprout,
                                                size: 25,
                                                color: indicadorScrollDiurno,
                                              ),
                                              Icon(
                                                MdiIcons.arrowDownBold,
                                                size: 25,
                                                color: indicadorScrollDiurno,
                                              ),
                                            ],
                                          ),
                                        )*/
                                      ],
                                    )),

                              // EN CASO DE NO HABER PLANTAS NOCTURNAS

                              plantasNocturnas.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          // MOSTRAR MENSAJE DE QUE NO EXISTEN HABITOS NOCTURNOS

                                          Text('Sin hábitos nocturnos creados',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16),
                                              textScaler:
                                                  TextScaler.linear(1.0)),

                                          // MOSTRAR BOTON PARA "CREAR HABITO"

                                          Container(
                                            margin: EdgeInsets.only(
                                                top: 20, bottom: 30),
                                            alignment: Alignment.topCenter,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(20)),
                                                gradient: LinearGradient(
                                                  begin: Alignment.centerLeft,
                                                  end: Alignment.centerRight,
                                                  colors: [
                                                    CustomColors
                                                        .newPurpleSecondary,
                                                    CustomColors
                                                        .newPinkSecondary,
                                                  ],
                                                ),
                                              ),
                                              child: ElevatedButton.icon(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.transparent,
                                                  elevation: 0,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        new BorderRadius.all(
                                                            Radius.circular(
                                                                20)),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  Navigator.pushNamed(context,
                                                      HomeScreen.routerName,
                                                      arguments: {
                                                        index = 2,
                                                        mode = 5
                                                      });
                                                },
                                                icon: Icon(
                                                  MdiIcons.plus,
                                                  size: 30,
                                                  color: Colors.white,
                                                ),
                                                label: Text(
                                                  'Crear hábito',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 20,
                                                      fontFamily: 'sen-regular',
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )

                                  // EN CASO DE HABER PLANTAS NOCTURNAS

                                  : Center(

                                      //MOSTRAR LISTA DE PLANTAS HACIENDO USO DE "PAGESCROLL"
                                      //PARA ANCLAR LAS VISTAS DE LAS PLANTAS

                                      child: Stack(children: [
                                      RawScrollbar(
                                        mainAxisMargin: size.height / 4,
                                        crossAxisMargin: 10,
                                        trackBorderColor: Colors.black87,
                                        thumbColor:
                                            CustomColors.newPinkSecondary,
                                        thumbVisibility: true,
                                        controller: scrollControllernocturnos,
                                        child: ListView.builder(
                                          // Ajustar el Padding de los elementos a 0 les obliga a utilizar toda la pagina
                                          // permitiendo que el Scroll funcione correctamente
                                          controller: scrollControllernocturnos,
                                          padding:
                                              EdgeInsets.symmetric(vertical: 0),
                                          physics: PageScrollPhysics(),
                                          itemCount: plantasNocturnas.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            // SE RETORNAN LAS PLANTAS CON UN INDICADOR DE SCROOLL
                                            // EL INDICADOR ES INVISIBLE SI SOLO HAY 1 PLANTA

                                            return Stack(
                                              alignment: Alignment.bottomRight,
                                              children: [
                                                Container(
                                                    width: size.width,
                                                    height: size.height,
                                                    child: plantasNocturnas[
                                                        index]),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      /*Container(
                                        margin: EdgeInsets.only(
                                            bottom: 20, right: 20),
                                        height: 75,
                                        width: 25,
                                        child: Column(
                                          children: [
                                            Icon(
                                              MdiIcons.arrowUpBold,
                                              size: 25,
                                              color: indicadorScrollNocturno,
                                            ),
                                            Icon(
                                              MdiIcons.sprout,
                                              size: 25,
                                              color: indicadorScrollNocturno,
                                            ),
                                            Icon(
                                              MdiIcons.arrowDownBold,
                                              size: 25,
                                              color: indicadorScrollNocturno,
                                            ),
                                          ],
                                        ),
                                      )*/
                                    ])),
                            ],
                          ),

                          // MOSTAR NAVEGACION CON TABBAR

                          Container(
                              height: 150,
                              decoration: BoxDecoration(
                                  //image: DecorationImage(
                                  //image: AssetImage(
                                  //    'assets/images/header_galeria.png'),
                                  //fit: BoxFit.cover)
                                  ),
                              child: Column(
                                children: [
                                  Spacer(),
                                  Row(
                                    children: [
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15),
                                        child: Text(""),
                                      ),
                                    ],
                                  ),
                                  Spacer(),
                                  tabBarBottom(),
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                );
              }

              // PANTALLA DE CARGA MIENTRAS SE OBTIENEN LAS PLANTAS DEL USUARIO

              else {
                return Container(
                  width: size.width / 1.5,
                  height: size.height / 3,
                  margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: CustomColors.orange,
                    ),
                  ),
                );
              }
            },
          );
        }
      }
      return Container();
    });
  }

  // BOTONES DE LA TABBAR

  Widget tabBarBottom() {
    return TabBar(
      dividerColor: Colors.transparent,
      indicatorSize: TabBarIndicatorSize.tab,
      indicator:
          BoxDecoration(image: DecorationImage(image: AssetImage(imagennube))),
      indicatorWeight: 1,
      unselectedLabelColor: Color.fromARGB(255, 163, 163, 163),
      labelColor: Colors.black,
      tabs: [
        Tab(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Hábitos diurnos',
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
        Tab(
          child: Container(
            padding: EdgeInsets.all(10),
            child: Text(
              'Hábitos nocturnos',
              textScaler: TextScaler.linear(1.0),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }
}
