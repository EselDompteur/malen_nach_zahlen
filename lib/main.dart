import "dart:io";
import "dart:typed_data";
import "dart:ui" as dart_ui;

import "package:flutter/material.dart";
import "package:file_picker/file_picker.dart";
import "package:pdfrx/pdfrx.dart";

// import "package:flutter/gestures.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await pdfrxFlutterInitialize();
  runApp(const MyApp());
}

enum MalModus { stift, eimer }

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Paint",
      theme: ThemeData.dark(),
      home: const PaintCanvas(),
    );
  }
}

class PaintCanvas extends StatefulWidget {
  const PaintCanvas({super.key});
  @override
  State<PaintCanvas> createState() => _PaintCanvasState();
}

class _PaintCanvasState extends State<PaintCanvas> {
  dart_ui.Image? templateImage;
  dart_ui.Image? paintLayer;
  Uint8List? rawPreviewBytes;
  bool isLoading = false;
  MalModus aktuellerModus = MalModus.stift;
  Color activeColor = Colors.blue;
  double brushWidth = 4.0;
  double fillTolerance = 120.0;
  final List<Uint8List> undoHistory = [];
  final TransformationController _zoomController = TransformationController();
  bool isPortraitMode = false;
  final double targetSize = 1000.0;

  Future<void> initPaintLayer(int w, int h) async {
    final rec = dart_ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.drawColor(Colors.transparent, BlendMode.src);
    final img = await rec.endRecording().toImage(w, h);
    setState(() {
      paintLayer = img;
    });
  }

  Future<dart_ui.Image> rotateImage90Degrees(dart_ui.Image src) async {
    final rec = dart_ui.PictureRecorder();
    final canvas = Canvas(rec);
    canvas.translate(src.height.toDouble() / 2, src.width.toDouble() / 2);
    canvas.rotate(1.5708);
    canvas.translate(-src.width.toDouble() / 2, -src.height.toDouble() / 2);
    canvas.drawImage(src, Offset.zero, Paint());
    return await rec.endRecording().toImage(src.height, src.width);
  }

  Future<void> saveToUndoStack() async {
    if (paintLayer == null) return;
    final bd = await paintLayer!.toByteData(
      format: dart_ui.ImageByteFormat.rawRgba,
    );
    if (bd != null) {
      if (undoHistory.length >= 10) {
        undoHistory.removeAt(0);
      }
      undoHistory.add(bd.buffer.asUint8List());
    }
  }

  Future<void> executeUndo() async {
    if (undoHistory.isEmpty || paintLayer == null) return;
    setState(() => isLoading = true);
    final prev = undoHistory.removeLast();
    final desc = await dart_ui.ImmutableBuffer.fromUint8List(prev);
    final imgD = dart_ui.ImageDescriptor.raw(
      desc,
      width: paintLayer!.width,
      height: paintLayer!.height,
      pixelFormat: dart_ui.PixelFormat.rgba8888,
    );
    final frame = await (await imgD.instantiateCodec()).getNextFrame();
    setState(() {
      paintLayer = frame.image;
      isLoading = false;
    });
  }

