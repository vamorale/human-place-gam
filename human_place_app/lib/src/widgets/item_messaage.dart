// ignore_for_file: unused_element, must_be_immutable

import 'dart:math';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:human_place_app/src/screens/image_viewer_screen.dart';
import 'package:human_place_app/src/screens/video_viewer_screen.dart';
import 'package:human_place_app/src/services/dialogflow_cx.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:metadata_fetch/metadata_fetch.dart';
import 'package:rive/rive.dart' as rive;
import 'package:video_player/video_player.dart';
import 'dart:async';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_metadata/youtube.dart';
import '../colors.dart';
import 'package:basic_utils/basic_utils.dart';
import '../services/plantas_control.dart';

//Estructura de Mensajes a utilizar
//
class ItemMessage extends StatefulWidget {
  bool isFirst;
  bool userMessage;
  String content;
  String type;
  List<String> listOfContent;
  List<String> listOfContentAUX1;
  List<String> listOfContentAUX2;
  double nivel;

  ItemMessage(
      {this.isFirst = false,
      this.userMessage = false,
      required this.content,
      required this.type,
      required this.listOfContent,
      required this.listOfContentAUX1,
      required this.listOfContentAUX2,
      required this.nivel});
  @override
  _ItemMessageState createState() => _ItemMessageState();
}

late Future<void> _launched;

//control de animaciones
//
var plantas;
int riesgosTotalesHabito = 0;

// Valores para el fetch de datos para mensajes de tipo Link
//
String? linktitulo;
String? linkdescripcion;
String? linkimagen;
String? linkof;

// Valores para control de listas simples
//
late Map values;

//Estructura de estados de los mensajes
//-Busca al usuario en la base de datos
//-Realiza el proceso para extraer la informacion de los habitos que tenga el usuario

