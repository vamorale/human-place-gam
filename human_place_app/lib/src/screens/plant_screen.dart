import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:human_place_app/src/services/firebase_service.dart';
import 'package:human_place_app/src/services/notification_service.dart';

class PlantScreen extends StatelessWidget {
  final String userId;

  PlantScreen({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Estado de la Planta')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userId).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final plant = data['plants'];

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Estado: ${plant['isAlive'] ? "Viva" : "Muerta"}'),
              Text('Días de crecimiento: ${plant['growthDays']}'),
              Text('Protectores: ${plant['protectors']}'),
              ElevatedButton(
                onPressed: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    await FirebaseService.saveNotificationTime(userId, time);
                    await NotificationService.scheduleDailyNotification(time);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Recordatorio configurado a las ${time.format(context)}')),
                    );
                  }
                },
                child: Text('Configurar recordatorio'),
              ),
            ],
          );
        },
      ),
    );
  }
}
