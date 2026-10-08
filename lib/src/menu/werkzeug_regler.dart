import 'package:flutter/material.dart';
import '../head/app_state.dart';

class WerkzeugRegler extends StatelessWidget {
  final AppState state;

  const WerkzeugRegler({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final MalModus modus = state.aktuellerModus;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // 1. Der Stift-Button
        IconButton(
          icon: Icon(
            Icons.edit,
            color: modus == MalModus.stift ? Colors.blue : Colors.black54,
          ),
          tooltip: "Stift",
          onPressed: () => state.setMalModus(MalModus.stift),
        ),

        // 2. Der Fülleimer-Button
        IconButton(
          icon: Icon(
            Icons.format_color_fill,
            color: modus == MalModus.eimer ? Colors.blue : Colors.black54,
          ),
          tooltip: "Fuelleimer",
          onPressed: () => state.setMalModus(MalModus.eimer),
        ),

        // 3. Die Pipette
        IconButton(
          icon: Icon(
            Icons.colorize,
            color: modus == MalModus.pipette ? Colors.blue : Colors.black54,
          ),
          tooltip: "Pipette",
          onPressed: () => state.setMalModus(MalModus.pipette),
        ),
      ],
    );
  }
}