class _ItemMessageState extends State<ItemMessage> {
  MetaDataModel? youtubeMetadata;
  final userId = FirebaseAuth.instance.currentUser!.uid;
  final PlantasFunctionService plantasService = PlantasFunctionService();
  Future<void>? _data;
  Future<void> _launchUrlWhatsapp(url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  void initState() {
    super.initState();

    print(id_habito);
    print('ItemMessage.initState type1: ' +
        widget.type +
        ' content: ' +
        widget.content);
    if (widget.type == 'videoYT') {
      _data = _fetchMetadata(widget.content);
    }
    if (widget.type == 'animacion') {
      //Se solicita informacion de las plantas del usuario en la base de datos
      getDataHabito(id_habito);
    }
  }

//Metodo para extraccion de videos provenientes de Youtube
//

  _fetchMetadata(String link) async {
    try {
      youtubeMetadata = await YoutubeMetaData.getData(
          'https://www.youtube.com/watch?v=' + link);
    } catch (e) {
      youtubeMetadata = null;
    }
  }

  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  String get contentMessages {
    String _content = widget.content.split('_')[0];
    if (_content == 'Dia' || _content == 'Noche') {
      return 'Comenzar mi sesión';
    } else {
      return widget.content;
    }
  }

  //metodo para obtener los habitos del usuario
  //

  void getDataHabito(String idHabitoGlobal) async {
    plantas = await plantasService.detectPlantas(userId);
    setState(() {
      for (var i = 0; i < plantas.habits.length; i++) {
        if (plantas.habits[i]['id_habito'] == idHabitoGlobal) {
          riesgosTotalesHabito = plantas.habits[i]['riegos_totales'];
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //Se Evalua que contiene el mensaje para llevar a cabo el proceso correcto
    //
    switch (widget.type) {
      // El mensaje contiene: Texto

      case 'text':
        return Container(
          margin: EdgeInsets.only(bottom: 10),
          child: Row(
            mainAxisAlignment: widget.userMessage
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: widget.userMessage ? size.width * 0.3 : 0,
              ),
              if (!widget.userMessage)
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage: AssetImage("assets/images/gato_sam.png"),
                  ),
                ),
              Flexible(
                child: Bubble(
                  borderWidth: 1,
                  elevation: 2,
                  radius: Radius.circular(12),
                  shadowColor: widget.userMessage
                      ? CustomColors.grey
                      : CustomColors.newGreenPrimary,
                  color: widget.userMessage
                      ? CustomColors.newPurpleSecondary
                      : CustomColors.grey,
                  margin: BubbleEdges.only(top: 10),
                  nip: widget.userMessage
                      ? BubbleNip.rightTop
                      : BubbleNip.leftTop,
                  nipHeight: 12,
                  child: Text(
                    contentMessages,
                    style: TextStyle(
                        color: widget.userMessage ? Colors.white : Colors.black,
                        fontFamily: 'sen-regular',
                        fontSize: widget.isFirst ? 24 : 16),
                  ),
                ),
              ),
              if (!widget.isFirst)
                SizedBox(
                  width: widget.userMessage ? 0 : size.width * 0.3,
                ),
              if (widget.userMessage)
                Align(alignment: Alignment.topLeft,
                child: 
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundImage:
                        AssetImage("assets/images/personajes/huillin.png"),
                  ),
                ),
                ),
            ],
          ),
        );

      // El mensaje contiene: imagen

      case 'image':
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageViewerScreen(
                  url: widget.content,
                ),
              ),
            );
          },
          child: Container(
            child: Align(
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: widget.content,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
        );

      // El mensaje contiene: Una animacion
      // Nota: aqui se encuentran todas las animaciones posibles en un mensaje

      case 'animacion':
        switch (widget.content) {
          // Se evalua que planta debe ser presentada en la animacion:

          // Animacion del tomate

          case 'Tomate':
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.7, 0.3],
                  colors: [CustomColors.grey, CustomColors.brown],
                ),
              ),
              width: size.width / 2,
              height: size.height / 1.5,
              child: rive.RiveAnimation.asset(
                'assets/animationsRive/plantas.riv',
                artboard: 'Tomate',
                animations: ['out'],
                antialiasing: false,
                placeHolder: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              ),
            );

          // Animacion del cebollin

          case 'Cebollin':
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.7, 0.3],
                  colors: [CustomColors.grey, CustomColors.brown],
                ),
              ),
              width: size.width / 2,
              height: size.height / 1.5,
              child: rive.RiveAnimation.asset(
                'assets/animationsRive/plantas.riv',
                artboard: 'Ciboulette',
                animations: ['out'],
                antialiasing: false,
                placeHolder: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              ),
            );

          // Animacion del repollo

          case 'Repollo':
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.6, 0.4],
                  colors: [CustomColors.grey, CustomColors.brown],
                ),
              ),
              width: size.width / 2,
              height: size.height / 1.5,
              child: rive.RiveAnimation.asset(
                'assets/animationsRive/plantas.riv',
                artboard: 'Repollo',
                animations: ['out'],
                antialiasing: false,
                placeHolder: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              ),
            );

          // animacion de regar

          case 'Regar':
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: CustomColors.grey),
              width: size.width / 2,
              height: size.height / 1.5,
              child: rive.RiveAnimation.asset(
                'assets/animationsRive/plantas.riv',
                artboard: 'Regar',
                animations: ['Timeline 1'],
                antialiasing: false,
                placeHolder: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                ),
              ),
            );

          // animacion de tomate siendo regado

          case 'RegarTomate':
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 62, 134, 193),
                    Color.fromARGB(255, 210, 238, 248)
                  ],
                ),
              ),
              width: size.width / 2,
              height: size.height / 1.5,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  rive.RiveAnimation.asset(
                    'assets/animationsRive/plantas.riv',
                    artboard: 'Tomate',
                    animations: [riesgosTotalesHabito.toString()],
                    antialiasing: false,
                    placeHolder: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  ),
                  Container(
                    width: 230,
                    height: 500,
                    child: rive.RiveAnimation.asset(
                      'assets/animationsRive/regadera.riv',
                      artboard: 'Regar',
                      animations: ['Timeline 1'],
                      antialiasing: false,
                      placeHolder: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: (size.height * 17) / 100,
                    width: size.width,
                    child: Image(
                        fit: BoxFit.fill,
                        image: AssetImage(
                          'assets/images/maceta-galeria.png',
                        )),
                  ),
                ],
              ),
            );

          // animacion de repollo siendo regado

          case 'RegarRepollo':
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 62, 134, 193),
                    Color.fromARGB(255, 210, 238, 248)
                  ],
                ),
              ),
              width: size.width / 2,
              height: size.height / 1.5,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  rive.RiveAnimation.asset(
                    'assets/animationsRive/plantas.riv',
                    artboard: 'Repollo',
                    animations: [riesgosTotalesHabito.toString()],
                    antialiasing: false,
                    placeHolder: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  ),
                  Container(
                    width: 220,
                    height: 500,
                    child: rive.RiveAnimation.asset(
                      'assets/animationsRive/regadera.riv',
                      artboard: 'Regar',
                      animations: ['Timeline 1'],
                      antialiasing: false,
                      placeHolder: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: (size.height * 21) / 120,
                    width: size.width,
                    child: Image(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/maceta-galeria.png')),
                  ),
                ],
              ),
            );

          // animacion de cebollin siendo regado

          case 'RegarCebollín':
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 62, 134, 193),
                    Color.fromARGB(255, 210, 238, 248)
                  ],
                ),
              ),
              width: size.width / 2,
              height: size.height / 1.5,
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  rive.RiveAnimation.asset(
                    'assets/animationsRive/plantas.riv',
                    artboard: 'Cebollín',
                    animations: [riesgosTotalesHabito.toString()],
                    antialiasing: false,
                    placeHolder: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.orange),
                      ),
                    ),
                  ),
                  Container(
                    width: 230,
                    height: 500,
                    child: rive.RiveAnimation.asset(
                      'assets/animationsRive/regadera.riv',
                      artboard: 'Regar',
                      animations: ['Timeline 1'],
                      antialiasing: false,
                      placeHolder: Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.orange),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: (size.height * 20) / 100,
                    width: size.width,
                    child: Image(
                        fit: BoxFit.fill,
                        image: AssetImage('assets/images/maceta-galeria.png')),
                  ),
                ],
              ),
            );
        }
        return Container();

      // El mensaje contiene: Audio

      case 'audio':
        return AudioPlayerURL(
          url: widget.content,
          isModule: false,
        );

      // El mensaje contiene: Gif

      case 'gif':
        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ImageViewerScreen(
                  url: widget.content,
                ),
              ),
            );
          },
          child: Container(
            width: size.width / 2,
            margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
            child: Align(
              alignment: Alignment.centerLeft,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CachedNetworkImage(
                  imageUrl: widget.content,
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          ),
        );

      // El mensaje contiene: Un "Card"

      case 'card':
        return CardInfo(
          contenido: widget.listOfContent,
        );

      // El mensaje contiene: Un Url

      case 'url':
        return LinkInfo(
          linkurl: widget.content,
        );

      // El mensaje contiene: Acceso a chat de Whatsapp

      case 'whatsappChat':
        return InkWell(
          onTap: () {
            final Uri whatsappURL = Uri.parse(widget.content);
            _launchUrlWhatsapp(whatsappURL);
          },
          child: Container(
            margin: EdgeInsets.all(10),
            child: Image(
                height: 70,
                fit: BoxFit.scaleDown,
                image: AssetImage('assets/images/whatsappButton.png')),
          ),
        );

      // El mensaje contiene: Numero de telefono

      case 'phone':
        return InkWell(
          onTap: () async {
            final _phone = widget.content;
            final Uri launchUri = Uri(
              scheme: 'tel',
              path: _phone,
            );
            await launchUrl(launchUri);
          },
          child: Container(
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20), color: gradientBlue),
            margin: EdgeInsets.only(top: 10, bottom: 10, left: 40, right: 40),
            child: ListTile(
              title: Text(
                'Llama ahora al ' + widget.content.toString(),
                textScaler: TextScaler.linear(1.0),
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              trailing: Icon(
                MdiIcons.phoneDialOutline,
                color: Colors.white,
                size: 30,
              ),
            ),
          ),
        );

      // El mensaje contiene: Selecion multiple

      case 'multiple':
        return Column(
          children: [
            Container(
              constraints: BoxConstraints(
                maxHeight: size.height / 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: CustomColors.grey,
              ),
              child: SwitchOption(
                opciones: widget.listOfContent,
              ),
            ),
          ],
        );

      // El mensaje contiene: Video de youtube (Si se recibe desde Dialogflow)

      case 'videoYT':
        return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => VideoPlayerScreen(
                    url: widget.content,
                  ),
                ),
              );
            },
            child: FutureBuilder(
              future: _data,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20)),
                            color: CustomColors.orange,
                          ),
                          width: size.width / 1.5,
                          margin: EdgeInsets.only(top: 5, left: 5, right: 5),
                          child: ListTile(
                            isThreeLine: true,
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  youtubeMetadata!.title.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  youtubeMetadata!.description.toString(),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          width: size.width / 1.5,
                          height: size.width / 2,
                          margin: EdgeInsets.only(bottom: 5, left: 5, right: 5),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: ClipRRect(
                              borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(20),
                                  bottomRight: Radius.circular(20)),
                              child: CachedNetworkImage(
                                fit: BoxFit.contain,
                                imageUrl:
                                    youtubeMetadata!.thumbnailUrl.toString(),
                                errorWidget: (context, url, error) =>
                                    const Icon(Icons.error),
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  );
                } else {
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
            ));

      // El mensaje contiene: Una lista

      case 'list':
        return Container(
          constraints: BoxConstraints(
            maxHeight: size.height / 2,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: CustomColors.grey,
          ),
          child: ListView.separated(
            itemCount: widget.listOfContent.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(
                  widget.listOfContent[index],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  widget.listOfContentAUX1[index],
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(fontSize: 14),
                ),
                trailing: Container(
                  width: 50,
                  height: 50,
                  child: CachedNetworkImage(
                    fit: BoxFit.contain,
                    imageUrl: widget.listOfContentAUX2[index],
                    errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                  ),
                ), //Text(widget.listOfContentAUX2[index]),
              );
            },
          ),
        );

      // El mensaje contiene: Una lista simple

      case 'simpleList':
        return SimpleList(listOfContent: widget.listOfContent);

      default:
        {
          return Container();
        }
    }
  }
}

