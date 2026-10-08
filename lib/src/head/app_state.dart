import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  // --- Zustand: Allgemeine App-Metadaten ---
  final String appTitel = "Paint by Numbers Prototyp";
  final int buildNummer = 2;

  // --- Zustand: Mal-Optionen und Werkzeuge ---
  Color _aktiveFarbe = Colors.red;
  double _pinselBreite = 5.0;
  bool _auslaufSchutzAktiv = false;

  // Genosse Poveronoffs unbestechlicher Kantenschutz
  bool _kantenschutzAktiv = false;

  // --- Getter: Damit die UI-Kompnenten die Werte nur LESEN duerfen ---
  Color get aktiveFarbe => _aktiveFarbe;
  double get pinselBreite => _pinselBreite;
  bool get auslaufSchutzAktiv => _auslaufSchutzAktiv;
  bool get kantenschutzAktiv => _kantenschutzAktiv;

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
    _kantenschutzAktiv = !_kantenschutzAktiv;
    notifyListeners(); // Zündet das visuelle Umschalten des russischen Schalters!
  }
}
