import 'package:flutter/material.dart';

enum MalModus { stift, eimer, pipette }

class AppState extends ChangeNotifier {
  // --- Zustand: Allgemeine App-Metadaten ---
  final String appTitel = "Paint by Numbers Prototyp";
  final int buildNummer = 2;

  // --- Zustand: Mal-Optionen und Werkzeuge ---
  Color _aktiveFarbe = Colors.red;
  double _pinselBreite = 5.0;
  bool _auslaufSchutzAktiv = false;
  bool _kantenSchutzAktiv = false;

  // Das aktive Werkzeug im Hangar (Standard: Fülleimer)
  MalModus _aktuellerModus = MalModus.eimer;

  // --- Getter: Damit die UI-Kompnenten die Werte nur LESEN duerfen ---
  Color get aktiveFarbe => _aktiveFarbe;
  double get pinselBreite => _pinselBreite;
  bool get auslaufSchutzAktiv => _auslaufSchutzAktiv;
  bool get kantenSchutzAktiv => _kantenSchutzAktiv;
  MalModus get aktuellerModus => _aktuellerModus;

  // --- Setter: Saubere Methoden, um die Werte kontrolliert zu VERAENDERN ---
  void wechsleFarbe(Color neueFarbe) {
    _aktiveFarbe = neueFarbe;
    notifyListeners(); // Benachrichtigt das Menu und den Body blitzschnell!
  }

  void setPinselBreite(double neueBreite) {
    _pinselBreite = neueBreite;
    notifyListeners();
  }

  void toogleAuslaufSchutz() {
    _auslaufSchutzAktiv = !_auslaufSchutzAktiv;
    notifyListeners();
  }

  void toggleKantenschutz() {
    _kantenSchutzAktiv = !_kantenSchutzAktiv;
    notifyListeners(); // Zündet das visuelle Umschalten des russischen Schalters!
  }

  void setMalModus(MalModus neuerModus) {
    _aktuellerModus = neuerModus;
    notifyListeners(); // Zuendet das visuelle Umschalten in der Toolbar!
  }
}
