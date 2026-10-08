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
    // Wir nutzen Theme-Zuweisungen, damit die Icons auf dem hellen Silber dunkel und sichtbar sind!
    return Theme(
      data: ThemeData(
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      child: Container(
        height: 65, // Ein Hauch mehr Atempause fuer die Finger
        color: const Color(0xFFD5D8DC), // Pures, edles Foederations-Silbergrau!
        padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        child: Row(
          children: [
            DateiButton(state: state),
            const SizedBox(width: 4),

            // Flexibel anstelle von fester Breite! Schiebt sich bei Bedarf unfallfrei zusammen!
            Expanded(
              child: FarbLeiste(state: state),
            ),
            const SizedBox(width: 8),

            WerkzeugRegler(state: state),
            const SizedBox(width: 8),

            PoveronoffRegler(state: state),
          ],
        ),
      ),
    );
  }
}
