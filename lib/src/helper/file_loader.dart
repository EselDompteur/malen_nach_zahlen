import 'package:file_picker/file_picker.dart';

class FileLoader {
  /// Startet den modernisierten FilePicker 13 auf CachyOS/Android.
  /// Liefert den nackten Pfad der Vorlage als String zurueck oder null bei Abbruch.
  static Future<String?> waehleVorlageDatei() async {
    var res = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    // Genau so, wie du es seziert hast: res ist die Liste, wir nutzen .first!
    if (res != null && res.isNotEmpty) {
      return res.first.path;
    }

    return null;
  }
}
