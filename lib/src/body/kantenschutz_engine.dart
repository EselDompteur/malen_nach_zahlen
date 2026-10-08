import 'dart:ui' as dart_ui;
import 'package:flutter/material.dart';

class KantenschutzEngine {
  /// Untersucht das Vorlagen-Bild und frisst bei einem Klick auf eine schwarze Linie
  /// maximal 15 zusammenhaengende schwarze Pixel in der aktiven Farbe auf.
  static void fuehreLinienFresserAus({
    required int startX,
    required int startY,
    required dart_ui.Image templateImage,
    required Color activeColor,
    required List<int> imgData, // Das 32-Bit Pixel-Array deiner Vorlage
    required VoidCallback onUpdate, // UI-Notification-Schnittstelle
  }) {
    final int width = templateImage.width;
    final int height = templateImage.height;

    List<List<int>> queue = [[startX, startY]];
    Set<String> besucht = {"$startX,$startY"};
    int gefressenePixel = 0;

    // Die Malfarbe in das unbestechliche 32-Bit format (AARRGGBB) konvertieren
    final int neueFarbe32 = (0xFF << 24) | (activeColor.red << 16) | (activeColor.green << 8) | activeColor.blue;

    while (queue.isNotEmpty && gefressenePixel < 15) {
      var punkt = queue.removeAt(0);
      int curX = punkt[0];
      int curY = punkt[1];

      int idx = curY * width + curX;
      if (idx < 0 || idx >= imgData.length) continue;

      // Schwarzes Pixel unzerstoerbar mit der neuen Farbe ueberschreiben
      imgData[idx] = neueFarbe32;
      gefressenePixel++;

      // Die 4-Wege-Nachbarschaft (Oben, Unten, Links, Rechts) checken
      List<List<int>> nachbarn = [
        [curX, curY - 1],
        [curX, curY + 1],
        [curX - 1, curY],
        [curX + 1, curY]
      ];

      for (var n in nachbarn) {
        int nx = n[0];
        int ny = n[1];
        String key = "$nx,$ny";

        if (nx >= 0 && nx < width && ny >= 0 && ny < height && !besucht.contains(key)) {
          besucht.add(key);
          int nIdx = ny * width + nx;
          int nColor = imgData[nIdx];

          // Farbkomponenten extrahieren fuer den exakten Schwarz-Check
          int r = (nColor >> 16) & 0xFF;
          int g = (nColor >> 8) & 0xFF;
          int b = nColor & 0xFF;

          // Wenn der Nachbarpixel ebenfalls eine dunkle Konturlinie ist, weiterfressen
          if (r < 60 && g < 60 && b < 60) {
            queue.add([nx, ny]);
          }
        }
      }
    }

    // Die Callback-Schnittstelle zuendet das sofortige Neuzeichnen des Widgets
    onUpdate();
  }
}
