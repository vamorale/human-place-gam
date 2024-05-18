import 'package:flutter/material.dart';
import 'package:human_place_app/src/screens/login_screen.dart';
import 'package:human_place_app/src/widgets/header_intro_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../colors.dart';

class IntroSlider extends StatefulWidget {
  static final routerName = '/intro-slider';

  @override
  _IntroSliderState createState() => _IntroSliderState();
}

class _IntroSliderState extends State<IntroSlider> {
  // SE UTILIZA UN CONTROLADOR DE PAGINAS PARA MOSTRAR LAS DISTINTAS PAGINAS
  // SE PUEDEN VER CADA PAGINA POR SEPARADO MAS ADELANTE

  PageController pagViewController = PageController();
  double currentPageIndex = 0.0;

  // VARIABLES UTILIZADAS PARA LA BARRA INFERIOR
  bool activeDot1 = true;
  bool activeDot2 = false;
  bool activeDot3 = false;
  bool activeDot4 = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // WITGET INICIAL

    return Scaffold(
      backgroundColor: CustomColors.grey,
      body: SingleChildScrollView(
        child: Container(
          height: size.height,
          child: PageView(
            controller: pagViewController,
            onPageChanged: (index) {
              setState(() {
                currentPageIndex = index + .0;
                if (currentPageIndex == 0.0) {
                  activeDot1 = true;
                  activeDot2 = false;
                  activeDot3 = false;
                  activeDot4 = false;
                } else if (currentPageIndex == 1.0) {
                  activeDot1 = false;
                  activeDot2 = true;
                  activeDot3 = false;
                  activeDot4 = false;
                } else if (currentPageIndex == 2.0) {
                  activeDot1 = false;
                  activeDot2 = false;
                  activeDot3 = true;
                  activeDot4 = false;
                } else {
                  activeDot1 = false;
                  activeDot2 = false;
                  activeDot3 = false;
                  activeDot4 = true;
                }
              });
            },

            // ENTREGA DE LAS PAGINAS A MOSTRAR

            children: <Widget>[
              stepOne(context),
              stepTwo(context),
              stepThree(context),
            ],
          ),
        ),
      ),
    );
  }

  //PAGINA UNO

  Widget stepOne(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // WITGET BASE
    // SE UTILIZA UNA COLUMNA PARA MOSTRAR LA PAGINA

    return Container(
      child: Column(
        children: <Widget>[
          // MOSTRAR BANNER EN LA ZONA SUPERIOR

          Stack(children: [
            Container(
              child:
                  HeaderIntroSlider(header: 'assets/images/banner-intro.png'),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    width: size.width / 2,
                    child: Text('¿Qué es ...',
                        style: TextStyle(
                            fontFamily: 'sen-regular',
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                        textScaler: TextScaler.linear(1.0)),
                  ),
                  Container(
                    width: size.width / 3,
                    child: Image(
                        fit: BoxFit.cover,
                        image: AssetImage('assets/logos/logo-hp-intro.png')),
                  )
                ],
              ),
            ),
          ]),
          Spacer(),

          // MOSTRAR TEXTO DE LA INTRODUCCION.

          Container(
            width: size.width - 20,
            decoration: BoxDecoration(
              border:
                  Border.all(color: CustomColors.newPinkSecondary, width: 2),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
            ),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Únete al viaje de Human Place una experiencia de tecnología para la salud mental, pensada especialmente para estudiantes universitarios, que busca investigar y mapear su bienestar emocional.",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.0)),
            )),
          ),
          Spacer(),

          // MOSTRAR LA IMAGEN DE SAM

          Container(
            width: size.width / 4,
            child: Image(image: AssetImage('assets/images/gato_sam.png')),
          ),

          // GENERAR ESPACIO VACIO PARA LA APARICION DEL BOTON "COMENZAR"

          Container(
            height: 60,
          ),

          // MOSTRAR BARRA DE NAVEGACION PUNTEADA

          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: dotsNavigation(context),
          )
        ],
      ),
    );
  }

  //PAGINA DOS

  Widget stepTwo(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // WITGET BASE
    // SE UTILIZA UNA COLUMNA PARA MOSTRAR LA PAGINA

    return Container(
      child: Column(
        children: <Widget>[
          Column(
            children: [
              // MOSTRAR BANNER EN LA ZONA SUPERIOR

              Stack(children: [
                Container(
                  child: HeaderIntroSlider(
                      header: 'assets/images/banner-intro.png'),
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: size.width / 2,
                        child: Text('¿Cómo lo logra ...',
                            style: TextStyle(
                                fontFamily: 'sen-regular',
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textScaler: TextScaler.linear(1.0)),
                      ),
                      Container(
                        width: size.width / 3,
                        child: Image(
                            fit: BoxFit.cover,
                            image:
                                AssetImage('assets/logos/logo-hp-intro.png')),
                      )
                    ],
                  ),
                ),
              ]),
            ],
          ),
          Spacer(),

          // MOSTRAR TEXTO DE LA INTRODUCCION.

          Container(
            width: size.width - 20,
            decoration: BoxDecoration(
              border:
                  Border.all(color: CustomColors.newPinkSecondary, width: 2),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
            ),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Mediante conversaciones virtuales, diseñadas por nuestro psicólogos, te guiaremos para entrenar tu atención e intención, facilitando tu conexión con el aquí y ahora.",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.0)),
            )),
          ),
          Spacer(),

          // MOSTRAR LA IMAGEN DE SAM

          Container(
            width: size.width / 4,
            child: Image(image: AssetImage('assets/images/gato_sam.png')),
          ),

          // GENERAR ESPACIO VACIO PARA LA APARICION DEL BOTON "COMENZAR"

          Container(
            height: 60,
          ),

          // MOSTRAR BARRA DE NAVEGACION PUNTEADA

          Container(
            margin: EdgeInsets.only(bottom: 10),
            child: dotsNavigation(context),
          )
        ],
      ),
    );
  }

  //PAGINA TRES

  Widget stepThree(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // WITGET BASE
    // SE UTILIZA UNA COLUMNA PARA MOSTRAR LA PAGINA

    return Container(
      child: Column(
        children: <Widget>[
          Column(
            children: [
              // MOSTRAR BANNER EN LA ZONA SUPERIOR

              Stack(children: [
                Container(
                  child: HeaderIntroSlider(
                      header: 'assets/images/banner-intro.png'),
                ),
                Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        width: size.width / 2,
                        child: Text('¿Por qué ...',
                            style: TextStyle(
                                fontFamily: 'sen-regular',
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textScaler: TextScaler.linear(1.0)),
                      ),
                      Container(
                        width: size.width / 3,
                        child: Image(
                            fit: BoxFit.cover,
                            image:
                                AssetImage('assets/logos/logo-hp-intro.png')),
                      )
                    ],
                  ),
                ),
              ]),
            ],
          ),
          Spacer(),

          // MOSTRAR TEXTO DE LA INTRODUCCION.

          Container(
            width: size.width - 20,
            decoration: BoxDecoration(
              border:
                  Border.all(color: CustomColors.newPinkSecondary, width: 2),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
            ),
            child: Center(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                  "Tu participación es clave. No solo ayudarás a evaluar la eficacia de esta herramienta, sino que también contribuirás a su mejora y a la creación de comunidades de autocuidado. ¿Te sumas al viaje?",
                  style: TextStyle(fontSize: 15),
                  textAlign: TextAlign.center,
                  textScaler: TextScaler.linear(1.0)),
            )),
          ),
          Spacer(),

          // MOSTRAR LA IMAGEN DE SAM

          Container(
            width: size.width / 4,
            child: Image(image: AssetImage('assets/images/gato_sam.png')),
          ),

          // BOTON "COMENZAR"

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: Container(
              height: 45,
              width: size.width / 3,
              child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () async {
                    await SharedPreferences.getInstance().then((value) {
                      value.setBool('show_slider', false);
                    });
                    Navigator.of(context).pushNamed(LoginScreen.routerName);
                  },
                  child: Container(
                    height: 45,
                    width: size.width / 3,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: LinearGradient(colors: [
                          CustomColors.newPinkSecondary,
                          CustomColors.newPurpleSecondary
                        ])),
                    child: Center(
                      child: Text(
                        'Comenzar',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontFamily: 'sen-regular',
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  )),
            ),
          ),

          // MOSTRAR BARRA DE NAVEGACION PUNTEADA

          Container(
            margin: EdgeInsets.only(top: 10, bottom: 10),
            child: dotsNavigation(context),
          )
        ],
      ),
    );
  }

  // WITGET DE LA BARRA DE NAVEGACIO PUNTEADA

  Widget dotsNavigation(context) {
    Size size = MediaQuery.of(context).size;

    // WITGET BASE
    // SE UTILIZA UNA COLUMNA PARA MOSTRAR LA PAGINA

    return Container(
      width: size.width,

      // LINEA DE PUNTOS

      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          //PRIMER PUNTO

          InkWell(
            onTap: () {
              pagViewController.animateToPage(
                0,
                duration: Duration(seconds: 1),
                curve: Curves.ease,
              );
            },
            child: Container(
              padding: EdgeInsets.all(6.5),
              decoration: BoxDecoration(
                  color: activeDot1
                      ? CustomColors.newPinkSecondary
                      : CustomColors.newPurpleSecondary,
                  shape: BoxShape.circle),
            ),
          ),
          SizedBox(
            width: 6.5,
          ),

          //SEGUNDO PUNTO

          InkWell(
            onTap: () {
              pagViewController.animateToPage(
                1,
                duration: Duration(seconds: 1),
                curve: Curves.ease,
              );
            },
            child: Container(
              padding: EdgeInsets.all(6.5),
              decoration: BoxDecoration(
                  color: activeDot2
                      ? CustomColors.newPinkSecondary
                      : CustomColors.newPurpleSecondary,
                  shape: BoxShape.circle),
            ),
          ),
          SizedBox(
            width: 6.5,
          ),

          //TERCER PUNTO

          InkWell(
            onTap: () {
              pagViewController.animateToPage(
                2,
                duration: Duration(seconds: 1),
                curve: Curves.ease,
              );
            },
            child: Container(
              padding: EdgeInsets.all(6.5),
              decoration: BoxDecoration(
                  color: activeDot3
                      ? CustomColors.newPinkSecondary
                      : CustomColors.newPurpleSecondary,
                  shape: BoxShape.circle),
            ),
          ),
          SizedBox(
            width: 6.5,
          ),
        ],
      ),
    );
  }
}