////
//Estructura para reproductor de audio en el Chat
////

//Estructura Base del reproductor de audio
//- Contiene el url donde pedira el audio desde la base de datos

class AudioPlayerURL extends StatefulWidget {
  final String url;
  final bool isModule;
  const AudioPlayerURL({Key? key, required this.url, required this.isModule})
      : super(key: key);
  @override
  State<AudioPlayerURL> createState() => _AudioPlayerURLState();
}

//Estructura para determinar el estado actual de la reproduccion.

class _AudioPlayerURLState extends State<AudioPlayerURL> {
  late AudioPlayer _audioPlayer;

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
        _audioPlayer.positionStream,
        _audioPlayer.bufferedPositionStream,
        _audioPlayer.durationStream,
        (position, buffered, duration) =>
            PositionData(position, buffered, duration ?? Duration.zero),
      );

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer()..setUrl(widget.url);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // witget inicial del reproductor de audio
    // Utiliza un "Row" para colocar el boton y barra de repodruccion en orden

    return Container(
      decoration: BoxDecoration(
          color: Colors.black54, borderRadius: BorderRadius.circular(50)),
      padding: EdgeInsets.only(top: 5, bottom: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Mostrar Boton de "pausa/reproducir"

          Controles(
            audioPlayer: _audioPlayer,
            isModule: widget.isModule,
          ),

          // Mostrar barra de reproduccion

          Container(
            width: size.width * 70 / 100,
            child: StreamBuilder<PositionData>(
                stream: _positionDataStream,
                builder: (context, snapshot) {
                  final positionData = snapshot.data;
                  return ProgressBar(
                    thumbColor: widget.isModule
                        ? CustomColors.newPurpleSecondary
                        : CustomColors.newPurpleSecondary,
                    progressBarColor: CustomColors.newPurpleSecondary,
                    baseBarColor: Colors.white,
                    bufferedBarColor: Colors.grey,
                    progress: positionData?.position ?? Duration.zero,
                    buffered: positionData?.buffered ?? Duration.zero,
                    total: positionData?.duration ?? Duration.zero,
                    onSeek: _audioPlayer.seek,
                    timeLabelTextStyle: TextStyle(
                        color: widget.isModule
                            ? CustomColors.newPurpleSecondary
                            : Colors.white,
                        fontSize: 12),
                  );
                }),
          ),
        ],
      ),
    );
  }
}

