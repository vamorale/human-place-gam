// ignore_for_file: unused_element

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/models/quickly_answer.dart';
import 'package:human_place_app/src/services/dialogflow.dart';
import 'package:human_place_app/src/widgets/item_messaage.dart';

enum StateDay { Day, Night }

class ChatPage extends StatefulWidget {
  ChatPage(this.mode);
  final mode;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final DialogflowService dialogFlowService = DialogflowService();
  List<ItemMessage> _messages = [];
  String _sessionId = 'session_1';
  String _currentAction = 'text';
  List<QuicklyAnswer> _options = [];
  late StateDay _stateDay;

  void _sendQueryBot(String query, BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;

    setState(() {
      if (query != 'Testear' &&
          query != 'VerListas' &&
          query != 'RespInstrumento' &&
          query != 'ReformPensamientos') {
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

    final response = await dialogFlowService.detectIntent(
      query,
      sessionId: _sessionId,
      userId: user!.uid,
    );
    print("RESPONSE: ${response.diagnosticInfo}");

    if (response.beforeMessages.isNotEmpty) {
      final list = response.beforeMessages.map((e) => ItemMessage(
          type: 'text',
          content: e,
          listOfContent: [],
          listOfContentAUX1: [],
          listOfContentAUX2: [],
          nivel: 0));
      _messages.addAll(list);
    }

    final m = response.fulfillmentMessages
        .where((element) => element.containsKey('text'))
        .map((element) => element['text']['text'].first as String)
        .toList();

    final list = m.map((e) => ItemMessage(
        type: 'text',
        content: e,
        listOfContent: [],
        listOfContentAUX1: [],
        listOfContentAUX2: [],
        nivel: 0));
    _messages.addAll(list);

    final payload = response.fulfillmentMessages
        .where((element) => element.containsKey('payload'));

    List<String> options = [];
    bool endConversation =
        dialogFlowService.endedConversation(response.diagnosticInfo);

    if (endConversation) {
      setState(() {
        _currentAction = 'close';
        _options = [];
      });
    } else {
      if (payload.isNotEmpty) {
        final fields = payload.first['payload']['fields'];
        options = dialogFlowService.parseOptions(fields);

        if (options.isNotEmpty) {
          setState(() {
            _currentAction = 'quickly_answers';
            _options = List<QuicklyAnswer>.from(
                options.map((e) => QuicklyAnswer(e, e)));
          });
        }

        if (dialogFlowService.hasAudio(fields)) {
          final url = dialogFlowService.getAudio(fields);
          _messages.add(ItemMessage(
              content: url,
              type: 'audio',
              listOfContent: [],
              listOfContentAUX1: [],
              listOfContentAUX2: [],
              nivel: 0));
        }

        if (dialogFlowService.hasCard(fields)) {
          final card = dialogFlowService.getCard(fields);
          _messages.add(ItemMessage(
            listOfContent: card,
            type: 'card',
            listOfContentAUX1: [],
            listOfContentAUX2: [],
            nivel: 0,
            content: '',
          ));
        }

        if (dialogFlowService.hasImage(fields)) {
          final url = dialogFlowService.getImage(fields);
          _messages.add(ItemMessage(
              content: url,
              type: 'image',
              listOfContent: [],
              listOfContentAUX1: [],
              listOfContentAUX2: [],
              nivel: 0));
        }
        // whatsapp
        if (dialogFlowService.hasWhatsapp(fields)) {
          final url = dialogFlowService.getWhatsapp(fields);
          _messages.add(ItemMessage(
            content: url,
            type: 'whatsappChat',
            listOfContent: [],
            listOfContentAUX1: [],
            listOfContentAUX2: [],
            nivel: 0,
          ));
        }

        if (dialogFlowService.hasGif(fields)) {
          final url = dialogFlowService.getGif(fields);
          _messages.add(ItemMessage(
              content: url,
              type: 'gif',
              listOfContent: [],
              listOfContentAUX1: [],
              listOfContentAUX2: [],
              nivel: 0));
        }

        if (dialogFlowService.hasURL(fields)) {
          final url = dialogFlowService.getURL(fields);
          _messages.add(ItemMessage(
              content: url,
              type: 'url',
              listOfContent: [],
              listOfContentAUX1: [],
              listOfContentAUX2: [],
              nivel: 0));
        }

        if (dialogFlowService.hasVideo(fields)) {
          final url = dialogFlowService.getVideo(fields);
          _messages.add(ItemMessage(
              content: url,
              type: 'videoYT',
              listOfContent: [],
              listOfContentAUX1: [],
              listOfContentAUX2: [],
              nivel: 0));
        }
        if (dialogFlowService.hasAnimation(fields)) {
          final url = dialogFlowService.getAnimation(fields);
          print(')))>>> ' + url);
          _messages.add(ItemMessage(
              content: url,
              type: 'animacion',
              listOfContent: [],
              listOfContentAUX1: [],
              listOfContentAUX2: [],
              nivel: 0));
        }

        if (dialogFlowService.hasListTitle(fields)) {
          final listTitle = dialogFlowService.getListTitle(fields);
          final listDescription = dialogFlowService.getListDescription(fields);

          final listImage = dialogFlowService.getListImage(fields);
          _messages.add(ItemMessage(
            listOfContent: listTitle,
            listOfContentAUX1: listDescription,
            listOfContentAUX2: listImage,
            type: 'list',
            content: url,
            nivel: 0,
          ));
        }
        if (dialogFlowService.hasMultipleChoice(fields)) {
          final choices = dialogFlowService.getMultipleChoice(fields);
          _messages.add(ItemMessage(
            listOfContent: choices,
            type: 'multiple',
            listOfContentAUX1: [],
            listOfContentAUX2: [],
            nivel: 0,
            content: '',
          ));
        }

        if (dialogFlowService.hasSimpleList(fields)) {
          final listValues = dialogFlowService.getSimpleList(fields);
          _messages.add(ItemMessage(
            listOfContent: listValues,
            type: 'simpleList',
            listOfContentAUX1: [],
            listOfContentAUX2: [],
            nivel: 0,
            content: '',
          ));
        }
      } else {
        _currentAction = 'text';
      }

      setState(() {
        if (response.afterMessages.isNotEmpty) {
          final list = response.afterMessages.map((e) => ItemMessage(
              type: 'text',
              content: e,
              listOfContent: [],
              listOfContentAUX1: [],
              listOfContentAUX2: [],
              nivel: 0));
          _messages.addAll(list);
        }
      });
    }
  }

  String get _labelGreeting {
    DateTime now = DateTime.now();

    if (now.hour > 5 && now.hour < 12) {
      _stateDay = StateDay.Day;
      return 'Hola, muy buenos días.';
    } else if (now.hour >= 12 && now.hour < 18) {
      _stateDay = StateDay.Day;
      return 'Hola, muy buenas tardes.'; //tardes
    } else {
      _stateDay = StateDay.Night;
      return 'Hola, muy buenas noches.';
    }
  }

  String get _stateDayG {
    if (_stateDay == StateDay.Day) {
      return 'este día.';
    } else {
      return 'esta noche.';
    }
  }

  String get _currentSession {
    // return range 01 between 28
    String session = '';
    if (_stateDay == StateDay.Day) {
      session = 'Dia_28';
      return session;
    } else {
      if (true) {
        session = 'Noche_28';
        return session;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    //launches test options, current session or show lists depending on the button selected on the main page
    late String query;
    switch (widget.mode) {
      case 0:
        query = 'Testear';
        break;
      case 1:
        query = _currentSession;
        break;
      case 2:
        query = 'VerListas';
        break;
      case 3:
        query = 'RespInstrumento';
        break;
      case 4:
        query = 'ReformPensamientos';
        break;
    }
    _sendQueryBot(query, context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    double bottomHeight;
    if (_currentAction == 'text') {
      bottomHeight = 0.0;
    } else {
      bottomHeight = 10 + size.height / 15;
    }

    return Padding(
      padding: EdgeInsets.only(bottom: bottomHeight),
      child: Container(
        child: Column(
          children: [
            Flexible(
              child: ListView.builder(
                physics: BouncingScrollPhysics(),
                reverse: true,
                itemBuilder: (_, int index) {
                  var _msgsR = new List.from(_messages.reversed);
                  return index == 0
                      ? Container(
                          margin: EdgeInsets.only(
                            bottom: 70,
                            left: 12,
                            right: 12,
                          ),
                          child: _msgsR[index],
                        )
                      : Container(
                          margin: EdgeInsets.symmetric(horizontal: 12),
                          child: _msgsR[index],
                        );
                },
                itemCount: _messages.length,
              ),
            ),
            BottomWidget(
              options: _options,
              action: _currentAction,
              onSubmit: (value) {
                _sendQueryBot(value, context);
              },
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }
}

class BottomWidget extends StatefulWidget {
  final String action;
  final Function(String) onSubmit;
  final List<QuicklyAnswer> options;

  BottomWidget({
    required this.action,
    required this.onSubmit,
    required this.options,
  });

  @override
  _BottomWidgetState createState() => _BottomWidgetState();
}

class _BottomWidgetState extends State<BottomWidget> {
  TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    switch (widget.action) {
      case 'text':
        return Container(
          child: Row(
            children: <Widget>[
              SizedBox(
                width: 8,
              ),
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  child: TextField(
                    autofocus: true,
                    controller: _textController,
                    maxLines: null,
                    cursorColor: primary,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                      hintText: 'Mensaje a enviar',
                      hintStyle: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                          fontFamily: 'roboto-regular'),
                      isDense: true,
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.all(7),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            18,
                          ),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            18,
                          ),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            18,
                          ),
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            18,
                          ),
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.transparent),
                        borderRadius: BorderRadius.all(
                          Radius.circular(
                            18,
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
                margin: EdgeInsets.only(
                  left: 10,
                ),
                child: InkWell(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    this.widget.onSubmit(_textController.text);
                    _textController.clear();
                  },
                  child: Container(
                    margin: EdgeInsets.all(5),
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: gradPink,
                    ),
                    child: Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      case 'quickly_answers':
        return QuickAnswers(
          options: this.widget.options,
          onTap: (value) {
            this.widget.onSubmit(value);
          },
        );

      case 'close':
        return Container();
      default:
        return SpinKitThreeBounce(
          color: gradPink,
          size: 50.0,
        );
    }
  }
}

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
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 12,
        runSpacing: 20,
        direction: Axis.horizontal,
        children: List.generate(widget.options.length, (index) {
          return InkWell(
            onTap: () {
              this.widget.onTap(widget.options[index].value);
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 15),
              decoration: BoxDecoration(
                color: gradPink,
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
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
          );
        }),
      ),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double? trackHeight = sliderTheme.trackHeight;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight!) / 2;
    final double trackWidth = parentBox.size.width;

    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
