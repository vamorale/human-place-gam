import 'package:url_launcher/url_launcher.dart';

Future<void> openTimerApp() async {
  try {
    final Uri timerIntentUri = Uri.parse(
        "intent:#Intent;action=android.intent.action.MAIN;category=android.intent.category.APP_TIMER;end");

    if (await canLaunchUrl(timerIntentUri)) {
      await launchUrl(
        timerIntentUri,
        mode: LaunchMode.externalApplication,
      );
    } else {
      print("No se pudo abrir la app de temporizador.");
    }
  } catch (e) {
    print("Error al intentar abrir el temporizador: $e");
  }
}