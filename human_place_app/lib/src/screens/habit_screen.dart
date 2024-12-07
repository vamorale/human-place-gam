import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
/*import 'package:human_place_app/src/screens/home_screen.dart';
import 'package:human_place_app/src/routes.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
 */
import 'package:human_place_app/src/colors.dart';
import 'package:human_place_app/src/screens/about_app.dart';
import 'package:rive/rive.dart';
import 'package:human_place_app/src/widgets/time_picker.dart';
import 'package:human_place_app/src/widgets/tempo.dart';
import 'package:human_place_app/src/widgets/habit_selector.dart';

class HabitScreen extends StatefulWidget {
  static final routerName = '/habit-screen';
  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  //RIVE
  SMIInput<double>? _sliderInput; // Controlador para el input numérico
  Artboard? _riveArtboard;
  //TIMEPICKER
  TimeOfDay _selectedTime = TimeOfDay.now();
  void _onTimeSelected(TimeOfDay time) {
    setState(() {
      _selectedTime = time;
    });
  }

  @override
  void initState() {
    super.initState();
    // Cargar la animación .riv
    rootBundle.load('assets/animationsRive/growing_plant.riv').then(
      (data) async {
        final file = RiveFile.import(data);
        final artboard = file.mainArtboard;

        // Vincular los inputs del controlador a los inputs del archivo Rive
        var controller = StateMachineController.fromArtboard(artboard, 'Plant');
        if (controller != null) {
          artboard.addController(controller);
          _sliderInput =
              controller.findInput<double>('Grow'); // Nombre del input numérico
        }

        setState(() => _riveArtboard = artboard);
      },
    );
  }

  void _updateSlider(double value) {
    if (_sliderInput != null) {
      _sliderInput!.value = value; // Actualizar el valor del input numérico
    }
  }

  Duration _selectedDuration = Duration(minutes: 1);
  bool _isTimerRunning = false;
  final String fuente = 'sen-regular';

