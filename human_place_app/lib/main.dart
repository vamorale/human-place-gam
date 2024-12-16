import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:human_place_app/src/app.dart';
import 'package:human_place_app/src/utils/notification_helper.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:human_place_app/src/providers/user_notifier.dart';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

void main() async {
  // Inicializacion con la base de datos

  WidgetsFlutterBinding.ensureInitialized();
  NotificationHelper.init();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  BehaviorSubject<RemoteMessage> _eventBus = BehaviorSubject<RemoteMessage>();

  EasyLoading.instance
    ..toastPosition = EasyLoadingToastPosition.bottom
    ..maskType = EasyLoadingMaskType.custom
    ..maskColor = Colors.black.withOpacity(0.4);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserNotifier()),
      ],
      child: MyApp(eventBus: _eventBus),
    ),
  );
}
