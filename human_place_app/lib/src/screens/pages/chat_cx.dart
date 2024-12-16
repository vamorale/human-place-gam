import 'package:flutter/material.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/services/dialogflow_cx.dart';
import 'package:human_place_app/src/widgets/item_messaage.dart';
import 'package:human_place_app/src/models/quickly_answer.dart';
//import 'package:rxdart/rxdart.dart';

enum StateDay { Day, Night }

class ChatCX extends StatefulWidget {
  ChatCX(
    this.mode,
  );
  final mode;
  static final routerName = '/chat-cx';

  @override
  _ChatCXState createState() => _ChatCXState();
}

class _ChatCXState extends State<ChatCX> {
  // Variables iniciales
  final DialogflowCXService dialogflowService =
      DialogflowCXService(); // Conexión con Dialogflow CX
  static String _sessionAdder = '';
  String? _sessionId; // ID de la sesión con el agente
  late String _userId;

  List<ItemMessage> _messages = []; // Lista de mensajes que se renderizarán
  List<QuicklyAnswer> _options = []; // Lista de opciones de respuesta rápida
  List<Map<String, dynamic>> _habitos =
      []; // Lista de maps de los habitos propuestos por el agente

  String _currentAction = 'text'; // Le comunica a BottomWidget qué debe mostrar
  //late StateDay _stateDay;

