import 'package:flutter/material.dart';
import 'package:human_place_app/src/notifiers/app.dart';
import 'package:human_place_app/src/screens/audio_player_screen.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:provider/provider.dart';
import 'package:human_place_app/src/colors.dart';

class AudioList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //Se busca la informacion de Audios en la base de datos
    //
    context.read<AppNotifier>().fetchMedia();
    return Consumer<AppNotifier>(
      builder: (context, state, _) {
        if (state.hasLoading(AppAction.FetchMedia) == true) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(CustomColors.orange),
            ),
          );
        }

        //En caso de un error se notifica
        //
        if (state.hasError(AppAction.FetchMedia) == true) {
          return Center(child: Text('Error al cargar los audios'));
        }

        //En caso de obtener los datos se inicia la generacion de la lista
        //
        return ListView.separated(
          //Se extrae la cantidad de Audios a mostrar/obtenidos
          //
          itemCount: state.media.length,

          //Se generan los separadores de la lista y que estilo poseeran
          //

          separatorBuilder: (context, index) => const Divider(
            color: Colors.grey,
          ),

          //Se inicia el constructor de cada elemento de la lista
          //

          itemBuilder: (BuildContext context, int index) {
            //Se extrae "Nombre", "Descripcion" y "Url" asociado al audio en la iteracion
            //

            final audio = state.media[index];
            print(audio.url);
            print(audio.name);
            print(audio.description);
            print(audio.duration);

            //Se crean variables capaces de ser entregar a futuros Wigets que solo aceptan "String"
            //
            String title = audio.name;
            String description = audio.description;
            String duration = audio.duration;

            //Se retorna la estructura de un elemento de la lista con la informacion extraida
            //
            return ListTile(
              //Acción al momento de presionar un elemento de la lista
              //
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => AudioPlayerScreen(
                          media: audio,
                        )));
              },

              //Elementos visuales de los elementos de una lista:
              //
              leading:
                  Icon(MdiIcons.album, color: CustomColors.orange, size: 30),
              title: Text(title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 15),
                  textScaler: TextScaler.linear(1.0)),
              subtitle: Text(description,
                  style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Colors.white70,
                      fontSize: 14),
                  textScaler: TextScaler.linear(1.0)),
              trailing: Container(
                child: Column(
                  children: [
                    Spacer(),
                    Icon(MdiIcons.play, color: Colors.white),
                    Text(
                      duration,
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    Spacer(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
