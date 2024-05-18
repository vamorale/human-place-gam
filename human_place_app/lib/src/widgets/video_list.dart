import 'package:flutter/material.dart';
import 'package:human_place_app/src/notifiers/app.dart';
import 'package:human_place_app/src/screens/video_viewer_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import '../colors.dart';

class VideoList extends StatelessWidget {
  const VideoList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    context.read<AppNotifier>().fetchVideos();

    return Consumer<AppNotifier>(builder: (context, state, _) {
      // Se cargan los videos

      if (state.hasLoading(AppAction.FetchMedia) == true) {
        return Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(CustomColors.orange),
          ),
        );
      }
      if (state.hasError(AppAction.FetchMedia) == null) {
        return Center(child: const Text('Error al cargar los videos'));
      }

      Size size = MediaQuery.of(context).size;

      // witget inicial

      return ListView.separated(
        //Se extrae la cantidad de videos a mostrar/obtenidos
        //
        itemCount: state.videos.length,

        //Se generan los separadores de la lista y que estilo poseeran
        //

        separatorBuilder: (context, index) => const Divider(
          color: Colors.grey,
        ),

        //Se inicia el constructor de cada elemento de la lista
        //

        itemBuilder: (BuildContext context, int index) {
          //Se extrae "Nombre", "Descripcion" y "Url" asociado al video en la iteracion
          //

          final video = state.videos[index];
          print(video.url);
          print(video.name);
          print(video.thumbnailUrl);
          //Se crean variables capaces de ser entregar a futuros Wigets que solo aceptan "String"
          //
          String url = video.url;
          String name = video.name;
          String thumbnail = video.thumbnailUrl;

          //Se retorna la estructura de un elemento de la lista con la informacion extraida
          //
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListTile(
              //Acción al momento de presionar un elemento de la lista
              //
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => VideoPlayerScreen(
                      url: url,
                    ),
                  ),
                );
              },

              //Elementos visuales de los elementos de una lista:
              //
              visualDensity: VisualDensity(vertical: 4),
              // Imagen del video asociado
              leading: Container(
                  width: size.width / 3,
                  child: Image.network(thumbnail, fit: BoxFit.contain)),

              //Titulo
              title: Text(name,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15),
                  textScaler: TextScaler.linear(1.0)),

              //Trailing con decoraciones
              trailing: Container(
                child: Column(
                  children: [
                    Spacer(),
                    Icon(MdiIcons.play, color: Colors.white),
                    Spacer(),
                  ],
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