  // Método para hablar con el agente
  void _sendQueryBot(
      String query, BuildContext context, Map<String, dynamic> habito) async {
    final user = FirebaseAuth.instance.currentUser;
    _userId = user!.uid;
    _sessionId = user.uid.toString() + _sessionAdder;
    print('sessionId: ' + _sessionId!);

    // Añadir texto a _messages para poder renderizarlo en el chat
    setState(() {
      if (query != '') {
        _messages.add(ItemMessage(
          content: query,
          type: 'text',
          userMessage: true,
          listOfContent: [],
          listOfContentAUX1: [],
          listOfContentAUX2: [],
          nivel: 0,
        ));
      }
      _currentAction = 'loading';
    });

    // Conexión con el agente
    final response = await dialogflowService.detectIntent(
        query, _sessionId!, _userId, habito);

    final msg = response.response;
    for (final v in msg) {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _messages.add(ItemMessage(
            content: v,
            type: 'text',
            listOfContent: [],
            listOfContentAUX1: [],
            listOfContentAUX2: [],
            nivel: 0));
      });
    }

    // Obtenemos los atributos de DialogflowCXService
    final payload = response.payload;
    List<String> options = response.options;
    Map<String, dynamic> params = response.params;
    List<Map<String, dynamic>> habitos = response.habits;
    int endConverestaion = response.end;

    if (endConverestaion == 1) {
      setState(() {
        _currentAction = 'close';
        _options = [];
      });
    } else {
      await Future.delayed(Duration(seconds: 1));
      // Respuestas rápidas
      if (options.isNotEmpty) {
        setState(() {
          _currentAction = 'quickly_answers';
          _options =
              List<QuicklyAnswer>.from(options.map((e) => QuicklyAnswer(e, e)));
        });
      } else {
        setState(() {
          _currentAction = 'text';
        });
      }

      // Audios
      if (dialogflowService.hasAudio(payload)) {
        final url = dialogflowService.getAudio(payload);
        _messages.add(ItemMessage(
          content: url,
          type: 'audio',
          listOfContent: [],
          listOfContentAUX1: [],
          listOfContentAUX2: [],
          nivel: 0,
        ));
      }

      // Cards
      // if (dialogflowService.hasAudio(payload)) {
      //   final card = dialogflowService.getCard(payload);
      //   _messages.add(ItemMessage(
      //     listOfContent: card,
      //     type: 'card',
      //   ));
      // }

      // URLs
      if (dialogflowService.hasURL(payload)) {
        final url = dialogflowService.getURL(payload);
        _messages.add(ItemMessage(
          content: url,
          type: 'url',
          listOfContent: [],
          listOfContentAUX1: [],
          listOfContentAUX2: [],
          nivel: 0,
        ));
      }

      // phone
      if (dialogflowService.hasPhone(payload)) {
        final url = dialogflowService.getPhone(payload);
        _messages.add(ItemMessage(
          content: url,
          type: 'phone',
          listOfContent: [],
          listOfContentAUX1: [],
          listOfContentAUX2: [],
          nivel: 0,
        ));
      }

      // whatsapp
      if (dialogflowService.hasWhatsapp(payload)) {
        final url = dialogflowService.getWhatsapp(payload);
        _messages.add(ItemMessage(
          content: url,
          type: 'whatsappChat',
          listOfContent: [],
          listOfContentAUX1: [],
          listOfContentAUX2: [],
          nivel: 0,
        ));
      }

      // Imágenes
      if (dialogflowService.hasImage(payload)) {
        final url = dialogflowService.getImage(payload);
        _messages.add(ItemMessage(
          content: url,
          type: 'image',
          listOfContent: [],
          listOfContentAUX1: [],
          listOfContentAUX2: [],
          nivel: 0,
        ));
      }

      // Videos
      if (dialogflowService.hasVideo(payload)) {
        final url = dialogflowService.getVideo(payload);
        _messages.add(ItemMessage(
          content: url,
          type: 'videoYT',
          listOfContent: [],
          listOfContentAUX1: [],
          listOfContentAUX2: [],
          nivel: 0,
        ));
      }

      // Animaciones
      if (dialogflowService.hasAnimation(payload)) {
        final artboard = dialogflowService.getAnimation(payload);
        _messages.add(ItemMessage(
          content: artboard,
          type: 'animacion',
          listOfContent: [],
          listOfContentAUX1: [],
          listOfContentAUX2: [],
          nivel: 0,
        ));
      }

      // GIFs
      if (dialogflowService.hasGif(payload)) {
        final url = dialogflowService.getGif(payload);
        _messages.add(ItemMessage(
          content: url,
          type: 'gif',
          listOfContent: [],
          listOfContentAUX1: [],
          listOfContentAUX2: [],
          nivel: 0,
        ));
      }

      // Título de listas

      // Descripción de listas

      // Imágenes de listas

      // Opciones múltiples

      // Listas simples

      // Hábitos
      if (dialogflowService.hasHabits(params)) {
        setState(() {
          _currentAction = 'quickly_habits';
          _habitos = habitos;
        });
      }
    }
  }

  // Métoto inicial
  @override
  void initState() {
    super.initState();
    // Se le enviará un query distinto al agente dependiendo de donde
    // viene la intención del usuario por conectarse con el chatbot
    late String query;

    switch (widget.mode) {
      case 0:
        query = 'Hola';
        break;
      case 3:
        query = 'Herramientas de las comunidades';
        break;
      case 4:
        query = 'Herramientas de atención';
        break;
      case 5:
        query = 'Herramientas de intención';
        break;
      case 6:
        query = 'Herramientas del propósito';
        break;
    }
    print(query);
    _sendQueryBot(query, context, {});
  }

  @override
  void dispose() {
    _sessionAdder = _sessionAdder + '1';
    super.dispose();
  }

  // Widget principal
  @override
  Widget build(BuildContext context) {
    // Para ver cuánto margen se deja abajo dependiendo de si es un TextField o una QuickAnswer*
    Size size = MediaQuery.of(context).size;
    double bottomHeight;
    if (_currentAction == 'text') {
      bottomHeight = 0.0;
    } else {
      bottomHeight = 10 + size.height / 15;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomHeight), // *
      child: Column(
        children: [
          Flexible(
            child: ListView.builder(
              // Mensajes scrolleables logicamente
              physics:
                  BouncingScrollPhysics(), // Poder scrollear cierto margen pese a haber llegado al fin
              reverse: true, // Se muestran de abajo hacia arriba
              itemBuilder: (_, int index) {
                var _msgsR = List.from(_messages.reversed);
                return index == 0
                    ? Container(
                        margin:
                            EdgeInsets.only(bottom: 70, left: 12, right: 12),
                        child: _msgsR[index],
                      )
                    : Container(
                        margin: EdgeInsets.symmetric(horizontal: 12),
                        child: _msgsR[index]);
              },
              itemCount: _messages.length,
            ),
          ),
          BottomWidget(
            options: _options,
            action: _currentAction,
            onSubmit: (value, habits) {
              _sendQueryBot(value, context, habits);
            },
            listaHabitos: _habitos,
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}

// Ventana y logica de la ventana de texto para el usuario
// En caso de no existir Respuestas Rapidas, se dispondra un chat de texto comun.

class BottomWidget extends StatefulWidget {
  final String action;
  final Function(String, Map<String, dynamic>) onSubmit;
  final List<QuicklyAnswer> options;
  final List<Map<String, dynamic>> listaHabitos;

  BottomWidget(
      {required this.action,
      required this.onSubmit,
      required this.options,
      required this.listaHabitos});

  @override
  _BottomWidgetState createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    switch (widget.action) {
      case 'text':
        return Container(
            child: Row(
          children: <Widget>[
            SizedBox(width: 8),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(vertical: 8),
                child: TextField(
                  textCapitalization: TextCapitalization.sentences,
                  autofocus: true,
                  controller: _textController,
                  maxLines: null,
                  cursorColor: primary,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Escriba su mensaje',
                    hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                        fontFamily: 'roboto-regular'),
                    isDense: true,
                    filled: true,
                    fillColor: CustomColors.grey,
                    contentPadding: EdgeInsets.all(7),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          12,
                        ),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          12,
                        ),
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          12,
                        ),
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          12,
                        ),
                      ),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.all(
                        Radius.circular(
                          12,
                        ),
                      ),
                    ),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontFamily: 'roboto-regular',
                  ),
                ),
              ),
            ),
            Container(
              child: InkWell(
                splashColor: gradPink.withAlpha(30),
                onTap: () {
                  if (_textController.text.isNotEmpty) {
                    this.widget.onSubmit(_textController.text, {});
                    _textController.clear();
                  }
                },
                child: Container(
                  margin: EdgeInsets.all(2),
                  padding: EdgeInsets.all(4),
                  child: Icon(
                    Icons.send,
                    color: CustomColors.newPinkSecondary,
                    size: 30,
                  ),
                ),
              ),
            )
          ],
        ));
      case 'quickly_answers':
        return QuickAnswers(
          options: this.widget.options,
          onTap: (value) {
            this.widget.onSubmit(value, {});
          },
        );
      case 'quickly_habits':
        return QuickHabits(
          listaHabitos: this.widget.listaHabitos,
          onTap: (habits) {
            this.widget.onSubmit(habits['nombre'], habits);
          },
        );
      case 'close':
        return Container(
          width: size.width * 3 / 4,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
              gradient: LinearGradient(colors: [
                CustomColors.newPurpleSecondary,
                CustomColors.newPinkSecondary
              ])),
          child: ElevatedButton(
            onPressed: () {
              //Navigator.of(context).pushReplacementNamed(MainPage.routerName);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: new BorderRadius.all(Radius.circular(20)),
              ),
            ),
            child: Text(
              "Volver a inicio",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        );
      default:
        return SpinKitPulse(
          color: gradPink,
          size: 35.0,
        );
    }
  }
}

