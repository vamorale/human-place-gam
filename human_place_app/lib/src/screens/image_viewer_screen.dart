import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:photo_view/photo_view.dart';

class ImageViewerScreen extends StatefulWidget {
  final String url;

  ImageViewerScreen({required this.url});

  @override
  _ImageViewerScreenState createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //WITGET INICIAL

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,

          //UTILIZA UN CONTENEDDOR DE TODA LA PANTALLA, EN EL TIENE UNA COLUMNA
          //EN DONDE SE MUESTRAS LOS DATOS E IMAGEN

          body: Container(
            color: Colors.black,
            child: Stack(
              alignment: AlignmentDirectional.topStart,
              children: [
                //IMAGEN A MOSTRAR

                Container(
                    margin: EdgeInsets.only(top: size.height / 5),
                    height: size.height / 1.5,
                    padding: EdgeInsets.only(
                        left: 10, right: 10, bottom: size.height / 10),
                    child: PhotoView(
                      imageProvider: NetworkImage(widget.url),
                      minScale: PhotoViewComputedScale.contained,
                      maxScale: PhotoViewComputedScale.covered * 2,
                    )),

                //BOTON "X" PARA VOLVER ATRAS

                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black54,
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.clear,
                      color: CustomColors.lightGrey,
                      size: 50,
                    ),
                  ),
                ),
                // BOTONES DE FAVORITO Y COMPARTIR EN LA PARTE INFERIOR
                //ACTUALMENTE SIN FUNCIONALIDAD

                /*
                Container(
                  //bottom bar with icons
                  height: size.height / 15,
                  decoration: const BoxDecoration(color: Colors.black),
                  child: Row(
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Icon(
                          Icons.favorite_border,
                          color: Colors.orange,
                          size: 30.0,
                        ),
                      ),
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 15.0),
                        child: Icon(
                          Icons.ios_share,
                          color: Colors.orange,
                          size: 30.0,
                        ),
                      ),
                    ],
                  ),
                ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
