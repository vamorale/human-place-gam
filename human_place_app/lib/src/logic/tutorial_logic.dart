import 'package:flutter/material.dart';
import '../models/tutorial_step.dart';
import '../utils/widget_utils.dart';
import '../data/tutorial_steps.dart';
import '../utils/text_highlighter.dart';
//import 'dart:async';

void _showStepsWithNavigation(BuildContext context, List<TutorialStep> steps) {
  int currentStepIndex = 0;

  OverlayEntry? overlayEntry;

  void showCurrentStep() async {
    // Si el overlay ya está mostrado, elimínalo antes de mostrar el siguiente paso
    overlayEntry?.remove();

    final step = steps[currentStepIndex];

    Rect? bounds;
    if (step.highlightWidget && step.targetKey != null) {
      // Obtén las coordenadas solo si se debe destacar el widget
      bounds = await getWidgetBounds(step.targetKey!);
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            if (step.highlightWidget && bounds != null)
              HighlightOverlay(highlightRect: bounds)
            else
              HighlightOverlay(highlightRect: null),
            if (step.highlightWidget && bounds != null)
              Positioned(
                top: bounds.top,
                left: bounds.left,
                child: Container(
                  width: bounds.width,
                  height: bounds.height,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.pinkAccent, width: 3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            // Mostrar contenido del tutorial
            _buildTutorialContent(
              context,
              step,
              currentStepIndex,
              steps.length,
              () {
                if (currentStepIndex < steps.length - 1) {
                  currentStepIndex++; // Avanza al siguiente paso
                  showCurrentStep();
                } else {
                  overlayEntry?.remove(); // Termina el tutorial
                }
              },
              () {
                if (currentStepIndex > 0) {
                  currentStepIndex--; // Retrocede al paso anterior
                  showCurrentStep();
                }
              },
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(overlayEntry!);
  }

  showCurrentStep();
}

/* class HighlightPainter extends CustomPainter {
  final Rect highlightRect;

  HighlightPainter(this.highlightRect);

  @override
  void paint(Canvas canvas, Size size) {
    // Fondo semitransparente
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    // Dibuja el fondo
    canvas.drawRect(Offset.zero & size, paint);

    // Recorta el área destacada
    final clearPaint = Paint()
      ..blendMode = BlendMode.clear;

    canvas.drawRect(highlightRect, clearPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Siempre redibujar en cada cambio
  }
}
 */
/* Future<void> showTutorialOverlay(
    BuildContext context, TutorialStep step) async {
  final overlay = Overlay.of(context);
  final bounds = await getWidgetBounds(step.targetKey);
  final completer = Completer<void>();

  final overlayEntry = OverlayEntry(
      builder: (context) => Stack(children: [
            Positioned(
            top: bounds.top,
            left: bounds.left,
            child: Container(
              width: bounds.width,
              height: bounds.height,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.pinkAccent, width: 3),
                borderRadius: BorderRadius.circular(8),
                color: Colors.pinkAccent.withOpacity(0.2), // Fondo semitransparente
              ),
            ),
          ),
            Positioned(
                      bottom: 50, // Ajusta según tu diseño
                      width: MediaQuery.of(context).size.width, // Centra el personaje
                      child: GestureDetector(
              onTap: () {
                completer.complete(); // Completa la acción cuando el usuario toca la pantalla
              },
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Globo de texto encima del personaje
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Text(
                              step.message,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold, overflow: TextOverflow.clip),
                            ),
                          ),
                          // Imagen del personaje
                          Image.asset(
                            step.imagePath,
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                )],
                ),
  );

  overlay.insert(overlayEntry);

  await completer.future;
  overlayEntry.remove();
}
 */

class HighlightOverlay extends StatelessWidget {
  final Rect? highlightRect;

  HighlightOverlay({required this.highlightRect});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Si no hay highlightRect o es cero, muestra un fondo semitransparente completo
        if (highlightRect == null ||
            highlightRect?.width == 0 ||
            highlightRect?.height == 0)
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.9), // Fondo semitransparente
            ),
          )
        else
          // Si highlightRect tiene valor, aplica el recorte
          Positioned.fill(
            child: ClipPath(
              clipper: HighlightClipper(highlightRect!),
              child: Container(
                color: Colors.black.withOpacity(0.5), // Fondo semitransparente
              ),
            ),
          ),
      ],
    );
  }
}