// Witget de Controles de Audio

class Controles extends StatelessWidget {
  const Controles({Key? key, required this.audioPlayer, required this.isModule})
      : super(key: key);
  final AudioPlayer audioPlayer;
  final bool isModule;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
        stream: audioPlayer.playerStateStream,
        builder: (context, snapshot) {
          final playerState = snapshot.data;
          final processingState = playerState?.processingState;
          final playing = playerState?.playing;
          if (!(playing ?? false)) {
            return Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: CustomColors.newPurpleSecondary),
              child: Center(
                child: IconButton(
                  onPressed: audioPlayer.play,
                  icon: Icon(
                    MdiIcons.playOutline,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            );
          } else if (processingState != ProcessingState.completed) {
            return Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: CustomColors.newPurpleSecondary),
              child: IconButton(
                onPressed: audioPlayer.pause,
                icon: Icon(
                  MdiIcons.pause,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            );
          }
          return Icon(MdiIcons.play);
        });
  }
}

// Clase utilizada para tener informacion para Barra de reprodruccion

class PositionData {
  const PositionData(this.position, this.buffered, this.duration);
  final Duration position;
  final Duration buffered;
  final Duration duration;

  get bufferedPosition => null;
}

// Se desconoce el uso de "Seekbar"

class SeekBar extends StatefulWidget {
  final Duration duration;
  final Duration position;
  final Duration bufferedPosition;
  final ValueChanged<Duration> onChanged;
  final ValueChanged<Duration> onChangeEnd;

