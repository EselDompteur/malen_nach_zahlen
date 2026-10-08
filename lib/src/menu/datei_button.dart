import 'package:flutter/material.dart';
import '../head/app_state.dart';
import '../helper/file_loader.dart';

class DateiButton extends StatelessWidget {
  final AppState state;

  const DateiButton({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.file_open, color: Colors.blue),
      tooltip: "Vorlage laden",
      onPressed: () async {
        print("Starte FilePicker 13...");
        final String? pfad = await FileLoader.waehleVorlageDatei();
        if (pfad != null) {
          print("Vorlage erfolgreich geladen: $pfad");
          // Hier triggern wir spaeter das Rendersystem im Body!
        }
      },
    );
  }
}
