import 'package:flutter/material.dart';
import '../head/app_state.dart';

class FarbLeiste extends StatelessWidget {
  final AppState state;

  final List<Color> malFarben = const [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.cyan,
    Colors.lime,
  ];

  const FarbLeiste({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final Color aktuelleFarbe = state.aktiveFarbe;

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: malFarben.length,
        itemBuilder: (context, index) {
          final Color farbe = malFarben[index];
          final bool istAusgewaehlt = farbe == aktuelleFarbe;

          return GestureDetector(
            onTap: () => state.wechsleFarbe(farbe),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: farbe,
                shape: BoxShape.circle,
                border: Border.all(
                  color: istAusgewaehlt ? Colors.white : Colors.black26,
                  width: istAusgewaehlt ? 3.0 : 1.0,
                ),
                boxShadow: istAusgewaehlt ? const [
                  BoxShadow(color: Colors.black38, blurRadius: 4, offset: Offset(0, 2))
                ] : null,
              ),
            ),
          );
        },
      ),
    );
  }
}
