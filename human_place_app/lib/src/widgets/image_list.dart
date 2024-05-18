import 'package:flutter/material.dart';
//import 'package:gallery_image_viewer/gallery_image_viewer.dart'; Reemplazado por navegacion a una pagina de visualizacion de imagen
import 'package:human_place_app/src/notifiers/app.dart';
import 'package:human_place_app/src/screens/image_viewer_screen.dart';
import 'package:provider/provider.dart';
import '../colors.dart';

class ImageList extends StatelessWidget {
  const ImageList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    //Se solicitan las imagenes a la base de Datos
    //

    context.read<AppNotifier>().fetchImages();
    return Consumer<AppNotifier>(builder: (context, state, _) {
      if (state.hasLoading(AppAction.FetchMedia) == true) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomColors.orange),
          ),
        );
      }
      //En caso de no haber un error al conectar con la base de datos se notifica el error
      //
      if (state.hasError(AppAction.FetchMedia) == true) {
        return Center(child: Text('Error al cargar las imagenes'));
      }
      Size size = MediaQuery.of(context).size;

      //En caso de conseguir los datos de la base de datos se realiza la visualizacion
      //
      return ListView.builder(
        itemCount:
            (state.images.length / 2).ceil() + 1, // one row for every 3 images
        itemBuilder: (BuildContext context, int index) {
          final len = state.images.length;
          final newIndex = index * 2;
          if (newIndex < len) {
            var records;
            if ((len - newIndex) < 2) {
              // se extraen las imagenes restantes
              records = state.images.getRange(newIndex, len).toList();
            } else {
              // se extraen 2 imagenes
              records = state.images.getRange(newIndex, newIndex + 2).toList();
            }

            //Se retorna una fila de 1 o 2 imagenes
            //Generando una columna de filas para la galeria de imagenes

            return Center(
              child: Container(
                  width: size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //Muestra la primera imagen extraida

                        Container(
                            padding: EdgeInsets.only(top: 10),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => ImageViewerScreen(
                                      url: records[0].url,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    records[0].url,
                                    fit: BoxFit.contain,
                                    width: (size.width / 2) - 20,
                                  ),
                                ),
                              ),
                            )),

                        //Muestra la segunda imagen extraida si existe

                        if (records.length > 1)
                          Container(
                              padding: EdgeInsets.only(top: 10),
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (context) => ImageViewerScreen(
                                        url: records[1].url,
                                      ),
                                    ),
                                  );
                                },
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: Image.network(
                                    records[1].url,
                                    fit: BoxFit.contain,
                                    width: (size.width / 2) - 20,
                                  ),
                                ),
                              )),
                      ])),
            );
          } else {
            // espacio vacio para facilitar la visualizacion
            return Container(
              height: 100,
            );
          }
        },
      );
    });
  }
}
