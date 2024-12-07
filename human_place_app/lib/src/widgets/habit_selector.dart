import 'package:flutter/material.dart';

void showHabitDialog({
  required BuildContext context,
  required Function(String) onHabitSelected,
}) {
  String customHabit = "";
  final List<String> defaultHabits = [
    "Beber agua",
    "Caminar 10,000 pasos",
    "Dormir 8 horas",
    "Meditar 10 minutos",
    "Comer frutas y verduras",
  ];

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text("Selecciona un hábito"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ...defaultHabits.map((habit) => ListTile(
                      title: Text(habit),
                      onTap: () {
                        onHabitSelected(habit);
                        Navigator.of(context).pop();
                      },
                    )),
                Divider(),
                TextField(
                  decoration: InputDecoration(
                    labelText: "Escribe tu propio hábito",
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) {
                    customHabit = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text("Cancelar"),
              ),
              TextButton(
                onPressed: () {
                  if (customHabit.isNotEmpty) {
                    onHabitSelected(customHabit);
                  }
                  Navigator.of(context).pop();
                },
                child: Text("Guardar"),
              ),
            ],
          );
        },
      );
    },
  );
}
