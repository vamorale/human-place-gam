import 'package:flutter/material.dart';

class CharacterScreen extends StatelessWidget {
  final String imagePath;
  final String text;
  final VoidCallback onActionCompleted;
  final String? rewardImagePath;
  final String? nameCharacter;

  const CharacterScreen({
    Key? key,
    required this.imagePath,
    required this.text,
    required this.onActionCompleted,
    this.rewardImagePath,
    this.nameCharacter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      //backgroundColor: Colors.deepPurple[900],
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.blueAccent,
            Colors.deepPurpleAccent,
          ],
        ),
      ),
          ),
      SafeArea(
        child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(imagePath, height: 180),
              if (nameCharacter!=null) ...{
                SizedBox(height: 20),
                Text(
                  nameCharacter!,
                  textAlign: TextAlign.center,
                  
                  style: TextStyle(fontSize: 20, color: Colors.yellow, fontFamily: 'sen-regular',fontWeight: FontWeight.bold),
                ),
              },
              SizedBox(height: 20),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, color: Colors.white, fontFamily: 'sen-regular'),
              ),
              SizedBox(height: 15),

              // Imagen del premio (si se proporciona)
              if (rewardImagePath != null)
                Column(
                  children: [
                    SizedBox(height: 20),
                    Image.asset(rewardImagePath!, height: 50,),
                    SizedBox(height: 10),
                    Text(
                      '¡Este es tu premio!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.white, fontFamily: 'sen-regular'),
                    ),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: onActionCompleted,
                child: Text('Continuar'),
              ),
            ],
          ),
        ),

        /* child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, width: 150, height: 150), // Imagen del personaje
            const SizedBox(height: 20),
            Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white, // Texto en blanco
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: onActionCompleted,
              child: const Text('Continuar'),
            ),
          ],
        ),
       */),
    )]));
  }
}
