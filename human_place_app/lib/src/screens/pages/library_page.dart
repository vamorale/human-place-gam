import 'package:flutter/material.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/widgets/audio_list.dart';
import 'package:human_place_app/src/widgets/gif_list.dart';
import 'package:human_place_app/src/widgets/image_list.dart';
import 'package:human_place_app/src/widgets/video_list.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LibraryPage extends StatefulWidget {
  static final routeName = '/library';

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //Size size = MediaQuery.of(context).size; //Por posibles ajuste se mantiene esta linea
    return Center(
      child: DefaultTabController(
        length: 4,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(175, 0, 0, 0),
          //Ajustes de la AppBar

          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: const Text("Biblioteca",
                style: TextStyle(
                    fontSize: 35,
                    fontWeight: FontWeight.w500,
                    color: Colors.white),
                textScaler: TextScaler.linear(1.0)),
            backgroundColor: Colors.transparent,
            // Implementacion de la TabBar
            // Funcion unica para navegar entre 4 vistas que corresponden a las
            // Listas de elementos:
            //-AudioList
            //-VideoList
            //-ImageList
            //-GifList
            bottom: TabBar(
                labelColor: CustomColors.newPinkSecondary,
                indicatorColor: CustomColors.primary,
                dividerColor: Colors.transparent,
                labelStyle:
                    TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                unselectedLabelColor: Colors.grey,
                tabs: [
                  Tab(
                    icon: Icon(
                      MdiIcons.flowerPoppy,
                      size: kToolbarHeight / 2,
                    ),
                    child: Text(
                      "Audio",
                    ),
                  ),
                  Tab(
                      child: Text(
                        "Video",
                      ),
                      icon: Icon(MdiIcons.flower, size: kToolbarHeight / 2)),
                  Tab(
                      child: Text(
                        "Imagenes",
                      ),
                      icon: Icon(MdiIcons.spa, size: kToolbarHeight / 2)),
                  Tab(
                    child: Text(
                      "Gifs",
                    ),
                    icon: Icon(MdiIcons.flowerTulip, size: kToolbarHeight / 2),
                  ),
                ]),
          ),
          body: TabBarView(
              children: [AudioList(), VideoList(), ImageList(), GifList()]),
        ),
      ),
    );
  }
}