class HighlightClipper extends CustomClipper<Path> {
  final Rect highlightRect;

  HighlightClipper(this.highlightRect);

  @override
  Path getClip(Size size) {
    // Crea el path que recorta el área del rectángulo destacado
    Path path = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    path.addRect(highlightRect);
    return path..fillType = PathFillType.evenOdd; // Recorta el área destacada
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true; // Siempre redibujar si cambia
  }
}

void checkTutorialForView(BuildContext context, String currentView) {
  final stepsForView =
      tutorialSteps.where((step) => step.targetView == currentView).toList();

  if (stepsForView.isNotEmpty) {
    _showStepsWithNavigation(context, stepsForView);
  }
}

/* Widget _highlightWidget(TutorialStep step) {
  return FutureBuilder<Rect>(
    future: getWidgetBounds(step.targetKey), // Resuelve el Future<Rect>
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        // Mientras se resuelve el Future, puedes mostrar un indicador de carga o un espacio vacío
        return SizedBox.shrink();
      } else if (snapshot.hasError) {
        // Manejo de errores si getWidgetBounds falla
        return SizedBox.shrink();
      } else if (snapshot.hasData) {
        // Cuando el Future se resuelve, usa los datos (Rect)
        final bounds = snapshot.data!;
        return Positioned(
          top: bounds.top,
          left: bounds.left,
          child: Container(
            width: bounds.width,
            height: bounds.height,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.pinkAccent, width: 3),
              borderRadius: BorderRadius.circular(8),
              color: Colors.transparent, // Fondo semitransparente
            ),
          ),
        );
      } else {
        // Caso predeterminado si no hay datos
        return SizedBox.shrink();
      }
    },
  );
}
 */
Widget _buildTutorialContent(
  BuildContext context,
  TutorialStep step,
  int currentStepIndex,
  int totalSteps,
  VoidCallback onNext,
  VoidCallback onPrevious,
) {
  return Stack(children: [
    Positioned(
      //bottom: 50, // Ajusta según diseño
      top: step.position == CharacterPosition.center
          ? MediaQuery.of(context).size.height / 2 - 100 // Centro vertical
          : null, // No especificar si es bottom
      bottom: 120,
      width: MediaQuery.of(context).size.width, // Centra el contenido
      child: Column(
        children: [
          /* if (step.characterName != null) ...[
            Text(
            step.characterName!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: step.nameColor, // Custom color for the character name
            ),
          ),
          const SizedBox(height: 5),
          ], */

          // Globo de texto
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: /* Text(
              step.message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ), */
                Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Nombre del personaje, si está disponible
                if (step.characterName != null)
                  Text(
                    step.characterName!,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: step.nameColor,
                        fontSize: 16,
                        fontFamily: 'sen-regular'),
                    textAlign: TextAlign.center,
                  ),
                if (step.characterName != null) const SizedBox(height: 5),
                // Mensaje del tutorial
                /* Text(
                step.message,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontFamily: 'sen-regular'
                ),
                textAlign: TextAlign.center,
              ), */
                if (step.wordsToHighlight != null)
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: highlightWords(
                        text: step.message,
                        wordsToHighlight: step.wordsToHighlight!,
                      ),
                    ),
                  )
                else
                  Text(
                    step.message,
                    style: const TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontFamily: 'sen-regular'),
                    textAlign: TextAlign.center,
                  )
              ],
            ),
          ),
          // Imagen del personaje
          Image.asset(
            step.imagePath,
            width: 80,
            height: 80,
          ),
        ],
      ),
    ),
    //const SizedBox(height: 10),
    // Botones de navegación
    Positioned(
      bottom: 50,
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (currentStepIndex > 0)
            ElevatedButton(
              onPressed: onPrevious,
              child: const Text("Volver"),
            ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onNext,
            child: Text(
                currentStepIndex < totalSteps - 1 ? "Continuar" : "Finalizar"),
          ),
        ],
      ),
    ),
  ]);
}
