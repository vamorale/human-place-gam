import 'dart:async';
import 'package:flutter/material.dart';

class TimerWidget extends StatefulWidget {
  final Duration duration;
  final bool isTimerRunning; // Cambiado de `isTimerStarted` a `isTimerRunning`

  const TimerWidget({
    Key? key,
    required this.duration,
    required this.isTimerRunning,
  }) : super(key: key);

  @override
  _TimerWidgetState createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Duration _remainingTime;
  Timer? _timer;
  final String fuente = 'sen-regular';

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
  }

  @override
  void didUpdateWidget(TimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.duration != widget.duration) {
      _resetTimer(widget.duration);
    }

    if (oldWidget.isTimerRunning != widget.isTimerRunning) {
      if (widget.isTimerRunning) {
        _startTimer();
      } else {
        _pauseTimer();
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > Duration.zero) {
        setState(() {
          _remainingTime -= Duration(seconds: 1);
        });
      } else {
        timer.cancel();
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("¡Se acabó el tiempo!", textAlign: TextAlign.center,),
            content: Text("El temporizador ha finalizado", textAlign: TextAlign.center,),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("OK"),
              ),
            ],
          ),
        );
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel(); // Pausa el temporizador
  }

  void _resetTimer(Duration duration) {
    setState(() {
      _remainingTime = duration;
    });
    _timer?.cancel(); // Resetea el temporizador
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        textTheme: TextTheme(
          bodyLarge: TextStyle(fontFamily: fuente, fontSize: 18),
          bodyMedium: TextStyle(fontFamily: fuente, fontSize: 16),
        ),
      ), 
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Tiempo restante:",
          style: TextStyle(
            fontSize: 18, 
            //fontWeight: FontWeight.bold,
            color: Colors.lightGreen, // Color del texto (estilo digital)
            //fontFamily: "Courier",
            ),
        ),
        Text(
          "${_remainingTime.inMinutes}:${(_remainingTime.inSeconds % 60).toString().padLeft(2, '0')}",
          style: TextStyle(fontSize: 36, color: Colors.white),
        ),
      ],
    ));
  }
}