  Future<void> selectTemplateFile() async {
    setState(() => isLoading = true);
    try {
      FilePickerResult? res = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ["pdf", "png", "jpg", "jpeg"],
      );
      if (res != null && res.files.single.path != null) {
        String path = res.files.single.path!;
        bool isPdf = path.toLowerCase().endsWith(".pdf");
        int totalPages = 1;
        if (isPdf) {
          final doc = await PdfDocument.openFile(path);
          totalPages = doc.pages.length;
          await doc.dispose();
        }
        if (mounted) {
          final dialogResult = await showCombinedImportDialog(
            path,
            isPdf,
            totalPages,
          );
          if (dialogResult != null) {
            dart_ui.Image finalImg = dialogResult["image"];
            int finalRotation = dialogResult["rotation"];

            for (int i = 0; i < finalRotation; i++) {
              finalImg = await rotateImage90Degrees(finalImg);
            }

            setState(() {
              templateImage = finalImg;
              undoHistory.clear();
              _zoomController.value = Matrix4.identity();
            });
            await initPaintLayer(finalImg.width, finalImg.height);
          }
        }
      }
    } catch (e) {
      debugPrint("Error routing file: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> showCombinedImportDialog(
    String path,
    bool isPdf,
    int totalPages,
  ) {
    int rotationSteps = 0;

    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        int currentPage = 1;

        Uint8List? dialogPreviewBytes;
        dart_ui.Image? currentLoadedImage;
        bool isDialogLoading = false;
        final TextEditingController pageController = TextEditingController(
          text: "1",
        );
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> loadPreview() async {
              setDialogState(() => isDialogLoading = true);
              if (isPdf) {
                final doc = await PdfDocument.openFile(path);
                final page = doc.pages[currentPage - 1];
                final pdfImg = await page.render(
                  fullWidth: page.width * 3,
                  fullHeight: page.height * 3,
                );
                if (pdfImg != null) {
                  final uiImg = await pdfImg.createImage();
                  final bData = await uiImg.toByteData(
                    format: dart_ui.ImageByteFormat.png,
                  );
                  if (bData != null) {
                    setDialogState(() {
                      dialogPreviewBytes = bData.buffer.asUint8List();
                      currentLoadedImage = uiImg;
                    });
                  }
                  pdfImg.dispose();
                }
                await doc.dispose();
              } else {
                final bytes = await File(path).readAsBytes();
                final codec = await dart_ui.instantiateImageCodec(bytes);
                final frame = await codec.getNextFrame();
                setDialogState(() {
                  dialogPreviewBytes = bytes;
                  currentLoadedImage = frame.image;
                });
              }
              setDialogState(() => isDialogLoading = false);
            }

            if (dialogPreviewBytes == null && !isDialogLoading) {
              loadPreview();
            }
            return AlertDialog(
              title: const Center(
                child: Text("Vorlage importieren"),
              ), // Zentriert
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedRotation(
                      turns: rotationSteps * 0.25,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                        ),
                        child: isDialogLoading
                            ? const Center(child: CircularProgressIndicator())
                            : (dialogPreviewBytes != null
                                  ? Image.memory(
                                      dialogPreviewBytes!,
                                      fit: BoxFit.contain,
                                    )
                                  : Container()),
                      ),
                    ),
                    const SizedBox(height: 15),
                    if (isPdf && totalPages > 1) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () {
                              setDialogState(() {
                                currentPage = currentPage > 1
                                    ? currentPage - 1
                                    : totalPages;
                                pageController.text = currentPage.toString();
                                dialogPreviewBytes = null;
                              });
                            },
                          ),
                          SizedBox(
                            width: 50,
                            child: TextField(
                              controller: pageController,
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                              onSubmitted: (val) {
                                int? p = int.tryParse(val);
                                if (p != null && p >= 1 && p <= totalPages) {
                                  setDialogState(() {
                                    currentPage = p;
                                    dialogPreviewBytes = null;
                                  });
                                } else {
                                  pageController.text = currentPage.toString();
                                }
                              },
                            ),
                          ),
                          Text(
                            " von $totalPages",
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward),
                            onPressed: () {
                              setDialogState(() {
                                currentPage = currentPage < totalPages
                                    ? currentPage + 1
                                    : 1;
                                pageController.text = currentPage.toString();
                                dialogPreviewBytes = null;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                    ],
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.rotate_left),
                          label: const Text("Gegen den Uhrzeigersinn"),
                          onPressed: () => setDialogState(() {
                            rotationSteps--;
                          }),
                        ),
                        const SizedBox(width: 15),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.rotate_right),
                          label: const Text("Mit dem Uhrzeigersinn"),
                          onPressed: () => setDialogState(() {
                            rotationSteps++;
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  child: const Text("Abbrechen"),
                  onPressed: () => Navigator.of(ctx).pop(null),
                ),
                ElevatedButton(
                  onPressed: (isDialogLoading || currentLoadedImage == null)
                      ? null
                      : () {
                          int finalCleanRotation = (rotationSteps % 4 + 4) % 4;
                          Navigator.of(ctx).pop({
                            "image": currentLoadedImage,
                            "rotation": finalCleanRotation,
                          });
                        },
                  child: const Text("Vorlage laden"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> executeFloodFill(Offset pos) async {
    if (templateImage == null || paintLayer == null) return;
    int tx = pos.dx.toInt();
    int ty = pos.dy.toInt();
    int w = templateImage!.width;
    int h = templateImage!.height;
    if (tx < 0 || tx >= w || ty < 0 || ty >= h) return;
    await saveToUndoStack();
    setState(() => isLoading = true);
    final bgD = await templateImage!.toByteData(
      format: dart_ui.ImageByteFormat.rawRgba,
    );
    final ptD = await paintLayer!.toByteData(
      format: dart_ui.ImageByteFormat.rawRgba,
    );
    if (bgD == null || ptD == null) {
      setState(() => isLoading = false);
      return;
    }
    final bgP = bgD.buffer.asUint32List();
    final ptP = ptD.buffer.asUint32List();
    int idx = ty * w + tx;
    int tColor = bgP[idx];
    int fColor =
        (activeColor.a * 255).toInt() << 24 |
        (activeColor.b * 255).toInt() << 16 |
        (activeColor.g * 255).toInt() << 8 |
        (activeColor.r * 255).toInt();
    bool isDark(int v) {
      return (0.299 * (v & 0xFF) +
              0.587 * ((v >> 8) & 0xFF) +
              0.114 * ((v >> 16) & 0xFF)) <
          fillTolerance;
    }

    if (isDark(tColor)) {
      setState(() => isLoading = false);
      return;
    }
    List<int> q = [idx];
    Set<int> vis = {idx};
    while (q.isNotEmpty) {
      int c = q.removeLast();
      ptP[c] = fColor;
      int cx = c % w;
      int cy = c ~/ w;
      List<int> n = [];
      if (cx > 0) n.add(c - 1);
      if (cx < w - 1) n.add(c + 1);
      if (cy > 0) n.add(c - w);
      if (cy < h - 1) n.add(c + w);
      for (int nIdx in n) {
        if (!vis.contains(nIdx)) {
          vis.add(nIdx);
          if (!isDark(bgP[nIdx])) q.add(nIdx);
        }
      }
    }
    final desc = await dart_ui.ImmutableBuffer.fromUint8List(
      Uint8List.view(ptD.buffer),
    );
    final imgD = dart_ui.ImageDescriptor.raw(
      desc,
      width: w,
      height: h,
      pixelFormat: dart_ui.PixelFormat.rgba8888,
    );
    final frame = await (await imgD.instantiateCodec()).getNextFrame();
    setState(() {
      paintLayer = frame.image;
      isLoading = false;
    });
  }

  void drawStroke(Offset f, Offset t) async {
    if (paintLayer == null) return;
    final rec = dart_ui.PictureRecorder();
    final canvas = Canvas(rec)..drawImage(paintLayer!, Offset.zero, Paint());
    canvas.drawLine(
      f,
      t,
      Paint()
        ..color = activeColor
        ..strokeCap = StrokeCap.round
        ..strokeWidth = brushWidth
        ..style = PaintingStyle.stroke,
    );
    final img = await rec.endRecording().toImage(
      paintLayer!.width,
      paintLayer!.height,
    );
    setState(() {
      paintLayer = img;
    });
  }

  Offset? lastPos;

    Future<void> exportToPng() async {
    if (paintLayer == null) return;
    setState(() => isLoading = true);
    try {
      final home = Platform.environment["HOME"];
      if (home == null) return;
      final dirPath = "$home/Bilder/Enkel_Kunst";
      final dir = Directory(dirPath);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }
      final ts = DateTime.now().toString().replaceAll(RegExp(r"[:.- ]"), "_");
      final filePath = "$dirPath/kunstwerk_$ts.png";
      final bd = await paintLayer!.toByteData(format: dart_ui.ImageByteFormat.png);
      if (bd != null) {
        final bytes = bd.buffer.asUint8List();
        await File(filePath).writeAsBytes(bytes);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Bild erfolgreich gespeichert unter: $filePath")),
          );
        }
      }
    } catch (e) {
      debugPrint("Fehler beim Speichern: $e");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Paint by Numbers Prototyp"),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            tooltip: "Rueckgaengig",
            onPressed: undoHistory.isNotEmpty ? executeUndo : null,
          ),
          const SizedBox(width: 10),
          ToggleButtons(
            isSelected: [
              aktuellerModus == MalModus.stift,
              aktuellerModus == MalModus.eimer,
            ],
            onPressed: (i) => setState(
              () => aktuellerModus = i == 0 ? MalModus.stift : MalModus.eimer,
            ),
            children: const [Icon(Icons.edit), Icon(Icons.format_color_fill)],
          ),
          const SizedBox(width: 20),
          ElevatedButton(
            onPressed: selectTemplateFile,
            child: const Text("Vorlage laden"),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              if (paintLayer != null) {
                await initPaintLayer(paintLayer!.width, paintLayer!.height);
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.blueGrey.shade800,
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...[
                  Colors.blue,
                  Colors.red,
                  Colors.green,
                  Colors.yellow,
                  Colors.black,
                ].map(
                  (color) => GestureDetector(
                    onTap: () => setState(() => activeColor = color),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8.0),
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: activeColor == color
                              ? Colors.white
                              : Colors.black38,
                          width: 3,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 30),
                const Icon(Icons.security, size: 20, color: Colors.white70),
                const Text(" Auslauf-Schutz: ", style: TextStyle(fontSize: 12)),
                Slider(
                  value: fillTolerance,
                  min: 50.0,
                  max: 200.0,
                  divisions: 15,
                  label: fillTolerance.toInt().toString(),
                  onChanged: aktuellerModus == MalModus.eimer
                      ? (newValue) {
                          setState(() {
                            fillTolerance = newValue;
                          });
                        }
                      : null,
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator()
                  : Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade700,
                          width: 2,
                        ),
                      ),
                      child: InteractiveViewer(
                        transformationController: _zoomController,
                        maxScale: 6.0,
                        minScale: 1.0,
                        child: templateImage == null
                            ? const SizedBox(
                                width: 600,
                                height: 600,
                                child: Center(
                                  child: Text(
                                    "Bitte laden Sie oben eine Vorlage",
                                  ),
                                ),
                              )
                            : Listener(
                                onPointerDown: (ev) {
                                  if (ev.buttons == 2) lastPos = null;
                                },
                                child: GestureDetector(
                                  onTapDown: (d) {
                                    if (aktuellerModus == MalModus.eimer) {
                                      executeFloodFill(d.localPosition);
                                    }
                                  },
                                  onPanStart: (d) async {
                                    if (aktuellerModus == MalModus.stift) {
                                      await saveToUndoStack();
                                      lastPos = d.localPosition;
                                    }
                                  },
                                  onPanUpdate: (d) {
                                    if (aktuellerModus == MalModus.stift &&
                                        lastPos != null) {
                                      drawStroke(lastPos!, d.localPosition);
                                      lastPos = d.localPosition;
                                    }
                                  },
                                  onPanEnd: (_) => lastPos = null,
                                  child: CustomPaint(
                                    size: Size(
                                      templateImage!.width.toDouble(),
                                      templateImage!.height.toDouble(),
                                    ),
                                    painter: CombinedLayerPainter(
                                      template: templateImage!,
                                      paintImage: paintLayer!,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class CombinedLayerPainter extends CustomPainter {
  final dart_ui.Image template;
  final dart_ui.Image paintImage;
  CombinedLayerPainter({required this.template, required this.paintImage});
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawImage(template, Offset.zero, Paint());
    canvas.drawImage(paintImage, Offset.zero, Paint());
  }

  @override
  bool shouldRepaint(covariant CombinedLayerPainter old) => true;
}
