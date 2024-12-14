import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rive/rive.dart';
import 'package:human_place_app/src/widgets/time_picker.dart';
import 'package:human_place_app/src/widgets/tempo.dart';
import 'package:human_place_app/src/widgets/habit_selector.dart';
import 'package:human_place_app/src/services/firestore_planta.dart';
import 'package:human_place_app/src/screens/character_screen.dart';
import '../logic/tutorial_logic.dart';
import '../services/reward_service.dart';

final GlobalKey habitSection = GlobalKey();
final GlobalKey timeHabit = GlobalKey();
final GlobalKey seedsSection = GlobalKey();
final GlobalKey pourSection = GlobalKey();

class HabitScreen extends StatefulWidget {
  static final routerName = '/habit-screen';
  @override
  _HabitScreenState createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  bool isLoading = true;
  bool _isButtonDisabled = false;

  CollectionReference nameRef =
      FirebaseFirestore.instance.collection('usuarios');

  final FirebaseAuth auth = FirebaseAuth.instance;
  final userId = FirebaseAuth.instance.currentUser!.uid;

  SMIInput<double>? growInput;
  StateMachineController? controller;

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
    //_checkPlantStatusOnLoad();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkTutorialForView(context, "habitscreen");
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      otorgarSemillas(context);
    });
  }

  Future<void> _checkPlantStatusOnLoad() async {
    // Llamar a la función checkPlantStatus con el userId
    await _firestoreService.checkPlantStatus(userId);
    final int daysAchieved =
        7; // Ejemplo: obtener el valor desde Firebase o lógica local
    await _firestoreService.updateMedallas(userId, daysAchieved);

    // Cambiar el estado para indicar que la verificación se completó
    setState(() {
      isLoading = false;
    });
  }

  void _showCharacterScreen(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CharacterScreen(
          imagePath:
              'assets/images/personajes/huillin.png', // Ruta de la imagen en assets
          text: '¡Has completado la acción!',
          onActionCompleted: () {
            Navigator.of(context).pop(); // Cerrar la pantalla
          },
        ),
      ),
    );
  }

  double calculateInputValue(int growthDays) {
    if (growthDays == 0 || growthDays == 1) {
      return 0;
    } else if (growthDays == 2 || growthDays == 3) {
      return 1;
    } else if (growthDays == 4 || growthDays == 5) {
      return 2;
    } else if (growthDays == 6) {
      return 3;
    } else if (growthDays >= 7) {
      return 4;
    } else {
      return 0; // Valor predeterminado si no coincide
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

  void _updateSelectedHabit(String habit) {
    // Guardar el hábito en Firebase
    _saveHabitToFirestore(habit);
  }

  Future<void> _saveHabitToFirestore(String habit) async {
    try {
      // Referencia al documento del usuario
      final userRef =
          FirebaseFirestore.instance.collection('usuarios').doc(userId);

      // Actualizar o establecer el hábito seleccionado en el documento del usuario
      await userRef.set(
          {
            'selectedHabit': habit,
            'updatedAt':
                FieldValue.serverTimestamp(), // Registrar cuándo se actualizó
          },
          SetOptions(
              merge:
                  true)); // Merge asegura que no se sobrescriban otros campos

      print('Hábito guardado correctamente en Firebase.');
    } catch (e) {
      print('Error al guardar el hábito en Firebase: $e');
    }
  }

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
        ),
        body: Center(
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
              key: habitSection,
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  margin: EdgeInsets.symmetric(vertical: 5),
                  width: size.width - 40,
                  alignment: Alignment.center,
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
                        "Mi hábito diario",
                        style: TextStyle(
                            color: Colors.white,
                            fontFamily: fuente,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('usuarios')
                            .doc(userId)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator(); // Mostrar un indicador de carga
                          }

                          if (snapshot.hasError) {
                            return Text(
                              'Error al cargar el hábito.',
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: fuente,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }

                          if (!snapshot.hasData || !snapshot.data!.exists) {
                            return Text(
                              'No se ha seleccionado ningún hábito.',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: fuente,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }

                          final data =
                              snapshot.data!.data() as Map<String, dynamic>?;
                          final String? selectedHabit = data?['selectedHabit'];

                          if (selectedHabit == null) {
                            return Text(
                              'No se ha seleccionado ningún hábito.',
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: fuente,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            );
                          }

                          return Text(
                            '$selectedHabit',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: fuente,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 5)),
                        onPressed: () => showHabitDialog(
                          context: context,
                          onHabitSelected: _updateSelectedHabit,
                        ),
                        child: Text(
                          "Escoger hábito",
                          style: TextStyle(fontFamily: fuente, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Container(
                            key: timeHabit,
                            alignment: Alignment.center,
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                            padding: EdgeInsets.all(0),
                            width: (size.width / 2) - 20,
                            decoration: BoxDecoration(
                              color:
                                  Colors.white, // Fondo blanco para la pizarra
                              borderRadius: BorderRadius.circular(
                                  5), // Bordes redondeados
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                      0.7), // Sombra alrededor de la pizarra
                                  spreadRadius: 2,
                                  blurRadius: 5,
                                  offset:
                                      Offset(0, 6), // Dirección de la sombra
                                ),
                              ],
                              border: Border.all(
                                color: Colors
                                    .black, // Marco negro alrededor de la pizarra
                                width: 2,
                              ),
                            ),
                            child: Column(
                              children: [
                                Text(
                                  "Hora de riego:",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: fuente,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "${_selectedTime.format(context)}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontFamily: fuente,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 2),
                                /* TimePickerAlertDialog(
                          onTimeSelected: _onTimeSelected,
                        ), */
                                StreamBuilder<DocumentSnapshot>(
                                  stream: FirebaseFirestore.instance
                                      .collection('usuarios')
                                      .doc(userId)
                                      .snapshots(),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator(); // Mostrar un indicador de carga
                                    }

                                    if (snapshot.hasError) {
                                      return Text(
                                        'Error al cargar el hábito.',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontFamily: fuente,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    }

                                    if (!snapshot.hasData ||
                                        !snapshot.data!.exists) {
                                      return Text(
                                        'No se ha seleccionado ningún hábito.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: fuente,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    }

                                    final data = snapshot.data!.data()
                                        as Map<String, dynamic>?;
                                    final String? selectedHabit =
                                        data?['selectedHabit'];

                                    if (selectedHabit == null) {
                                      return Text(
                                        'No se ha seleccionado ningún hábito.',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontFamily: fuente,
                                          color: Colors.white,
                                        ),
                                        textAlign: TextAlign.center,
                                      );
                                    }

                                    return IconButton(
                                      icon: Icon(Icons.alarm),
                                      onPressed: () {
                                        _onTimeSelected(_selectedTime);
                                      },
                                    );
                                  },
                                ),
                              ],
                            )),
                        Container(
                          key: seedsSection,
                          margin: EdgeInsets.fromLTRB(0, 5, 0, 5),
                          //padding: EdgeInsets.all(5),
                          width: (size.width / 2) - 20,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.lightGreen.shade400,
                            border: Border.all(color: Colors.green, width: 2),
                            borderRadius: BorderRadius.circular(2),
                          ),
                          child: Column(children: [
                            StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('usuarios')
                                  .doc(userId)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return CircularProgressIndicator();
                                }

                                final userData = snapshot.data!.data()
                                    as Map<String, dynamic>;
                                final int protectores =
                                    userData['protectores'] ?? 0;
                                final int semillas = userData['semillas'] ?? 0;

                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Semillas: $semillas',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: fuente,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'Protectores: $protectores',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontFamily: fuente,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 5)),
                                      onPressed: () async {
                                        final firestoreService =
                                            FirestoreService();
                                        await firestoreService
                                            .convertirSemillasAProtectores(
                                                userId);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '¡Conversión intentada! Verifica tu saldo y protectores.'),
                                          ),
                                        );
                                      },
                                      child: Text('Convertir'),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ]),
                        ),
                      ]),
                ),
                IntrinsicWidth(
                  child: Container(
                      padding: EdgeInsets.all(5),
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
                              fontSize: 18,
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
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.center, // Centra los botones
                            children: [
                              ElevatedButton(
                                onPressed: _editTimer == null
                                    ? null
                                    : () => _editTimer(context),
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
                                  backgroundColor: _isTimerRunning
                                      ? Colors.deepOrange.shade300
                                      : Colors.lightGreenAccent.shade200,
                                ),
                                child: Text(
                                  _isTimerRunning ? "Pausar" : "Empezar",
                                  style: TextStyle(
                                      fontFamily: fuente, fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                ),
                SizedBox(height: 5),
                Stack(alignment: Alignment.bottomCenter, children: [
                  StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(userId) // Reemplaza con el ID del usuario actual
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Indicador de carga
                        }

                        if (snapshot.hasError) {
                          return Text('Error al cargar los datos.');
                        }

                        if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text('No hay datos disponibles.');
                        }

                        final userData =
                            snapshot.data!.data() as Map<String, dynamic>?;
                        final String? plantaActiva =
                            userData?['plantaActiva'] as String?;

                        // Verificar si plantaActiva está definido
                        if (plantaActiva == null || plantaActiva.isEmpty) {
                          return Text('No hay una planta activa seleccionada.');
                        }

                        // Consultar el documento en la subcolección 'plantas'
                        return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(userId)
                              .collection('plant_growth')
                              .doc(plantaActiva) // Usar el ID de plantaActiva
                              .snapshots(),
                          builder: (context, plantSnapshot) {
                            if (plantSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }

                            if (plantSnapshot.hasError) {
                              return Text(
                                  'Error al cargar los datos de la planta.');
                            }

                            if (!plantSnapshot.hasData ||
                                !plantSnapshot.data!.exists) {
                              return Text(
                                  'No se encontraron datos para la planta activa.');
                            }

                            // Obtener los datos del documento de la planta
                            final plantData = plantSnapshot.data!.data()
                                as Map<String, dynamic>?;
                            final int growthDays =
                                plantData?['growthDays'] ?? 0;
                            if (growInput != null) {
                              growInput!.value =
                                  calculateInputValue(growthDays);
                            }

                            return Container(
                              width: 210,
                              height: 220,
                              margin: EdgeInsets.symmetric(
                                  vertical: 20, horizontal: 10),
                              child: RiveAnimation.asset(
                                'assets/animationsRive/growing_plant.riv',
                                fit: BoxFit.fitHeight,
                                onInit: (artboard) {
                                  // Inicializar el controlador solo si no está ya configurado
                                  /* if (controller == null) {
                                    controller =
                                        StateMachineController.fromArtboard(
                                            artboard,
                                            'Plant'); // Cambia por el nombre de tu StateMachine
                                    if (controller != null) {
                                      artboard.addController(controller!
                                          as RiveAnimationController<dynamic>);

                                      // Encontrar el input 'Grow' y asignarlo
                                      growInput =
                                          controller!.findInput<double>('Grow');
                                      if (growInput != null) {
                                        growInput!.value =
                                            calculateInputValue(growthDays);
                                      }
                                    }
                                  } */
                                  if (controller == null) {
                                    controller =
                                        StateMachineController.fromArtboard(
                                            artboard, 'Plant');
                                    if (controller != null) {
                                      artboard.addController(controller!);
                                      growInput =
                                          controller!.findInput<double>('Grow');
                                      if (growInput != null) {
                                        growInput!.value =
                                            calculateInputValue(growthDays);
                                      }
                                    }
                                  }
                                },
                              ),
                            );
                          },
                        );
                      }),
                  StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('usuarios')
                          .doc(userId)
                          .snapshots(),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator(); // Indicador mientras se cargan datos
                        }

                        if (userSnapshot.hasError) {
                          return Text('Error al cargar datos del usuario');
                        }

                        if (!userSnapshot.hasData ||
                            !userSnapshot.data!.exists) {
                          return Text(
                              'No hay datos disponibles para el usuario');
                        }

                        // Obtener plantId del usuario
                        final Map<String, dynamic>? userData =
                            userSnapshot.data!.data() as Map<String, dynamic>?;

                        final String? existingPlantId =
                            userData?['plantaActiva'];

                        if (userData == null ||
                            !userData.containsKey('plantaActiva') ||
                            userData['plantaActiva'] == null) {
                          return ElevatedButton(
                            onPressed: () async {
                              // Lógica para plantar
                              try {
                                final firestoreService = FirestoreService();
                                final plantId =
                                    await firestoreService.addPlantGrowthData(
                                  userId:
                                      userId, // Reemplaza con el ID del usuario
                                  growthDays:
                                      0, // Inicializa en 0 días de crecimiento
                                  wateringStartDate: DateTime
                                      .now(), // Fecha actual como inicio
                                  lastWateringDate: DateTime
                                      .now(), // Fecha actual como último riego
                                  protectors:
                                      1, // Número de protectores iniciales
                                  isAlive:
                                      true, // Indica que la planta está viva
                                );
                                await FirebaseFirestore.instance
                                    .collection('usuarios')
                                    .doc(userId)
                                    .update({
                                  'plantaActiva': plantId,
                                });

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Nueva planta creada con ID: $plantId')),
                                );
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content:
                                          Text('Error al crear la planta: $e')),
                                );
                              }
                            },
                            child: Text('Plantar'),
                          );
                        } else {
                          // Usar otro StreamBuilder para escuchar datos específicos de la planta activa
                          return StreamBuilder<DocumentSnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('usuarios')
                                  .doc(userId)
                                  .collection('plant_growth')
                                  .doc(existingPlantId)
                                  .snapshots(),
                              builder: (context, plantSnapshot) {
                                if (plantSnapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return CircularProgressIndicator(); // Indicador mientras se cargan datos
                                }

                                if (plantSnapshot.hasError) {
                                  return Text(
                                      'Error al cargar datos de crecimiento de la planta');
                                }

                                if (!plantSnapshot.hasData ||
                                    !plantSnapshot.data!.exists) {
                                  return Text(
                                      'No hay datos disponibles para la planta');
                                }

                                // Obtener los días de crecimiento
                                final data = plantSnapshot.data!.data();
                                final Map<String, dynamic>? plantData =
                                    data as Map<String, dynamic>?;

                                if (plantData == null ||
                                    !plantData.containsKey('growthDays')) {
                                  return Text(
                                      'No se encontró el dato growthDays');
                                }

                                final int growthDays = plantData['growthDays'];

                                return Container(
                                  margin: EdgeInsets.only(bottom: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.amber,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                      color: Colors.black,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    'Día: $growthDays',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: fuente, fontSize: 16),
                                  ),
                                );
                              });
                        }
                      })
                ]),

                //REGAR

                StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('usuarios')
                        .doc(userId)
                        .snapshots(),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator(); // Indicador mientras se cargan datos
                      }

                      if (userSnapshot.hasError) {
                        return Text('Error al cargar datos del usuario');
                      }

                      if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                        return Text('No hay datos disponibles para el usuario');
                      }

                      // Obtener plantId del usuario
                      final Map<String, dynamic>? userData =
                          userSnapshot.data!.data() as Map<String, dynamic>?;

                      final String? existingPlantId = userData?['plantaActiva'];

                      if (existingPlantId == null) {
                        return Text('No hay planta activa');
                      }

                      // Usar otro StreamBuilder para escuchar datos específicos de la planta activa
                      return StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('usuarios')
                              .doc(userId)
                              .collection('plant_growth')
                              .doc(existingPlantId)
                              .snapshots(),
                          builder: (context, plantSnapshot) {
                            if (plantSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return CircularProgressIndicator(); // Indicador mientras se cargan datos
                            }

                            if (plantSnapshot.hasError) {
                              return Text(
                                  'Error al cargar datos de crecimiento de la planta');
                            }

                            if (!plantSnapshot.hasData ||
                                !plantSnapshot.data!.exists) {
                              return Text(
                                  'No hay datos disponibles para la planta');
                            }

                            // Verificar lastWateringDate
                            final data = plantSnapshot.data!.data();
                            final Map<String, dynamic>? plantData =
                                data as Map<String, dynamic>?;

                            _isButtonDisabled = false;
                            if (plantData != null &&
                                plantData.containsKey('lastWateringDate')) {
                              final dynamic rawTimestamp =
                                  plantData['lastWateringDate'];

                              if (rawTimestamp != null &&
                                  rawTimestamp is Timestamp) {
                                final DateTime lastWateringDate =
                                    rawTimestamp.toDate();

                                // Comparar solo la fecha (sin horas)
                                final now = DateTime.now();
                                if (lastWateringDate.year == now.year &&
                                    lastWateringDate.month == now.month &&
                                    lastWateringDate.day == now.day) {
                                  _isButtonDisabled = true;
                                }
                                ;
                              }
                            } else {
                              print(
                                  "El campo 'lastWateringDate' es null o no es un Timestamp válido.");
                            }
                            ;
                            return ElevatedButton(
                              key: pourSection,
                              style: ElevatedButton.styleFrom(
                                disabledForegroundColor: Colors.black45,
                                backgroundColor: Colors.blue, // Color de fondo
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12), // Tamaño del botón
                                textStyle: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              onPressed: _isButtonDisabled
                                  ? null // Si está deshabilitado, el botón no tiene acción
                                  : () async {
                                      try {
                                        // Instanciar el servicio Firestore
                                        final firestoreService =
                                            FirestoreService();

                                        // Variable para almacenar el valor de plantId si ya existe
                                        String? existingPlantId;

                                        // Verificar si el usuario ya tiene un plantId activo
                                        final plantIdExists =
                                            !(await _firestoreService
                                                .verificarDatoFirestore(
                                                    "usuarios",
                                                    userId,
                                                    "plantaActiva",
                                                    false));

                                        if (plantIdExists) {
                                          final docSnapshot =
                                              await FirebaseFirestore.instance
                                                  .collection('usuarios')
                                                  .doc(userId)
                                                  .get();
                                          existingPlantId = docSnapshot
                                              .data()?['plantaActiva'];
                                          // Si ya existe plantId o no es false, actualizar los datos de crecimiento
                                          await firestoreService
                                              .updatePlantGrowthData(
                                                  userId, existingPlantId);

                                          _showCharacterScreen(context);

                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Datos de crecimiento actualizados correctamente')),
                                          );
                                        } else {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                                content: Text(
                                                    'Debes plantar primero')),
                                          );
                                        }
                                      } catch (e) {
                                        // Manejo de errores
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Error al procesar los datos: $e')),
                                        );
                                      }
                                    },
                              child: Text('Regar',
                                  style: TextStyle(
                                      color: Colors.white, fontFamily: fuente)),
                            );
                          });
                    }),
              ],
            ),
          ),
        ));
  }

  void dispose() {
    controller?.dispose();
    growInput = null;
    super.dispose();
  }
}
