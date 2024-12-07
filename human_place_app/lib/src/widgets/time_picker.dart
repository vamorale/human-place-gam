import 'package:flutter/material.dart';

class TimePickerAlertDialog extends StatefulWidget {
  final Function(TimeOfDay) onTimeSelected;

  const TimePickerAlertDialog({Key? key, required this.onTimeSelected})
      : super(key: key);

  @override
  _TimePickerAlertDialogState createState() => _TimePickerAlertDialogState();
}

class _TimePickerAlertDialogState extends State<TimePickerAlertDialog> {
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _showTimePickerDialog(BuildContext context) async {
    final TimeOfDay? pickedTime = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        TimeOfDay tempTime = _selectedTime;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Selecciona la hora de riego",
              textAlign: TextAlign.center,),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Hora seleccionada: ${tempTime.format(context)}",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 10,),
                  ElevatedButton(
                    onPressed: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: tempTime,
                      );
                      if (picked != null) {
                        setState(() {
                          tempTime = picked;
                        });
                      }
                    },
                    child: Text("Seleccionar hora"),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(null);
                  },
                  child: Text("Cancelar"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(tempTime);
                  },
                  child: Text("OK"),
                ),
              ],
            );
          },
        );
      },
    );

    if (pickedTime != null) {
      setState(() {
        _selectedTime = pickedTime;
      });
      widget.onTimeSelected(_selectedTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () => _showTimePickerDialog(context),
      child: Text("Escoger horario", style: TextStyle(fontFamily: 'sen-regular'),),
    );
  }
}