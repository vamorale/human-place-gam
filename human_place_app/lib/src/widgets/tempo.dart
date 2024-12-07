import 'dart:async';
import 'package:flutter/material.dart';

class TimerDialog extends StatefulWidget {
  final Function(int) onTimerComplete; // Callback cuando el temporizador termina

  const TimerDialog({Key? key, required this.onTimerComplete}) : super(key: key);

  @override
  _TimerDialogState createState() => _TimerDialogState();
}

class _TimerDialogState extends State<TimerDialog> {
  Duration _selectedDuration = Duration(minutes: 1);
  Timer? _timer;
  int _remainingTime = 0;
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text = _selectedDuration.inMinutes.toString();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _remainingTime = _selectedDuration.inSeconds;
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() {
          _remainingTime--;
        });
      } else {
        timer.cancel();
        widget.onTimerComplete(_remainingTime); // Llama al callback
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Time's up!"),
            content: Text("The timer has completed."),
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

  void _showTimerConfigDialog() {
    showDialog(
      context: context,
      builder: (context) {
        Duration tempDuration = _selectedDuration;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Configure Timer"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Enter duration (minutes):"),
                  TextField(
                    controller: _textController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Minutes (1 to 60)",
                    ),
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
                    label: "${tempDuration.inMinutes} minutes",
                    value: tempDuration.inMinutes.toDouble(),
                    onChanged: (value) {
                      setState(() {
                        tempDuration = Duration(minutes: value.toInt());
                        _textController.text = value.toInt().toString();
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text("Cancel"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(tempDuration);
                  },
                  child: Text("Start Timer"),
                ),
              ],
            );
          },
        );
      },
    ).then((selectedDuration) {
      if (selectedDuration != null && selectedDuration is Duration) {
        setState(() {
          _selectedDuration = selectedDuration;
        });
        _startTimer();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Remaining Time: ${(_remainingTime / 60).floor()} minutes ${_remainingTime % 60} seconds",
          style: TextStyle(fontSize: 20),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: _showTimerConfigDialog,
          child: Text("Configure Timer"),
        ),
      ],
    );
  }
}
