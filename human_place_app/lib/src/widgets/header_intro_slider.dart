import 'dart:math';
import 'package:flutter/material.dart';

class HeaderIntroSlider extends StatefulWidget {
  final String header;

  const HeaderIntroSlider({Key? key, required this.header}) : super(key: key);
  @override
  _HeaderIntroSliderState createState() => _HeaderIntroSliderState();
}

class _HeaderIntroSliderState extends State<HeaderIntroSlider> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              width: double.infinity,
              child: ClipRRect(
                child:
                    Image(fit: BoxFit.cover, image: AssetImage(widget.header)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CurvedBottomClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // extraje la altura aproximada de la pieza curvada
    // Se debe cambiar si se obtiene la altura exacta
    final roundingHeight = size.height * 3 / 5;

    // esta es la parte superior del camino, un rectangulo sin curvatura
    final filledRectangle =
        Rect.fromLTRB(0, 0, size.width, size.height - roundingHeight);

    // este es el rectangulo que se utilizara para dibujar el arco
    // el arco es dibujado desde el centro del rectangulo, su altura debe ser el doble de "roundingHeight"
    // hice que salga 5 unidades fuera de pantalla a la izquierda y derecha, para que la curva tenga inclinacion
    final roundingRectangle = Rect.fromLTRB(
        -5, size.height - roundingHeight * 2, size.width + 5, size.height);

    final path = Path();
    path.addRect(filledRectangle);

    // como se menciona anteriormente; el arco se dibuja desde el centro de "roundingRectangle"
    // el 2do y 3er argumento son angulos desde el centro hasta el inicio y final del arco
    // el 4to argumento se entrega como "true" para mover el camino al centro del rectangulo,
    // de esta forma no lo tenemos que mover manualmente
    path.arcTo(roundingRectangle, pi, -pi, true);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    // Se retorna "true" por simpleza, no es parte de la pregunta, por favor lea la documentacion si quiere indagar en ello
    // basicamente significa que si se superpone se sobrescribira cualquier cambio
    return true;
  }
}