  SeekBar({
    required this.duration,
    required this.position,
    required this.bufferedPosition,
    required this.onChanged,
    required this.onChangeEnd,
  });

  @override
  _SeekBarState createState() => _SeekBarState();
}

class _SeekBarState extends State<SeekBar> {
  double? _dragValue;
  late SliderThemeData _sliderThemeData;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _sliderThemeData = SliderTheme.of(context).copyWith(
      trackHeight: 2.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SliderTheme(
          data: _sliderThemeData.copyWith(
            thumbShape: HiddenThumbComponentShape(),
            inactiveTrackColor: Colors.white,
            activeTrackColor: CustomColors.violet,
          ),
          child: ExcludeSemantics(
            child: Slider(
              min: 0.0,
              max: widget.duration.inMilliseconds.toDouble(),
              value: min(widget.bufferedPosition.inMilliseconds.toDouble(),
                  widget.duration.inMilliseconds.toDouble()),
              onChanged: (value) {
                setState(() {
                  _dragValue = value;
                });
                widget.onChanged(Duration(milliseconds: value.round()));
              },
              onChangeEnd: (value) {
                widget.onChangeEnd(Duration(milliseconds: value.round()));

                _dragValue = null;
              },
            ),
          ),
        ),
        SliderTheme(
          data: _sliderThemeData.copyWith(
            inactiveTrackColor: Colors.transparent,
          ),
          child: Slider(
            min: 0.0,
            max: widget.duration.inMilliseconds.toDouble(),
            value: min(_dragValue ?? widget.position.inMilliseconds.toDouble(),
                widget.duration.inMilliseconds.toDouble()),
            onChanged: (value) {
              setState(() {
                _dragValue = value;
              });
              widget.onChanged(Duration(milliseconds: value.round()));
            },
            onChangeEnd: (value) {
              widget.onChangeEnd(Duration(milliseconds: value.round()));

              _dragValue = null;
            },
          ),
        ),
        Positioned(
          right: 16.0,
          bottom: 0.0,
          child: Text(
            RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})\.\d+$')
                    .firstMatch("$_remaining")
                    ?.group(1) ??
                '$_remaining',
          ),
        ),
      ],
    );
  }

  Duration get _remaining => widget.duration - widget.position;
}