  void _editTimer(BuildContext context) {
    Duration tempDuration = _selectedDuration;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Configurar tiempo",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: fuente)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Ingresa la duración (en minutos):",
                      style: TextStyle(fontFamily: fuente)),
                  SizedBox(
                    height: 5,
                  ),
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: "Minutos (1 a 60)",
                        labelStyle: TextStyle(fontFamily: fuente)),
                    onChanged: (value) {
                      int? minutes = int.tryParse(value);
                      if (minutes != null && minutes >= 1 && minutes <= 60) {
                        setState(() {
                          tempDuration = Duration(minutes: minutes);
                        });
                      }
                    },
                  ),
                  SizedBox(height: 20),
                  Slider(
                    min: 1,
                    max: 60,
                    divisions: 59,
                    label: "${tempDuration.inMinutes} minutos",
                    value: tempDuration.inMinutes.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        tempDuration = Duration(minutes: value.toInt());
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    "Cancelar",
                    style: TextStyle(fontFamily: fuente),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(tempDuration);
                  },
                  child: Text(
                    "Fijar tiempo",
                    style: TextStyle(fontFamily: fuente),
                  ),
                ),
              ],
            );
          },
        );
      },
    ).then((newDuration) {
      if (newDuration != null && newDuration is Duration) {
        setState(() {
          _selectedDuration = newDuration;
          _isTimerRunning =
              false; // Detener el temporizador al cambiar la duración
        });
      }
    });
  }

  String _selectedHabit = "Selecciona un hábito"; // Hábito inicial

  void _updateSelectedHabit(String habit) {
    setState(() {
      _selectedHabit = habit;
    });
  }

  /* void _startTimer() {
    setState(() {
      _isTimerStarted = true;
    });
  } */
  void _toggleTimer() {
    setState(() {
      _isTimerRunning = !_isTimerRunning;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Color.fromARGB(255, 1, 49, 26),
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 1, 49, 26),
          title: Text(
            'Mi rincón verde',
            style: TextStyle(
                fontFamily: fuente,
                color: Colors.white,
                fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Colors.white, // Cambia el color de la flecha aquí
          ),
          //backgroundColor: Colors.lightGreen.withOpacity(0.9),
        ),
        body: Center(
          //mainAxisAlignment: MainAxisAlignment.center,
          child: Container(
            width: size.width,
            decoration: BoxDecoration(
              image: DecorationImage(
                image:
                    AssetImage("assets/images/tablas.png"), // Ruta de la imagen
                fit: BoxFit.cover, // Ajusta la imagen al tamaño del Container
              ),
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.symmetric(vertical: 5),
                  width: size.width - 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF8B4513),
                    borderRadius: BorderRadius.circular(5),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black, // Sombra alrededor del tablón
                        blurRadius: 6,
                        offset: Offset(0, 6),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.black,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Mi hábito",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: fuente,
                            fontWeight: FontWeight.bold,
                            fontSize: 20),
                      ),
                      Text(
                        _selectedHabit,
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: fuente,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      ElevatedButton(
                        onPressed: () => showHabitDialog(
                          context: context,
                          onHabitSelected: _updateSelectedHabit,
                        ),
                        child: Text(
                          "Escoger hábito",
                          style: TextStyle(fontFamily: fuente),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                    padding: EdgeInsets.all(5),
                    //color: Colors.amber,
                    width: size.width - 40,
                    decoration: BoxDecoration(
                      color: Colors.white, // Fondo blanco para la pizarra
                      borderRadius:
                          BorderRadius.circular(5), // Bordes redondeados
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(
                              0.7), // Sombra alrededor de la pizarra
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 6), // Dirección de la sombra
                        ),
                      ],
                      border: Border.all(
                        color:
                            Colors.black, // Marco negro alrededor de la pizarra
                        width: 2,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Hora de riego: ${_selectedTime.format(context)}",
                          style: TextStyle(
                              fontSize: 20,
                              fontFamily: fuente,
                              fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 2),
                        TimePickerAlertDialog(
                          onTimeSelected: _onTimeSelected,
                        ),
                      ],
                    )),
                IntrinsicWidth(
                  child: Container(
                      //margin: EdgeInsets.only(bottom: 5),
                      padding: EdgeInsets.all(5),
                      //padding: EdgeInsets.symmetric(vertical: 20, horizontal: 40), // Espaciado interno
                      decoration: BoxDecoration(
                        color: Colors.black, // Fondo del reloj
                        borderRadius:
                            BorderRadius.circular(20), // Bordes redondeados
                        border: Border.all(
                          color: Colors.grey.shade800, // Borde exterior
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                                0.7), // Sombra alrededor de la pizarra
                            spreadRadius: 2,
                            blurRadius: 4,
                            offset: Offset(0, 4), // Dirección de la sombra
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            "Temporizador",
                            style: TextStyle(
                              fontSize: 20,
                              fontFamily: fuente,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          TimerWidget(
                            duration: _selectedDuration,
                            isTimerRunning:
                                _isTimerRunning, // Control del estado del temporizador
                          ),
                          //SizedBox(height: 0),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Centra los botones
                            children: [
                              ElevatedButton(
                                onPressed: _editTimer == null
                                    ? null
                                    : () => _editTimer(context),
                                style: ElevatedButton.styleFrom(
                                  minimumSize:
                                      Size(110, 40), // Ancho y alto específicos
                                ),
                                child: Text(
                                  "Editar",
                                  style: TextStyle(fontFamily: fuente),
                                ),
                              ),
                              SizedBox(
                                  width: 10), // Espaciado entre los botones
                              ElevatedButton(
                                onPressed: _toggleTimer,
                                style: ElevatedButton.styleFrom(
                                  minimumSize: Size(110, 40),
                                  backgroundColor: _isTimerRunning
                                      ? Colors.deepOrange.shade300
                                      : Colors.lightGreenAccent.shade200,
                                ),
                                child: Text(
                                  _isTimerRunning ? "Pausar" : "Empezar",
                                  style: TextStyle(fontFamily: fuente),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),

                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    if (_riveArtboard != null)
                      Container(
                        height: 210,
                        width: 170,
                        margin: EdgeInsets.only(top: 20),
                        child: Rive(
                          fit: BoxFit.cover,
                          artboard: _riveArtboard!,
                        ),
                      ),
                    Container(
                      margin: EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius:
                          BorderRadius.circular(5),
                        border: Border.all(
                          color: Colors.black,
                          width: 2,
                        ),
                      ),

                      //width: 250, // Ajusta el ancho de la caja de texto
                      child: Text(
                        'Día: ',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontFamily: fuente, fontSize: 16),
                      ),
                    ),
                  ],
                ),
                /*  SizedBox(
                  height: 50,
                ), */
                //Spacer(),
                ElevatedButton(
                  onPressed: () {
                    _sliderInput?.value += 1;
                    // Acción al presionar el botón
                    /* ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("¡Planta regada!"),
                            ),
                          ); */
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Color de fondo
                    //onPrimary: Colors.white, // Color del texto
                    padding: EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12), // Tamaño del botón
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    "Regar",
                    style: TextStyle(color: Colors.white, fontFamily: fuente),
                  ),
                ),

                /* Slider(
            min: 0, // Valor mínimo del slider
            max: 4, // Valor máximo del slider
            value: _sliderInput?.value ?? 0,
            onChanged: _updateSlider, // Actualizar el valor del slider
            divisions: 4, // Divisiones para un paso más suave
            label: _sliderInput?.value.toStringAsFixed(1), // Mostrar el valor actual
          ), */
              ],
            ),
          ),
        ));
  }
}
