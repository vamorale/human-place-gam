import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/routes.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:human_place_app/src/screens/pages/chat_page.dart';
import 'package:human_place_app/src/screens/pages/library_page.dart';
import 'package:human_place_app/src/screens/pages/chat_cx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeScreen extends StatefulWidget {
  static final routerName = '/home-screen';

  HomeScreen(this.index, this.mode);
  final index;
  final int mode;

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  PageController pageController = PageController(initialPage: index);
  var controladorColor = index;
  Color chatColor = CustomColors.lightGrey;
  Color bibColor = grey;

  //ESTA PAGINA ES UNA BASE PARA OTRAS PAGINAS, GENERANDO UNA IMAGEN BORROSA DEL FONDO
  //Y EL BOTON HOME EN ALGUNAS DE ELLAS. OTRAS PAGINAS YA NO UTILIZAN ESTE FORMATO
  //PAGINAS UTILIZANDO ESTA:
  //-CHATPAGE
  //-LIBRARYPAGE
  //-CHATCX

  @override
  Widget build(BuildContext context) {
    if (controladorColor == 1) {
      chatColor = grey;
      bibColor = CustomColors.lightGrey;
    }
    if (controladorColor == 0) {
      chatColor = CustomColors.lightGrey;
      bibColor = grey;
    }
    Size size = MediaQuery.of(context).size;

    // WITGET INICIAL

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: CustomColors.lightGrey,

          //APPBAR: CONTIENE EL BOTON "HOME"

          appBar: AppBar(
            automaticallyImplyLeading: false,
            iconTheme: IconThemeData(
              color: Colors.black,
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              //BOTON "HOME"

              Container(
                margin: EdgeInsets.only(right: 10, top: 10),
                width: 50,
                height: 50,
                child: FloatingActionButton(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Container(
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
                ),
              ),
            ],
          ),

          // CUERPO DE LA PAGINA: CONTIENE IMAGEN BORROSA PARA OTRAS PAGINAS
          // UTILIZA UN STACK PARA MOSTRAR LAS PAGINAS MENCIONADAS POR ENCIMA
          // DEL FONDO BORROSO

          body: Stack(
            children: [
              // MOSTRAR FONDO BORROSO

              Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/bg-blurred.png'),
                      fit: BoxFit.fill),
                ),
              ),
              Container(
                width: size.width,
                height: size.height,
                color: CustomColors.newGreenPrimary.withAlpha(50),
              ),

              //MOSTRAR PAGINAS HIJAS

              PageView(
                physics: NeverScrollableScrollPhysics(),
                pageSnapping: false,
                controller: pageController,
                children: [
                  ChatPage(mode),
                  LibraryPage(),
                  ChatCX(mode),
                ],
              ),
              KeyboardVisibilityBuilder(
                builder: (context, isKeyboardVisible) {
                  return isKeyboardVisible
                      ? const SizedBox()
                      : Align(
                          alignment: Alignment.bottomCenter,
                          child: Container());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
