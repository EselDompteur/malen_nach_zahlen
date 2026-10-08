import "src/menu/steuer_leiste.dart";
import "package:flutter/material.dart";
import "src/head/app_state.dart";
import "src/menu/poveronoff_regler.dart";
import "src/menu/farb_leiste.dart";
import "src/body/mal_feld.dart";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Malen nach Zahlen Prototyp",
      theme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.blue,
      ),
      home: const MalenNachZahlenInterface(),
    );
  }
}



class MalenNachZahlenInterface extends StatefulWidget {
  const MalenNachZahlenInterface({super.key});

  @override
  State<MalenNachZahlenInterface> createState() => _MalenNachZahlenInterfaceState();
}

class _MalenNachZahlenInterfaceState extends State<MalenNachZahlenInterface> {
  late final AppState _appState;
  final TransformationController _zoomController = TransformationController();

  @override
  void initState() {
    super.initState();
    _appState = AppState();
    _appState.addListener(_updateUI);
  }

  @override
  void dispose() {
    _appState.removeListener(_updateUI);
    _zoomController.dispose();
    super.dispose();
  }

  void _updateUI() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${_appState.appTitel} - Build ${_appState.buildNummer}"),
        backgroundColor: Colors.black38,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. Das komplett gekapselte Menu-Modul includieren!
          SteuerLeiste(state: _appState),
          const Divider(height: 1, color: Colors.white10),
          // 2. Das Malfeld bekommt unmissverstaendlich den gesamten restlichen Platz
          Expanded(
            child: MalFeld(
              state: _appState,
              zoomController: _zoomController,
            ),
          ),
        ],
      ),
    );
  }
}