// Clase asistente de Seek bar

class HiddenThumbComponentShape extends SliderComponentShape {
  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) => Size.zero;

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {}
}

void showSliderDialog({
  required BuildContext context,
  required String title,
  required int divisions,
  required double min,
  required double max,
  String valueSuffix = '',
  required double value,
  required Stream<double> stream,
  required ValueChanged<double> onChanged,
}) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title, textAlign: TextAlign.center),
      content: StreamBuilder<double>(
        stream: stream,
        builder: (context, snapshot) => Container(
          height: 100.0,
          child: Column(
            children: [
              Text('${snapshot.data?.toStringAsFixed(1)}$valueSuffix',
                  style: TextStyle(
                      fontFamily: 'Fixed',
                      fontWeight: FontWeight.bold,
                      fontSize: 24.0)),
              Slider(
                divisions: divisions,
                min: min,
                max: max,
                value: snapshot.data ?? value,
                onChanged: onChanged,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

class VideoPlayerChat extends StatefulWidget {
  const VideoPlayerChat({Key? key}) : super(key: key);

  @override
  _VideoPlayerChatState createState() => _VideoPlayerChatState();
}

// Url utilizado para el video player
final url =
    'https://flutter.github.io/assets-for-api-docs/assets/videos/butterfly.mp4';

// Witget encargado de mostrar videos en el chat

class _VideoPlayerChatState extends State<VideoPlayerChat> {
  late VideoPlayerController _controller;
  late Future<void> _initializeVideoPlayerFuture;
  bool isClicked = false;

  @override
  void initState() {
    super.initState();

    _controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
    );

    _initializeVideoPlayerFuture = _controller.initialize();

    _controller.setLooping(true);
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Witget Inicial

    return FutureBuilder(
        future: _initializeVideoPlayerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // Una vez completada la carga del video
            // Utiliza un Stack para mostrar:
            // -Reproductor
            // -Controles

            return Container(
              margin: EdgeInsets.only(right: 95),
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.black,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size.width / 1.5,
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  ),
                  ButtonTheme(
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      opacity: isClicked ? 0.0 : 1.0,
                      child: Container(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0),
                          onPressed: () {
                            setState(() {
                              if (_controller.value.isPlaying) {
                                _controller.pause();
                                isClicked = false;
                              } else {
                                _controller.play();
                                isClicked = true;
                              }
                            });
                          },
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            size: 90,
                          ),
                        ),
                      ),
                    ),
                  ),
                  ButtonTheme(
                    child: AnimatedOpacity(
                      duration: Duration(milliseconds: 500),
                      opacity: isClicked ? 0.0 : 1.0,
                      child: Container(
                        alignment: Alignment.bottomRight,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0),
                          onPressed: () {
                            setState(() {});
                          },
                          child: Icon(
                            _controller.value.isPlaying
                                ? Icons.fullscreen
                                : Icons.fullscreen,
                            size: 30,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // En caso de no cargar todavia

          else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        });
  }
}

class SwitchOption extends StatefulWidget {
  const SwitchOption({Key? key, this.opciones}) : super(key: key);
  final opciones;
  @override
  State<SwitchOption> createState() => _SwitchOptionState();
}

// Witget para la visualizacion de Lista de opciones

/// private State class that goes with SwitchOption
class _SwitchOptionState extends State<SwitchOption> {
  bool newvalue = false;
  List<String> userChecked = [];

  void _onSelected(bool selected, String dataName) {
    if (selected == true) {
      setState(() {
        userChecked.add(dataName);
      });
    } else {
      setState(() {
        userChecked.remove(dataName);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> data = widget.opciones;

    //para opciones desde firestore

    //para opciones desde input de usuario
    if (data.length == 1) {
      var split =
          data.toString().replaceAll('[', "").replaceAll(']', "").split(",");
      Map<int, String> values = {
        for (int i = 0; i < split.length; i++) i: split[i]
      };
      return Scrollbar(
        child: ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (context, index) => Divider(
            thickness: 2,
          ),
          itemCount: values.length,
          itemBuilder: (context, index) {
            String item = StringUtils.capitalize(values[index]!);
            return ListTile(
              title: Text(
                item,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 14),
              ),
              trailing: Checkbox(
                activeColor: gradPink,
                value: userChecked.contains(item),
                onChanged: (val) {
                  _onSelected(val!, item);
                  print(item);
                  print(val);
                },
              ),
            );
          },
        ),
      );
    } else {
      //para lista desde dialogflow
      return Scrollbar(
        child: ListView.separated(
          shrinkWrap: true,
          separatorBuilder: (context, index) => Divider(
            thickness: 2,
          ),
          itemCount: data.length,
          itemBuilder: (context, index) {
            return ListTile(
              title: Text(
                data[index],
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontSize: 14),
              ),
              trailing: Checkbox(
                activeColor: gradPink,
                value: userChecked.contains(data[index]),
                onChanged: (val) {
                  _onSelected(val!, data[index]);
                  print(data[index]);
                  print(val);
                },
              ),
            );
          },
        ),
      );
    }
  }
}

class CardInfo extends StatefulWidget {
  const CardInfo({Key? key, this.contenido}) : super(key: key);
  final contenido;
  @override
  _CardInfoState createState() => _CardInfoState();
}

// Witget de "Cards" en el chat

class _CardInfoState extends State<CardInfo> {
  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Witget Inicial

    return Container(
      height: 230,
      child: Card(
        color: CustomColors.grey,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
            child: Row(
          children: [
            // Mostrar Columna con informacion del "Card"

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mostrar Titulo del "Card"

                Container(
                  width: size.width / 2,
                  margin: EdgeInsets.only(top: 20, left: 10),
                  child: Text(
                    widget.contenido[1],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.black),
                  ),
                ),

                // Mostrar subtitulo del "Card"

                Container(
                  width: size.width / 2,
                  margin: EdgeInsets.only(left: 10),
                  child: Text(
                    widget.contenido[2],
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                        fontSize: 15,
                        fontStyle: FontStyle.italic,
                        color: Colors.black),
                  ),
                ),

                // Mostrar detalles del "Card"
                Container(
                  margin: EdgeInsets.only(top: 10, left: 10),
                  alignment: Alignment.center,
                  width: size.width / 2,
                  child: Text(
                    widget.contenido[3],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                    maxLines: 4,
                  ),
                ),
                Spacer(),

                // Mostrar boton de redireccion del "Card"

                Container(
                  child: TextButton(
                    onPressed: () {
                      _launchURL(widget.contenido[0]);
                    },
                    child: Text(
                      widget.contenido[4],
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: gradPink),
                    ),
                  ),
                ),
              ],
            ),
            Spacer(),

            // Mostrar imagen del "Card"

            Container(
              width: size.width / 3,
              height: 200,
              padding: EdgeInsets.all(10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  color: Colors.black,
                  child: CachedNetworkImage(
                    imageUrl: widget.contenido[0],
                    fit: BoxFit.contain,
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
          ],
        )),
      ),
    );
  }
}

