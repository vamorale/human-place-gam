import 'package:flutter/material.dart';
import 'package:human_place_app/src/notifiers/app.dart';
import 'package:human_place_app/src/screens/image_viewer_screen.dart';
import 'package:provider/provider.dart';
import '../colors.dart';

class GifList extends StatelessWidget {
  const GifList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // SE OBTIENEN LOS GIF DE LA BASE DE DATOS

    context.read<AppNotifier>().fetchGifs();

    Size size = MediaQuery.of(context).size;

    return Consumer<AppNotifier>(builder: (context, state, _) {
      // SE CARGAN LOS ARCHIVOS

      if (state.hasLoading(AppAction.FetchMedia) == true) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomColors.orange),
          ),
        );
      }

      if (state.hasError(AppAction.FetchMedia) == true) {
        return Center(child: Text('Error al cargar los gifs'));
      }

      // WITGET INICIAL

      return ListView.builder(
        itemCount:
            (state.gifs.length / 2).ceil() + 1, // SE LIMITA A 3 GIF POR FILA
        itemBuilder: (BuildContext context, int index) {
          final len = state.gifs.length;
          final newIndex = index * 2;
          print(len);
          var records;
          if (newIndex < len) {
            if ((len - newIndex) < 2) {
              //EXTRAE GIFS RESTANTES
              records = state.gifs.getRange(newIndex, len).toList();
            } else {
              //EXTRAE 3 GIF
              records = state.gifs.getRange(newIndex, newIndex + 2).toList();
            }
            //Se retorna una fila de 1 o 2 Gifs
            //Generando una columna de filas para la galeria de Gifs

            return Center(
              child: Container(
                  width: size.width,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        //Muestra el primer Gif extraido

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

                        //Muestra el segundo Gif extraido si existe

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
            //SE MUESTRA UN ESPACIO VACIO AL FINAL PARA FACILITAR VISUALIZACION
            return Container(
              height: 100,
            );
          }
        },
      );
    });
  }
}
