import 'package:flutter/material.dart';
import '../head/app_state.dart';

class PoveronoffRegler extends StatelessWidget {
  final AppState state;

  const PoveronoffRegler({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    // Der Schalter lauscht direkt auf den Zustand aus dem Head-Modul
    final bool aktiv = state.kantenSchutzAktiv;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            aktiv ? Icons.gpp_good : Icons.gpp_bad,
            color: aktiv ? Colors.green : Colors.red,
          ),
          tooltip: "Kantenschutz (Poveronoff)",
          // Wenn das Enkelkind klickt, zuenden wir die Methode im AppState!
          onPressed: () => state.toggleKantenschutz(),
        ),
        Text(
          aktiv ? " Poveronoff ON" : " Poveronoff OFF",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: aktiv ? Colors.green : Colors.red,
          ),
        ),
      ],
    );
  }
}