class LinkInfo extends StatefulWidget {
  const LinkInfo({Key? key, this.linkurl}) : super(key: key);
  final linkurl;
  @override
  _LinkInfoState createState() => _LinkInfoState();
}

Future<void> getDataLink(link) async {
  var data = await MetadataFetch.extract(link); // returns a Metadata object
  print(data);

  linktitulo = data!.title;

  linkdescripcion = data.description;

  linkimagen = data.image;

  if (data.url == "null")
    linkof = link;
  else
    linkof = data.url;
}

// Witget para visualizar links en el chat

class _LinkInfoState extends State<LinkInfo> {
  _launchURL(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not launch $url';
    }
  }

  late final Future future = getDataLink(widget.linkurl);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // Witget inicial

    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        // Se espera a que cargue la data del link

        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            // Se utiliza un "Card" para mostrar los datos del link

            child: Card(
              color: CustomColors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                  child: Column(
                children: [
                  // Mostrar imagen del Link

                  Container(
                    width: 400,
                    padding: EdgeInsets.all(10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        child: CachedNetworkImage(
                          imageUrl: linkimagen.toString(),
                          fit: BoxFit.cover,
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                        ),
                      ),
                    ),
                  ),

                  // Mostrar Titulo del link

                  if (linktitulo.toString() != "null")
                    Container(
                      margin: EdgeInsets.only(left: 10),
                      child: Text(
                        linktitulo.toString(),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Colors.black),
                      ),
                    ),

                  // Mostrar Descripcion del link

                  if (linkdescripcion.toString() != "null")
                    Container(
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      child: Text(
                        linkdescripcion.toString(),
                        textAlign: TextAlign.justify,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black,
                        ),
                        maxLines: 5,
                      ),
                    ),

                  // Mostrar boton para redirigir al link

                  Container(
                    margin: EdgeInsets.only(bottom: 5),
                    child: OutlinedButton(
                      onPressed: () {
                        _launchURL(linkof.toString());
                      },
                      child: Text(
                        'Más información',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: gradPink),
                      ),
                    ),
                  ),
                ],
              )),
            ),
          );
        }

        // Mientras carga se muestra un mensaje vacio

        else {
          return Container(
            height: size.height / 2,
            child: Card(
              color: CustomColors.grey,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: CircularProgressIndicator(
                  color: gradPink,
                ),
              ),
            ),
          );
        }
      },
    );
  }
}

class SimpleList extends StatefulWidget {
  const SimpleList({Key? key, this.listOfContent}) : super(key: key);
  final listOfContent;
  @override
  _SimpleListState createState() => _SimpleListState();
}

//Witget de listas simples

class _SimpleListState extends State<SimpleList> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    List<String> data = widget.listOfContent;

    if (data.length == 1) {
      var split = widget.listOfContent
          .toString()
          .replaceAll('[', "")
          .replaceAll(']', "")
          .split(",");
      values = {for (int i = 0; i < split.length; i++) i: split[i]};
    }

    // witget inicial

    return Container(
      constraints: BoxConstraints(
        maxHeight: size.height / 2,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: CustomColors.grey,
      ),
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: values.length,
        separatorBuilder: (BuildContext context, int index) => Divider(),

        // contructor de objetos en la lista

        itemBuilder: (BuildContext context, int index) {
          String item = StringUtils.capitalize(values[index]);
          return ListTile(
            title: Text(
              item,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(fontSize: 14),
            ),
          );
        },
      ),
    );
  }
}
