import 'package:flutter/material.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String url;

  const VideoPlayerScreen({Key? key, required this.url}) : super(key: key);

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  // INICIALIZACION DE VARIABLES

  late YoutubePlayerController _controller;
  late TextEditingController _idController;
  late TextEditingController _seekToController;

  late YoutubeMetaData _videoMetaData;
  double _volume = 100;
  bool _isPlayerReady = false;

  final List<String> _ids = [
    'dQw4w9WgXcQ',
    'gQDByCdjUXw',
    'iLnmTe5Q2Qw',
    '_WoCV4c6XOE',
    'KmzdUe0RSJo',
    '6jZDSSZZxjQ',
    'p2lYr3vM_1w',
    '7QUtEmBT_-w',
    '34_PXCzGw1M',
  ];

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.url,
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: true,
      ),
    )..addListener(listener);
    _idController = TextEditingController();
    _seekToController = TextEditingController();
    _videoMetaData = const YoutubeMetaData();
  }

  void listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _videoMetaData = _controller.metadata;
      });
    }
  }

  @override
  void deactivate() {
    // Pauses video while navigating to next page.
    _controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _controller.dispose();
    _idController.dispose();
    _seekToController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.w300,
            fontSize: 16.0,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        behavior: SnackBarBehavior.floating,
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    // WITGET INICIAL

    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        //SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },

      // GENERAR VISUALIZACION DEL VIDEO (FORMATO YOUTUBE)

      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.orange,
        topActions: <Widget>[
          const SizedBox(width: 8.0),
          Expanded(
            child: Text(
              _controller.metadata.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
        ],
        onReady: () {
          _isPlayerReady = true;
        },
        onEnded: (data) {
          _controller
              .load(_ids[(_ids.indexOf(data.videoId) + 1) % _ids.length]);
          _showSnackBar('Next Video Started!');
        },
      ),

      // ESTRUCTURA DE LA PAGINA

      builder: (context, player) => Scaffold(
        body: Container(
          height: size.height,
          width: size.width,
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              //BOTON "X" PARA VOLVER ATRAS

              Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.clear,
                      color: CustomColors.lightGrey,
                      size: 45,
                    ),
                  ),
                ),
              ),
              Spacer(
                flex: 2,
              ),
              //MOSTRAR TITULO DEL VIDEO
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(color: Colors.black),
                child: Text(
                  _videoMetaData.title,
                  style: TextStyle(
                      fontSize: size.height / 40,
                      fontFamily: 'sen-bold',
                      color: CustomColors.newPinkSecondary),
                ),
              ),
              Spacer(
                flex: 1,
              ),

              //MOSTRAR REPRODUCTOR DE VIDEO
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: player,
              ),
              Spacer(
                flex: 1,
              ),
              // COLUMNA CON CONTROLES Y ZONA INFERIOR DE LA PAGINA
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  children: <Widget>[
                    const Text(
                      "Volume",
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    Expanded(
                      child: Slider(
                        inactiveColor: Colors.transparent,
                        activeColor: CustomColors.newPurpleSecondary,
                        value: _volume,
                        min: 0.0,
                        max: 100.0,
                        divisions: 10,
                        label: '${(_volume).round()}',
                        onChanged: _isPlayerReady
                            ? (value) {
                                setState(() {
                                  _volume = value;
                                });
                                _controller.setVolume(_volume.round());
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                decoration: const BoxDecoration(color: Colors.black),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _videoMetaData.author,
                        style: TextStyle(
                            fontSize: size.height / 50,
                            fontFamily: 'sen-bold',
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),

              Spacer(
                flex: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
