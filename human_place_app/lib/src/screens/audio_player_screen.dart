import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/models/media.dart';
import 'package:human_place_app/src/widgets/item_messaage.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_session/audio_session.dart';
import 'package:rxdart/rxdart.dart';

class AudioPlayerScreen extends StatefulWidget {
  final Media media;

  AudioPlayerScreen({required this.media});

  get isModule => false;

  @override
  _AudioPlayerScreenState createState() => _AudioPlayerScreenState();
}

class _AudioPlayerScreenState extends State<AudioPlayerScreen>
    with WidgetsBindingObserver {
  final _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    _init();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.speech());
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
    try {
      await _player
          .setAudioSource(AudioSource.uri(Uri.parse(widget.media.url)));
    } catch (e) {
      print("Error loading audio source: $e");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _player.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _player.stop();
    }
  }

  // MÉTODO PARA OBTENER LA DATA NECESARIA PARA LA BARRA DE REPRODICCION

  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    //WIDGET INICIAL

    return Container(
      color: Colors.black,
      child: SafeArea(
        child: Scaffold(
          body: Container(
            height: size.height,
            width: size.width,
            decoration: BoxDecoration(
              color: Colors.black,
            ),

            //SE UTILIZA UNA COLUMNA PARA MOSTRAR LOS DATOS Y EL REPRODUCTOR
            //DEL AUDIO

            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                //BOTON "X" PARA VOLVER ATRAS
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(
                        Icons.clear,
                        color: CustomColors.lightGrey,
                        size: size.width / 9,
                      ),
                    ),
                  ),
                ),

                //IMAGEN O PORTADA DEL AUDIO A REPRODUCIR
                Spacer(
                  flex: 2,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: Container(
                    height: size.height / 2.5,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/images/medium_image.png'),
                            fit: BoxFit
                                .contain)), //widget.media.thumbnail when they're added
                  ),
                ),

                //BARRA DE REPRODUCCION
                Spacer(
                  flex: 2,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 35),
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
                          onSeek: _player.seek,
                          timeLabelTextStyle: TextStyle(
                              color: widget.isModule
                                  ? CustomColors.newPurpleSecondary
                                  : Colors.black,
                              fontSize: 12),
                        );
                      }),
                ),

                // BOTON DE REPRODUCIR/DETENER
                Spacer(
                  flex: 1,
                ),
                Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                      color: CustomColors.lightGrey, shape: BoxShape.circle),
                  child: ControlButtons(_player),
                ),

                // NOMBRE Y DESCRIPCION DEL AUDIO
                Spacer(
                  flex: 2,
                ),
                Column(
                  children: [
                    Container(
                      height: size.height / 10,
                      decoration: const BoxDecoration(color: Colors.black),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Text(widget.media.name,
                                style: TextStyle(
                                    fontSize: 20,
                                    fontFamily: 'sen-bold',
                                    color: CustomColors.newPinkSecondary),
                                textScaler: TextScaler.linear(1.0)),
                            Text(widget.media.description,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontFamily: 'sen-bold',
                                    color: Colors.white),
                                textScaler: TextScaler.linear(1.0)),
                          ],
                        ),
                      ),
                    ),
                    //BOTONES DE FAVORITO Y COMPARTIR
                    //ACTUALMENTE SIN FUNCIONALIDAD

                    /*Container(
                      height: size.height / 10,
                      decoration: const BoxDecoration(color: Colors.black),
                      child: Row(
                        children: const [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Icon(
                              Icons.favorite_border,
                              color: Colors.orange,
                              size: 45.0,
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15.0),
                            child: Icon(
                              Icons.ios_share,
                              color: Colors.orange,
                              size: 45.0,
                            ),
                          ),
                        ],
                      ),
                    ),*/
                  ],
                ),
                Spacer(
                  flex: 2,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// WITGET DE LOS CONTROLES

class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  ControlButtons(this.player);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PlayerState>(
      //DETERMINA EL ESTADO ACTUAL DE LA REPRODUCCION:
      //-SI ESTA REPRODUCIENDOSE
      //-SI NO ESTA REPRODUCIENDOSE
      //-SI ESTA CARGANDO
      //-SI ESTA HACIENDO BUFFERING

      stream: player.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final processingState = playerState?.processingState;
        final playing = playerState?.playing;

        //SI ESTA CARGANDO O HACIENDO BUFFERING
        //MUESTRA ICONO DE CARGA

        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          return Container(
            margin: EdgeInsets.all(7.0),
            width: 22,
            height: 22,
            child: CircularProgressIndicator(),
          );
        }

        //SI ESTA REPRODUCIENDO EL AUDIO
        //MUESTRA ICONO DE PAUSA

        else if (playing != true) {
          return InkWell(
            onTap: player.play,
            child: Container(
              padding: EdgeInsets.zero,
              child: Icon(
                Icons.play_arrow,
                color: CustomColors.newPurpleSecondary,
                size: 40,
              ),
            ),
          );
        }

        //SI NO ESTA REPRODUCIENDO EL AUDIO
        //MUESTRA ICONO DE PLAY

        else if (processingState != ProcessingState.completed) {
          return InkWell(
            onTap: player.pause,
            child: Container(
              padding: EdgeInsets.zero,
              child: Icon(
                Icons.pause,
                color: CustomColors.newPurpleSecondary,
                size: 40,
              ),
            ),
          );
        } else {
          return InkWell(
            onTap: () => player.seek(Duration.zero),
            child: Container(
              padding: EdgeInsets.zero,
              child: Icon(
                Icons.play_arrow,
                color: CustomColors.newPurpleSecondary,
                size: 40,
              ),
            ),
          );
        }
      },
    );
  }
}
