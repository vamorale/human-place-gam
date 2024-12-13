import 'package:flutter/material.dart';
//import 'package:diacritic/diacritic.dart';

/// Genera una lista de [TextSpan] para destacar palabras específicas en un texto.
///
/// - [text]: El texto completo.
/// - [wordsToHighlight]: Lista de palabras a destacar.
/// - [normalStyle]: Estilo del texto normal.
/// - [highlightStyle]: Estilo del texto destacado.
/// 
String cleanWord(String word) {
  return word.replaceAll(RegExp(r'[^\w\s]'), ''); // Elimina puntuaciones
}
List<TextSpan> highlightWords({
  required String text,
  required List<String> wordsToHighlight,
  TextStyle normalStyle = const TextStyle(color: Colors.black, fontSize: 16, fontFamily: 'sen-regular'),
  TextStyle highlightStyle = const TextStyle(color: Colors.purpleAccent, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'sen-regular'),
}) {
  final List<TextSpan> spans = [];
  final textParts = text.split(RegExp(r'\s+'));

  for (final part in textParts) {
    final cleanedPart = cleanWord(part.toLowerCase());
    final isHighlighted = wordsToHighlight
        .map((word) => cleanWord(word.toLowerCase()))
        .contains(cleanedPart);;

    

    spans.add(
      TextSpan(
        text: "$part ", // Agrega un espacio después de cada palabra
        style: isHighlighted ? highlightStyle : normalStyle,
      ),
    );
  }

  return spans;
}
