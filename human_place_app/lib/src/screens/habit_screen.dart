import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
/*import 'package:human_place_app/src/screens/home_screen.dart';
import 'package:human_place_app/src/routes.dart';
import 'package:human_place_app/src/screens/main_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
 */
import 'package:human_place_app/src/colors.dart';
import 'package:rive/rive.dart';
import 'package:human_place_app/src/widgets/time_picker.dart';
import 'package:human_place_app/src/widgets/tempo.dart';

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

  void _showTimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: TimerDialog(
            onTimerComplete: (remainingTime) {
              // Manejar el evento cuando el temporizador termine
              print("Timer completed with $remainingTime seconds left.");
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
        backgroundColor: Colors.indigo.shade900,
        appBar: AppBar(
          title: Text('Mi rincón verde'),
          centerTitle: true,
          backgroundColor: Colors.lightGreen.withOpacity(0.9),
        ),
        body: Center(
          //mainAxisAlignment: MainAxisAlignment.center,
          child: Container(
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
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    color: Colors.amber,
                    width: size.width,
                    child: Column(
                      children: [
                        Text(
                          "Hora de riego: ${_selectedTime.format(context)}",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 10),
                        TimePickerAlertDialog(
                          onTimeSelected: _onTimeSelected,
                        ),
                      ],
                    )),
                Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(10),
                    color: Colors.amber,
                    width: size.width,
                    child: Column(
                      children: [
                        Text(
                          "Hora de riego: ${_selectedTime.format(context)}",
                          style: TextStyle(fontSize: 20),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () => _showTimer(context),
                          child: Text("Open Timer"),
                        ),
                      ],
                    )),
                Spacer(),
                if (_riveArtboard != null)
                  Container(
                    height: 400,
                    width: size.width - 80,
                    child: Rive(
                      fit: BoxFit.cover,
                      artboard: _riveArtboard!,
                    ),
                  ),
                SizedBox(
                  height: 50,
                )

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
