import 'package:flutter/material.dart';

Future<Rect> getWidgetBounds(GlobalKey key) async{
  while (key.currentContext == null) {
    await Future.delayed(const Duration(milliseconds: 10));
  }
  final renderObject = key.currentContext?.findRenderObject();
  
  if (renderObject == null || renderObject is! RenderBox) {
    throw Exception("El widget asociado al GlobalKey no está renderizado o no es un RenderBox.");
  }
  final RenderBox renderBox = key.currentContext?.findRenderObject() as RenderBox;
  final Offset position = renderBox.localToGlobal(Offset.zero);
  return Rect.fromLTWH(position.dx, position.dy, renderBox.size.width, renderBox.size.height);
}