//Logica de "Respuestas Rapidas"

class QuickAnswers extends StatefulWidget {
  final List<QuicklyAnswer> options;
  final Function(String) onTap;

  QuickAnswers({
    required this.options,
    required this.onTap,
  });

  @override
  _QuickAnswersState createState() => _QuickAnswersState();
}

class _QuickAnswersState extends State<QuickAnswers> {
  @override
  Widget build(BuildContext context) {
    
    //Size size = MediaQuery.of(context).size;
    //Controlador de Scroll de respuestas rapidas estandar
    ScrollController scrollControllerQuickReply = ScrollController();

    String startUpOption = '';

    //Se evalua la cantidad de respuestas que se conseguiran con las respuestas rapidas
    //De esta forma se sabe Si son repuestas rapidas comunes o menus especiales.

    if (widget.options.length == 3) {
      String option1 = widget.options[0].value;
      String option2 = widget.options[1].value;
      String option3 = widget.options[2].value;
      startUpOption = option1 + ' ' + option2 + ' ' + option3;
    }
    if (widget.options.length == 4) {
      String option1 = widget.options[0].value;
      String option2 = widget.options[1].value;
      String option3 = widget.options[2].value;
      String option4 = widget.options[3].value;
      startUpOption = option1 + ' ' + option2 + ' ' + option3 + ' ' + option4;
    }
    //respuestas quickreply en esteroides
    print(startUpOption);

    //Logica que muestra una de 3 opciones de Respuestas rapidas
    //-Menu para seleccionar Herramientas
    //-Menu para seleccionar Herramientas de las Comunidades
    //-Menu generico de respuestas rapidas.

    switch (startUpOption) {
      case 'Herramientas de atención Herramientas del propósito Herramientas de las comunidades Herramientas de intención':
        return Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CustomColors.newPinkSecondary,
                CustomColors.newPurpleSecondary,
              ],
            ),
          ),
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: widget.options.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(
              color: Colors.white,
            ),
            itemBuilder: (BuildContext context, int index) {
              String subtitulo = '';
              late Widget iconoLista;

              switch (widget.options[index].value) {
                case 'Herramientas de atención':
                  subtitulo =
                      'Meditaciones, reformula tus pensamientos, define tu propósito y más';
                  iconoLista = Icon(
                    MdiIcons.clouds,
                    size: 40,
                    color: Colors.white,
                  );
                  break;

                case 'Herramientas del propósito':
                  subtitulo = 'Define tu objetivo diario o a largo plazo';
                  iconoLista = Icon(
                    MdiIcons.imageFilterHdr,
                    size: 40,
                    color: Colors.white,
                  );

                  break;
                case 'Herramientas de las comunidades':
                  subtitulo =
                      'Encuentra apoyo y participa del estudio de salud mental';
                  iconoLista = Icon(
                    MdiIcons.forestOutline,
                    size: 40,
                    color: Colors.white,
                  );

                  break;
                case 'Herramientas de intención':
                  subtitulo =
                      'Planta tus hábitos y practícalos en una conversación';
                  iconoLista = Icon(
                    MdiIcons.sproutOutline,
                    size: 40,
                    color: Colors.white,
                  );

                  break;
                default:
              }

              return ListTile(
                onTap: () {
                  this.widget.onTap(widget.options[index].value);
                },
                title: Container(
                  margin: EdgeInsets.only(top: 10, bottom: 5),
                  child: Text(
                    widget.options[index].value,
                    //overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                subtitle: Container(
                  margin: EdgeInsets.only(top: 5, bottom: 5),
                  child: Text(
                    subtitulo,
                    //overflow: TextOverflow.ellipsis,
                    maxLines: 3,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
                trailing: Container(
                  child: iconoLista,
                ),
              );
            },
          ),
        );
      case 'Chat Hablemos de Todo Línea *4141 LíneaLibre.cl':
        return Container(
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                CustomColors.newPinkSecondary,
                CustomColors.newPurpleSecondary,
              ],
            ),
          ),
          height: 210,
          child: ListView.separated(
            physics: NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: widget.options.length,
            separatorBuilder: (BuildContext context, int index) =>
                const Divider(),
            itemBuilder: (BuildContext context, int index) {
              late Widget iconoLista;

              switch (widget.options[index].value) {
                case 'LíneaLibre.cl':
                  iconoLista = Icon(
                    MdiIcons.cellphoneMessage,
                    size: 40,
                    color: Colors.white,
                  );

                  break;
                case 'Chat Hablemos de Todo':
                  iconoLista = Icon(
                    MdiIcons.forumOutline,
                    size: 40,
                    color: Colors.white,
                  );

                  break;
                case 'Línea *4141':
                  iconoLista = Icon(
                    MdiIcons.phoneDialOutline,
                    size: 40,
                    color: Colors.white,
                  );

                  break;
                case 'Más información sobre estas opciones':
                  iconoLista = Icon(
                    MdiIcons.helpCircleOutline,
                    size: 40,
                    color: Colors.white,
                  );

                  break;
                default:
              }

              return ListTile(
                onTap: () {
                  this.widget.onTap(widget.options[index].value);
                },
                title: Text(
                  widget.options[index].value,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                trailing: Container(
                  child: iconoLista,
                ),
              );
            },
          ),
        );
      //
      //Respuestas rapidas estandar
      //(Esto ocurrira casi siempre)

      default:
        return Container(
          child: Column(
            
            children: [
              //Mostrar fila scrolleable de respuestas

              RawScrollbar(
                thumbVisibility: true,
                //thickness: 40,    
                controller: scrollControllerQuickReply,
                thumbColor: CustomColors.newPurpleSecondary,
                trackVisibility: true,
                trackColor: Colors.black87,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  controller: scrollControllerQuickReply,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(widget.options.length, (index) {
                      return Container(
                        margin: EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.symmetric(horizontal: 7),
                        child: InkWell(
                          onTap: () {
                            this.widget.onTap(widget.options[index].value);
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                vertical: 10, horizontal: 15),
                            decoration: BoxDecoration(
                              color: CustomColors.newPinkSecondary,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              widget.options[index].label,
                              style: TextStyle(
                                  fontSize: 17,
                                  color: Colors.white,
                                  fontFamily: 'roboto-regular'),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ],
          ),
        );
    }
  }
}

// Clase para recibir y enviar los hábitos que arroja el JSON
class QuickHabits extends StatefulWidget {
  final List<Map<String, dynamic>> listaHabitos;
  final Function(Map<String, dynamic>) onTap;

  QuickHabits({required this.listaHabitos, required this.onTap});

  @override
  _QuickHabitsState createState() => _QuickHabitsState();
}

class _QuickHabitsState extends State<QuickHabits> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 20,
        direction: Axis.horizontal,
        children: List.generate(widget.listaHabitos.length, (index) {
          return InkWell(
            onTap: () {
              this.widget.onTap(widget.listaHabitos[index]);
            },
            child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                decoration: BoxDecoration(
                  color: CustomColors.newPinkSecondary,
                  borderRadius: BorderRadius.all(
                    Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    widget.listaHabitos[index]['horario'].toString() == 'Diurno'
                        ? Icon(Icons.sunny, color: Colors.white)
                        : Icon(Icons.nights_stay_rounded, color: Colors.white),
                    Text(
                      ' ' +
                          widget.listaHabitos[index]['nombre'].toString() +
                          ' (' +
                          widget.listaHabitos[index]['planta'].toString() +
                          ')',
                      style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontFamily: 'roboto-regular'),
                    ),
                  ],
                )),
          );
        }),
      ),
    );
  }
}
