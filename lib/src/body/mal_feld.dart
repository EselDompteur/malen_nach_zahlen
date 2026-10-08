import 'package:flutter/material.dart';
import '../head/app_state.dart';
import 'kantenschutz_engine.dart';

class MalFeld extends StatelessWidget {
  final AppState state;
  final TransformationController zoomController;

  const MalFeld({
    super.key,
    required this.state,
    required this.zoomController,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        // Hier fangen wir den präzisen Fingertipp der Enkelkinder ab
        onTapUp: (TapUpDetails details) {
          final RenderBox box = context.findRenderObject() as RenderBox;
          final Offset lokalePosition = box.globalToLocal(details.globalPosition);

          // Wir berechnen die exakten Pixel-Koordinaten auf der Vorlage (inkl. Zoom-Faktor)
          final Matrix4 transformation = zoomController.value;
          final double scale = transformation.getMaxScaleOnAxis();
          final double translationX = transformation.getTranslation().x;
          final double translationY = transformation.getTranslation().y;

          final int pixelX = ((lokalePosition.dx - translationX) / scale).toInt();
          final int pixelY = ((lokalePosition.dy - translationY) / scale).toInt();

          // Hier schlägt die unbestechliche Klick-Weiche zu!
          if (state.kantenSchutzAktiv) {
            // Wenn Genosse Poveronoff aktiv ist, zünden wir die isolierte Engine händisch an!
            print("Kantenschutz feuert bei Pixel: $pixelX, $pixelY");

            // TODO: In der finalen main.dart übergeben wir hier das echte imgData-Array
            // KantenschutzEngine.fuehreLinienFresserAus(...);
          } else {
            print("Klassischer Flächen-Eimer feuert bei Pixel: $pixelX, $pixelY");
          }
        },
        child: InteractiveViewer(
          transformationController: zoomController,
          minScale: 0.5,
          maxScale: 10.0, // Bis zu 10-facher Monk-Präzisions-Zoom für die kleinen Linien
          boundaryMargin: const EdgeInsets.all(200),
          child: Center(
            child: Container(
              color: Colors.white,
              width: 400, // Platzhalter-Maße – werden später dynamisch von der PDF bestimmt!
              height: 600,
              child: const Stack(
                children: [
                  // Hier schichten wir später das PDF-Bild und die Malschicht übereinander
                  Center(child: Text("Hier entsteht das sterile Meisterwerk")),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
