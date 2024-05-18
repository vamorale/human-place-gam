import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:human_place_app/src/notifiers/app.dart';
import 'package:human_place_app/src/routes.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class MyApp extends StatelessWidget {
  final BehaviorSubject<RemoteMessage> eventBus;

  MyApp({required this.eventBus});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppNotifier(this.eventBus)),
      ],
      child: MaterialApp(
        title: 'Human Place',
        routes: routes, //rutas entregadas para generar un navegador
        builder: EasyLoading.init(),
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          fontFamily: 'POPPINS',
          primarySwatch: Colors.blue,
          bottomSheetTheme: BottomSheetThemeData(
            backgroundColor: Colors.black.withOpacity(0),
          ),
        ),
      ),
    );
  }
}
