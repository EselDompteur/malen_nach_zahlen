import 'package:flutter/material.dart';
import '../head/app_state.dart';

class WerkzeugRegler extends StatelessWidget {
  final AppState state;

  const WerkzeugRegler({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Da wir im AppState spaeter einen MalModus deklarieren koennen,
    // nutzen wir hier vorerst eine saubere, temporäre String-Erkennung
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.edit),
          tooltip: "Stift",
          onPressed: () => print("Stift ausgewaehlt"),
        ),
        IconButton(
          icon: const Icon(Icons.format_color_fill),
          tooltip: "Fuelleimer",
          onPressed: () => print("Fuelleimer ausgewaehlt"),
        ),
        IconButton(
          icon: const Icon(Icons.colorize),
          tooltip: "Pipette",
          onPressed: () => print("Pipette ausgewaehlt"),
        ),
      ],
    );
  }
}
