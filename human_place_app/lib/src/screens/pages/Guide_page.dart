import 'package:flutter/material.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:rive/rive.dart' as rive;

class GuidePage extends StatefulWidget {
  //Declaracion de la ruta
  static final routerName = '/Guide-Page';

  @override
  _GuidePageState createState() => _GuidePageState();
}

class _GuidePageState extends State<GuidePage> {
  //Se declara la variable encargada del controlador de pagina
  PageController pagViewController = PageController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    //Se retorna la pagina actual de la secuencia
    //Se utiliza "PageView" y un controlador para mostrar las paginas definidas más adelante.
    return Scaffold(
      backgroundColor: CustomColors.grey,
      body: Container(
        height: size.height,
        child: PageView(
          controller: pagViewController,
          onPageChanged: (index) {},
          children: <Widget>[
            stepOne(context),
            stepTwo(context),
            stepThree(context),
            stepFour(context),
            stepFive(context),
            stepSix(context),
            stepSeven(context),
            stepEight(context),
          ],
        ),
      ),
    );
  }

  //
  // Primera pagina
  //

  Widget stepOne(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //Se utiliza un "GestureDetector" para determinar cuando se presiona la pantalla
    //Una vez que se presiona la pantalla se pasa a la siguiente pagina.
    //
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          pagViewController.jumpToPage(1);
        },

        //Estructura de la pagina a mostrar
        child: Center(
          child: Container(
            width: size.width,
            height: size.height,

            //Se carga la imagen de fondo
            //
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/bg-blurred.png'),
                  fit: BoxFit.fill),
            ),
            child: Scaffold(
                //Declaramos todos los fondos para que sean transparentes
                //
                resizeToAvoidBottomInset: false,
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [],
                ),
                //Creamos una columna que tiene consigo un Stack
                //En el Stack Agrupamos todo lo que se muestra en pantalla
                //El Stack ordena las primeras cosas que se le entregan por detras
                //de esta forma, el texto e imagenes pueden ser resaltados o ocultos
                //por un contenedor que oscurece la pantalla
                body: Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          //Imagen del Logo en pantalla

                          Container(
                              margin: EdgeInsets.only(
                                  bottom: size.height - 60,
                                  left: size.width - 60),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: const AssetImage(
                                    'assets/logos/brand_new_logo_hp.png',
                                  ),
                                ),
                              )),
                          // Pantalla que oscurece todo lo anterior a el

                          Container(
                            width: size.width,
                            height: size.height,
                            color: Colors.black38,
                          ),
                          //Columna con las Areas donde se puede presionar el paisaje
                          //Actualmente desabilitado
                          //NOTA: Esta columna contiene en ella el mensaje que muestra Sam
                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(left: 100),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          CustomColors.newPurpleSecondary,
                                          CustomColors.newPinkSecondary
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      "Hola",
                                      style: TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 20,
                                          fontFamily: 'sen-regular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                              ],
                            ),
                          ),
                          //Imagen de Sam en pantalla

                          Center(
                            child: Container(
                              margin: EdgeInsets.all(20),
                              width: 100,
                              height: size.height / 2.5,
                              child: Image(
                                  image:
                                      AssetImage('assets/images/gato_sam.png')),
                            ),
                          ),
                          // Columna que contiene el mensaje de la introduccion

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              children: [
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: size.width - 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: CustomColors
                                                .newPurpleSecondary),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Te damos la bienvenida a Human Place",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "Nos alegra que decidieras dar este paso. ¿Demos un paseo por la app? \n \n Soy SAM, tu asistente dentro de Human Place y estoy aquí para guiarte dentro de la aplicación con las actividades y ejercicios que tenemos para ti.",
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "(Presiona la pantalla para continuar)",
                                          style: TextStyle(
                                              color: Colors.grey,
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  //
  // Segunda pagina
  //

  Widget stepTwo(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //Se utiliza un "GestureDetector" para determinar cuando se presiona la pantalla
    //Una vez que se presiona la pantalla se pasa a la siguiente pagina.
    //
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          pagViewController.jumpToPage(2);
        },
        //Estructura de la pagina a mostrar

        child: Center(
          //Se carga la imagen de fondo
          //
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/bg-blurred.png'),
                  fit: BoxFit.fill),
            ),
            child: Scaffold(
                //Declaramos todos los fondos para que sean transparentes
                //
                resizeToAvoidBottomInset: false,
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [],
                ),
                //Creamos una columna que tiene consigo un Stack
                //En el Stack Agrupamos todo lo que se muestra en pantalla
                //El Stack ordena las primeras cosas que se le entregan por detras
                //de esta forma, el texto e imagenes pueden ser resaltados o ocultos
                //por un contenedor que oscurece la pantalla
                body: Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          //Imagen del Logo en pantalla

                          Container(
                              margin: EdgeInsets.only(
                                  bottom: size.height - 60,
                                  left: size.width - 60),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: const AssetImage(
                                    'assets/logos/brand_new_logo_hp.png',
                                  ),
                                ),
                              )),
                          // Pantalla que oscurece todo lo anterior a el

                          Container(
                            width: size.width,
                            height: size.height,
                            color: Colors.black38,
                          ),
                          //Imagen de Sam en pantalla

                          Center(
                            child: Container(
                              margin: EdgeInsets.all(20),
                              width: 100,
                              height: size.height / 2.5,
                              child: Image(
                                  image:
                                      AssetImage('assets/images/gato_sam.png')),
                            ),
                          ),
                          //Columna con las Areas donde se puede presionar el paisaje
                          //Actualmente desabilitado
                          //NOTA: Esta columna contiene en ella el mensaje que muestra Sam
                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(left: 80),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Colors.transparent,
                                          Colors.transparent,
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      "Hola, un gusto conocerte",
                                      style: TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 20,
                                          fontFamily: 'sen-regular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                              ],
                            ),
                          ),
                          // Columna que contiene el mensaje de la introduccion

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              children: [
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: size.width - 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: CustomColors
                                                .newPurpleSecondary),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Column(
                                      children: [
                                        Text(
                                          "¿Ves el paisaje detrás de mí? ",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "Cada elemento es interactivo e invoca una conversación especial, solo haz tap sobre las nubes, la montaña, el bosque o en la tierra.",
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  //
  // Tercera pagina
  //

  Widget stepThree(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //Se utiliza un "GestureDetector" para determinar cuando se presiona la pantalla
    //Una vez que se presiona la pantalla se pasa a la siguiente pagina.
    //

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          pagViewController.jumpToPage(3);
        },

        //Estructura de la pagina a mostrar

        child: Center(
          //Se carga la imagen de fondo
          //
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/bg-blurred.png'),
                  fit: BoxFit.fill),
            ),
            child: Scaffold(
                //Declaramos todos los fondos para que sean transparentes
                //
                resizeToAvoidBottomInset: false,
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [],
                ),
                //Creamos una columna que tiene consigo un Stack
                //En el Stack Agrupamos todo lo que se muestra en pantalla
                //El Stack ordena las primeras cosas que se le entregan por detras
                //de esta forma, el texto e imagenes pueden ser resaltados o ocultos
                //por un contenedor que oscurece la pantalla
                body: Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          //Imagen del Logo en pantalla

                          Container(
                              margin: EdgeInsets.only(
                                  bottom: size.height - 60,
                                  left: size.width - 60),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: const AssetImage(
                                    'assets/logos/brand_new_logo_hp.png',
                                  ),
                                ),
                              )),
                          // Pantalla que oscurece todo lo anterior a el

                          Container(
                            width: size.width,
                            height: size.height,
                            color: Colors.black38,
                          ),

                          //Columna con las Areas donde se puede presionar el paisaje
                          //Actualmente desabilitado
                          //NOTA: Esta columna contiene en ella el mensaje que muestra Sam

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.white30,
                                      border: Border.all(
                                          color: CustomColors.newPinkSecondary),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(left: 100),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          CustomColors.newPurpleSecondary,
                                          CustomColors.newPinkSecondary
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      "Hola",
                                      style: TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 20,
                                          fontFamily: 'sen-regular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                              ],
                            ),
                          ),

                          // Columna que contiene el mensaje de la introduccion

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              children: [
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: size.width - 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: CustomColors
                                                .newPurpleSecondary),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Column(
                                      children: [
                                        Text(
                                          "Las nubes son como los pensamientos que vemos pasar en nuestra mente. Al hacer tap sobre ellas accederás a las herramientas de atención, centradas en conectar con el momento presente a través de la conciencia plena y la atención focalizada.",
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  //
  // Cuarta pagina
  //

  Widget stepFour(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //Se utiliza un "GestureDetector" para determinar cuando se presiona la pantalla
    //Una vez que se presiona la pantalla se pasa a la siguiente pagina.
    //

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          pagViewController.jumpToPage(4);
        },

        //Estructura de la pagina a mostrar

        child: Center(
          //Se carga la imagen de fondo
          //
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/bg-blurred.png'),
                  fit: BoxFit.fill),
            ),
            child: Scaffold(
                //Declaramos todos los fondos para que sean transparentes
                //
                resizeToAvoidBottomInset: false,
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [],
                ),
                //Creamos una columna que tiene consigo un Stack
                //En el Stack Agrupamos todo lo que se muestra en pantalla
                //El Stack ordena las primeras cosas que se le entregan por detras
                //de esta forma, el texto e imagenes pueden ser resaltados o ocultos
                //por un contenedor que oscurece la pantalla
                body: Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          //Imagen del Logo en pantalla

                          Container(
                              margin: EdgeInsets.only(
                                  bottom: size.height - 60,
                                  left: size.width - 60),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: const AssetImage(
                                    'assets/logos/brand_new_logo_hp.png',
                                  ),
                                ),
                              )),

                          // Pantalla que oscurece todo lo anterior a el

                          Container(
                            width: size.width,
                            height: size.height,
                            color: Colors.black38,
                          ),

                          //Columna con las Areas donde se puede presionar el paisaje
                          //Actualmente desabilitado
                          //NOTA: Esta columna contiene en ella el mensaje que muestra Sam

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.white30,
                                      border: Border.all(
                                          color: CustomColors.newPinkSecondary),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(left: 100),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          CustomColors.newPurpleSecondary,
                                          CustomColors.newPinkSecondary
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      "Hola",
                                      style: TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 20,
                                          fontFamily: 'sen-regular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                              ],
                            ),
                          ),

                          // Columna que contiene el mensaje de la introduccion

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              children: [
                                Spacer(
                                  flex: 3,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: size.width - 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: CustomColors
                                                .newPurpleSecondary),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Column(
                                      children: [
                                        Text(
                                          "En la montaña, las herramientas del propósito, define tus metas diarias, a corto y largo plazo o define tu propósito con IKIGAI. No importa qué tan grande o pequeña es tu meta, el objetivo es vivir una vida con propósito.",
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(
                                  flex: 1,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  //
  // Quinta pagina
  //

  Widget stepFive(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //Se utiliza un "GestureDetector" para determinar cuando se presiona la pantalla
    //Una vez que se presiona la pantalla se pasa a la siguiente pagina.
    //

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          pagViewController.jumpToPage(5);
        },

        //Estructura de la pagina a mostrar

        child: Center(
          //Se carga la imagen de fondo
          //
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/bg-blurred.png'),
                  fit: BoxFit.fill),
            ),
            child: Scaffold(
                //Declaramos todos los fondos para que sean transparentes
                //
                resizeToAvoidBottomInset: false,
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [],
                ),
                //Creamos una columna que tiene consigo un Stack
                //En el Stack Agrupamos todo lo que se muestra en pantalla
                //El Stack ordena las primeras cosas que se le entregan por detras
                //de esta forma, el texto e imagenes pueden ser resaltados o ocultos
                //por un contenedor que oscurece la pantalla
                body: Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          //Imagen del Logo en pantalla

                          Container(
                              margin: EdgeInsets.only(
                                  bottom: size.height - 60,
                                  left: size.width - 60),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: const AssetImage(
                                    'assets/logos/brand_new_logo_hp.png',
                                  ),
                                ),
                              )),

                          // Pantalla que oscurece todo lo anterior a el

                          Container(
                            width: size.width,
                            height: size.height,
                            color: Colors.black38,
                          ),

                          //Columna con las Areas donde se puede presionar el paisaje
                          //Actualmente desabilitado
                          //NOTA: Esta columna contiene en ella el mensaje que muestra Sam

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.white30,
                                      border: Border.all(
                                          color: CustomColors.newPinkSecondary),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(left: 100),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          CustomColors.newPurpleSecondary,
                                          CustomColors.newPinkSecondary
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      "Hola",
                                      style: TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 20,
                                          fontFamily: 'sen-regular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                              ],
                            ),
                          ),

                          // Columna que contiene el mensaje de la introduccion

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              children: [
                                Spacer(
                                  flex: 1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: size.width - 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: CustomColors
                                                .newPurpleSecondary),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Column(
                                      children: [
                                        Text(
                                          "El bosque, las herramientas de la comunidad, es un ecosistema de redes interconectadas de vida. Accede a ellas cuando busques ayuda dentro de las comunidades dentro y fuera de la universidad o desees conversar con un profesional de salud mental.",
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(
                                  flex: 2,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  //
  // Sexta pagina
  //

  Widget stepSix(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //Se utiliza un "GestureDetector" para determinar cuando se presiona la pantalla
    //Una vez que se presiona la pantalla se pasa a la siguiente pagina.
    //

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          pagViewController.jumpToPage(6);
        },

        //Estructura de la pagina a mostrar

        child: Center(
          //Se carga la imagen de fondo
          //
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/bg-blurred.png'),
                  fit: BoxFit.fill),
            ),
            child: Scaffold(
                //Declaramos todos los fondos para que sean transparentes
                //
                resizeToAvoidBottomInset: false,
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [],
                ),
                //Creamos una columna que tiene consigo un Stack
                //En el Stack Agrupamos todo lo que se muestra en pantalla
                //El Stack ordena las primeras cosas que se le entregan por detras
                //de esta forma, el texto e imagenes pueden ser resaltados o ocultos
                //por un contenedor que oscurece la pantalla
                body: Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          //Imagen del Logo en pantalla

                          Container(
                              margin: EdgeInsets.only(
                                  bottom: size.height - 60,
                                  left: size.width - 60),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: const AssetImage(
                                    'assets/logos/brand_new_logo_hp.png',
                                  ),
                                ),
                              )),

                          // Pantalla que oscurece todo lo anterior a el

                          Container(
                            width: size.width,
                            height: size.height,
                            color: Colors.black38,
                          ),

                          //Columna con las Areas donde se puede presionar el paisaje
                          //Actualmente desabilitado
                          //NOTA: Esta columna contiene en ella el mensaje que muestra Sam

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(left: 100),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          CustomColors.newPurpleSecondary,
                                          CustomColors.newPinkSecondary
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      "Hola",
                                      style: TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 20,
                                          fontFamily: 'sen-regular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.white30,
                                      border: Border.all(
                                          color: CustomColors.newPinkSecondary),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                              ],
                            ),
                          ),

                          // Columna que contiene el mensaje de la introduccion

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              children: [
                                Spacer(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: size.width - 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: CustomColors
                                                .newPurpleSecondary),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Column(
                                      children: [
                                        Text(
                                          "En la tierra puedes plantar hábitos. Al hacer tap sobre ella, accederás a los hábitos que hayas plantado para regarlos con constancia y verlos crecer.",
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }

  //
  // Septima pagina
  //
  Widget stepSeven(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Url necesaria para visualizar animaciones de las plantas
    var urlAnimacionPlantas = 'assets/animationsRive/plantas.riv';

    //Se utiliza un "GestureDetector" para determinar cuando se presiona la pantalla
    //Una vez que se presiona la pantalla se pasa a la siguiente pagina.
    //

    return SafeArea(
      child: GestureDetector(
        onTap: () async {
          pagViewController.jumpToPage(7);
        },

        //Estructura de la pagina a mostrar
        //Se muestra una copia de la galeria y por sobre existe un contenedor
        //para capturar el gesto de presionar la pantalla

        child: Stack(children: [
          // Se crea el app bar real para mejor replica

          DefaultTabController(
            length: 2,
            child: Container(
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
                      margin: EdgeInsets.only(top: 10, right: 10),
                      width: 50,
                      height: 50,
                      child: Icon(MdiIcons.home,
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
                  ],
                ),

                //BODY: UTILIZA UN STACK APRA MOSTRAR LAS LISTAS DE PLANTAS
                // DEL USUARIO ACTUAL JUNTO A DECORACIONES DE LA INTERFAZ

                body: Stack(children: [
                  // COLOREADO DEL FONDO

                  Container(
                    width: size.width,
                    height: size.height,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            stops: [
                          0.2,
                          0.8
                        ],
                            colors: [
                          Color.fromARGB(214, 2, 67, 120),
                          Color.fromARGB(190, 33, 149, 243)
                        ])),
                  ),

                  //Mostrar la TabBar

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
                                padding: EdgeInsets.symmetric(horizontal: 15),
                                child: Text(""),
                              ),
                            ],
                          ),
                          Spacer(),
                          TabBar(
                            dividerColor: Colors.transparent,
                            indicatorSize: TabBarIndicatorSize.tab,
                            isScrollable: false,
                            indicator: BoxDecoration(
                                image: DecorationImage(
                                    image:
                                        AssetImage("assets/images/Cloud.png"))),
                            indicatorWeight: 1,
                            unselectedLabelColor:
                                Color.fromARGB(255, 163, 163, 163),
                            labelColor: Colors.black,
                            tabs: [
                              Tab(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Hábitos diurnos',
                                    textScaler: TextScaler.linear(1.0),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                              Tab(
                                child: Container(
                                  padding: EdgeInsets.all(10),
                                  child: Text(
                                    'Hábitos nocturnos',
                                    textScaler: TextScaler.linear(1.0),
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),

                  // Se crearon 2 vistas para la TabBar, ya que sin ellas se
                  // genera un error, solo se muestra la primera pantalla

                  // Se genera una visualizacion de las paginas de la TabBAR

                  TabBarView(
                    children: [
                      Center(
                        child: Container(
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
                                      animations: ["36" + '_idle'],
                                      antialiasing: false,
                                      fit: BoxFit.scaleDown,
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
                                            border:
                                                Border.all(color: Colors.grey),
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(40)),
                                          ),
                                          child: Container(
                                            padding: EdgeInsets.all(5),
                                            child: Text(
                                              'Día ' +
                                                  "36" +
                                                  " de tu planta de " +
                                                  "Tomate",
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

                                  // Este bloque no se visualiza, pero existe en caso
                                  // de que se quiera mostrar la biblioteca sin plantas

                                  // BOTON DE "REGAR PLANTA"
                                  // APARECE SOLO CUANDO SE PUEDE REGAR:
                                  //-UNA VEZ AL DIA
                                  //-NO MAS VECES A LA SEMANA DE LO PERMITIDO
                                  // POR LA PLANTA

                                  Container(
                                    margin:
                                        EdgeInsets.only(top: 20, bottom: 30),
                                    alignment: Alignment.topCenter,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(20),
                                            topRight: Radius.circular(20),
                                            bottomRight: Radius.circular(20),
                                            bottomLeft: Radius.circular(20)),
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
                                          backgroundColor: Colors.transparent,
                                          elevation: 0,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: new BorderRadius.only(
                                                topLeft: Radius.circular(20),
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20)),
                                          ),
                                        ),
                                        onPressed: () {},
                                        icon: Image(
                                            width: 40,
                                            height: 40,
                                            image: AssetImage(
                                                "assets/images/reproduccion.png")),
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
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // MOSTRAR MENSAJE DE QUE NO EXISTEN HABITOS DIURNOS

                            Text('Sin hábitos diurnos creados',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 25),
                                textScaler: TextScaler.linear(1.0)),

                            // MOSTRAR BOTON PARA "CREAR HABITO"

                            Container(
                              margin: EdgeInsets.only(top: 20, bottom: 30),
                              alignment: Alignment.topCenter,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(20)),
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
                                    backgroundColor: Colors.transparent,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: new BorderRadius.all(
                                          Radius.circular(20)),
                                    ),
                                  ),
                                  onPressed: () {},
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // MOSTAR NAVEGACION CON TABBAR
                    ],
                  ),
                ]),
              ),
            ),
          ),

          // Bloque con el mensaje y fondo del Onboarding

          Container(
            height: size.height,
            width: size.width,
            color: Colors.black38,
            child: Column(
              children: [
                Spacer(flex: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: EdgeInsets.all(10),
                    width: size.width - 20,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        border:
                            Border.all(color: CustomColors.newPurpleSecondary),
                        borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Column(
                      children: [
                        Text(
                          "Las plantas / hábitos puedes regarlos tanto de día como de noche, viendo la cantidad de días que llevas y la etapa de crecimiento en que se encuentra. Deslizando hacia abajo navegas entre tus plantas.",
                          style: TextStyle(fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                Spacer(
                  flex: 1,
                ),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  //
  // Octava pagina
  //

  Widget stepEight(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //Se utiliza un "GestureDetector" para determinar cuando se presiona la pantalla
    //Una vez que se presiona la pantalla se pasa a la siguiente pagina.
    //

    return SafeArea(
      child: GestureDetector(
        onTap: () {
          Navigator.of(context).pushReplacementNamed(MainPage.routerName);
        },

        //Estructura de la pagina a mostrar

        child: Center(
          //Se carga la imagen de fondo
          //
          child: Container(
            width: size.width,
            height: size.height,
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/images/bg-blurred.png'),
                  fit: BoxFit.fill),
            ),
            child: Scaffold(
                //Declaramos todos los fondos para que sean transparentes
                //
                resizeToAvoidBottomInset: false,
                extendBodyBehindAppBar: true,
                backgroundColor: Colors.transparent,
                appBar: AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  actions: [],
                ),
                //Creamos una columna que tiene consigo un Stack
                //En el Stack Agrupamos todo lo que se muestra en pantalla
                //El Stack ordena las primeras cosas que se le entregan por detras
                //de esta forma, el texto e imagenes pueden ser resaltados o ocultos
                //por un contenedor que oscurece la pantalla
                body: Center(
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.bottomLeft,
                        children: [
                          //Imagen de Sam en pantalla

                          Container(
                            margin: EdgeInsets.all(20),
                            width: 100,
                            height: size.height / 2.5,
                            child: Image(
                                image:
                                    AssetImage('assets/images/gato_sam.png')),
                          ),

                          // Pantalla que oscurece todo lo anterior a el

                          Container(
                            width: size.width,
                            height: size.height,
                            color: Colors.black38,
                          ),

                          //Imagen del Logo en pantalla

                          Container(
                              margin: EdgeInsets.only(
                                  bottom: size.height - 60,
                                  left: size.width - 60),
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: const AssetImage(
                                    'assets/logos/brand_new_logo_hp.png',
                                  ),
                                ),
                              )),

                          Container(
                              margin: EdgeInsets.only(
                                  bottom: size.height - 70,
                                  left: size.width - 70),
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                                shape: BoxShape.circle,
                              )),

                          //Columna con las Areas donde se puede presionar el paisaje
                          //Actualmente desabilitado
                          //NOTA: Esta columna contiene en ella el mensaje que muestra Sam

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  padding: EdgeInsets.all(5),
                                  width: size.width,
                                  height: size.height / 3,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                                Container(
                                  alignment: Alignment.topLeft,
                                  margin: EdgeInsets.only(left: 100),
                                  child: Container(
                                    padding: EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(20),
                                          topRight: Radius.circular(20),
                                          bottomRight: Radius.circular(20)),
                                      gradient: LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          CustomColors.newPurpleSecondary,
                                          CustomColors.newPinkSecondary
                                        ],
                                      ),
                                    ),
                                    child: Text(
                                      "Hola",
                                      style: TextStyle(
                                          color: Colors.transparent,
                                          fontSize: 20,
                                          fontFamily: 'sen-regular',
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                                Spacer(),
                                Container(
                                  padding: EdgeInsets.only(top: 10),
                                  width: size.width,
                                  height: size.height / 6,
                                  decoration: BoxDecoration(
                                      color: Colors.transparent,
                                      border:
                                          Border.all(color: Colors.transparent),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(20))),
                                ),
                              ],
                            ),
                          ),

                          // Columna que contiene el mensaje de la introduccion

                          Container(
                            width: size.width,
                            height: size.height,
                            child: Column(
                              children: [
                                Spacer(
                                  flex: 1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Container(
                                    padding: EdgeInsets.all(10),
                                    width: size.width - 20,
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: CustomColors
                                                .newPurpleSecondary),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(20))),
                                    child: Column(
                                      children: [
                                        Text(
                                          "La biblioteca",
                                          style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold),
                                          textAlign: TextAlign.center,
                                        ),
                                        Text(
                                          "¿Quieres volver a escuchar un audio que te gustó? Anda a la biblioteca apretando el botón de Human Place y conecta con el contenido que se encuentra en la aplicación.",
                                          style: TextStyle(fontSize: 14),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Spacer(
                                  flex: 5,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
