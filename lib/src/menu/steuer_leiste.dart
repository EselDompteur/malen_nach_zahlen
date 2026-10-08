import 'package:flutter/material.dart';
import '../head/app_state.dart';
import 'datei_button.dart';
import 'werkzeug_regler.dart';
import 'farb_leiste.dart';
import 'poveronoff_regler.dart';

class SteuerLeiste extends StatelessWidget {
  final AppState state;

  const SteuerLeiste({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black26,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          DateiButton(state: state), // Datei-Knopf ganz links
          const SizedBox(width: 8),
          WerkzeugRegler(state: state), // Stift, Eimer, Pipette
          const SizedBox(width: 16),
          Expanded(child: FarbLeiste(state: state)), // Deine 10 Premium-Farben
          const SizedBox(width: 16),
          PoveronoffRegler(state: state), // Genosse Poveronoff ganz rechts
        ],
      ),
    );
  }
}
