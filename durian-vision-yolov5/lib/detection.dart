// detection_page.dart

import 'package:durian/details_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vision/flutter_vision.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'data.dart';

class DetectionPage extends StatefulWidget {
  const DetectionPage({super.key});

  @override
  _DetectionPageState createState() => _DetectionPageState();
}

class _DetectionPageState extends State<DetectionPage> {
  late FlutterVision vision;
  List<Map<String, dynamic>> detections = [];
  File? _image;
  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> modelLabelPairs = [
    {
      'model': 'assets/model/LeafSpot.tflite',
      'label': 'assets/model/LeafSpot.txt',
      'title': 'โรคใบจุด',
    },
    {
      'model': 'assets/model/LeafBlight.tflite',
      'label': 'assets/model/LeafBlight.txt',
      'title': 'โรคใบไหม้',
    },
    {
      'model': 'assets/model/AlgalLeafSpot.tflite',
      'label': 'assets/model/AlgalLeafSpot.txt',
      'title': 'โรคสาหร่ายใบจุด',
    },
  ];

  final Map<String, String> labelTitleMap = {
    'Anthracnose': 'โรคใบจุด',
    'LeafBlight': 'โรคใบไหม้',
    'AlgalLeafSpot': 'โรคสาหร่ายใบจุด',
  };

  Size? imageSize;
  bool isModelLoading = true;

  @override
  void initState() {
    super.initState();
    initializeVision();
  }

  Future<void> initializeVision() async {
    setState(() {
      isModelLoading = true;
    });
    vision = FlutterVision();
    setState(() {
      isModelLoading = false;
    });
  }

  Future<void> runObjectDetection(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image == null) return;

    setState(() {
      detections = [];
      _image = null;
    });
  
    try {
      Uint8List imageBytes = await image.readAsBytes();
      imageBytes = await convertToJpeg(imageBytes);
      final resizedBytes = await resizeImage(imageBytes, 640, 640);
      final imageData = await decodeImageFromList(resizedBytes);
      imageSize = Size(imageData.width.toDouble(), imageData.height.toDouble());
      List<Map<String, dynamic>> detectionResults = [];
      for (var pair in modelLabelPairs) {
        // Load the current model
        await vision.loadYoloModel(
          labels: pair['label']!,
          modelPath: pair['model']!,
          modelVersion: "yolov5",
          quantization: false,
          numThreads: 1,
          useGpu: true,
        );
        // Run detection
        final result = await vision.yoloOnImage(
          bytesList: resizedBytes,
          imageHeight: imageData.height,
          imageWidth: imageData.width,
          iouThreshold: 0.8,
          confThreshold: 0.4,
          classThreshold: 0.4,
        );

        // If a detection is found, save it and break out of the loop
        if (result.isNotEmpty) {
          detectionResults = result
              .map((res) => {
                    'box': res['box'],
                    'model': pair['model'],
                    // Map the detected tag to title
                    'title': labelTitleMap[res['tag']] ?? res['tag'],
                  })
              .toList();
          break;
        }

        // Unload the model to prepare for the next one
        await vision.closeYoloModel();
      }

      // Update the state to show results
      setState(() {
        detections = detectionResults;
        _image = File(image.path);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error during object detection: $e')),
      );
    }
  }

  Future<Uint8List> convertToJpeg(Uint8List bytes) async {
    final img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception("Failed to decode image");
    }
    return Uint8List.fromList(img.encodeJpg(image));
  }

  Future<Uint8List> resizeImage(Uint8List bytes, int width, int height) async {
    final img.Image? image = img.decodeImage(bytes);
    if (image == null) {
      throw Exception('Failed to decode image');
    }
    final resized = img.copyResize(image, width: width, height: height);
    return Uint8List.fromList(img.encodeJpg(resized));
  }

  @override
  void dispose() {
    vision.closeYoloModel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isModelLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color.fromARGB(255, 255, 0, 119),
              ),
            )
          : Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/image/durian_background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black54,
                    BlendMode.darken,
                  ),
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final screenWidth = constraints.maxWidth;
                          final containerWidth = screenWidth * 0.9;

                          return Center(
                            child: _image == null
                                ? const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.image,
                                          size: 150,
                                          color: Color.fromARGB(
                                              255, 56, 195, 162)),
                                      SizedBox(height: 22),
                                      Text(
                                        'เลือกรูปที่ต้องการตรวจสอบ',
                                        style: TextStyle(
                                            fontSize: 22,
                                            color: Color.fromARGB(
                                                255, 36, 184, 169)),
                                      ),
                                    ],
                                  )
                                : Container(
                                    width: containerWidth,
                                    height: containerWidth,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.black12,
                                          offset: Offset(0, 8),
                                          blurRadius: 16,
                                        ),
                                      ],
                                    ),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(16),
                                          child: Image.file(
                                            _image!,
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                        if (detections.isNotEmpty)
                                          CustomPaint(
                                            painter: BoxPainter(
                                                detections,
                                                imageSize!,
                                                Size(containerWidth,
                                                    containerWidth)),
                                          )
                                        else
                                          Center(
                                            child: Text(
                                              'ไม่พบโรคในรูปนี้',
                                              style: TextStyle(
                                                color: Colors.tealAccent
                                                    .withOpacity(0.8),
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    if (detections.isNotEmpty)
                      Expanded(
                        child: ListView.builder(
                          itemCount: detections.length,
                          itemBuilder: (context, index) {
                            final detection = detections[index];
                            final box = detection['box'];
                            final title = detection['title'];

                            return Card(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 4,
                              child: ListTile(
                                onTap: () {
                                  try {
                                    // Find the disease data by title
                                    final diseaseData = items.firstWhere(
                                      (item) => item['title'] == title,
                                    );

                                    // Navigate to DetailsPage
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => DetailsPage(
                                          images: List<String>.from(
                                              diseaseData['images']),
                                          title: diseaseData['title'],
                                          description:
                                              diseaseData['description'],
                                          link: diseaseData['link'],
                                          cause: diseaseData['cause'],
                                          importance: diseaseData['importance'],
                                          symptoms:
                                              diseaseData['symptoms'] != null
                                                  ? Map<String, String>.from(
                                                      diseaseData['symptoms'])
                                                  : null,
                                          spread: diseaseData['spread'],
                                          prevention:
                                              diseaseData['prevention'] != null
                                                  ? Map<String, String>.from(
                                                      diseaseData['prevention'])
                                                  : null,
                                        ),
                                      ),
                                    );
                                  } catch (e) {
                                    // Handle the case where the disease data is not found
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'ไม่พบข้อมูลสำหรับโรคที่ตรวจพบ')),
                                    );
                                  }
                                },
                                leading: const Icon(
                                  Icons.bug_report,
                                  color: Colors.teal,
                                  size: 36,
                                ),
                                title: Text(
                                  'ตรวจพบ: $title',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.teal,
                                  ),
                                ),
                                subtitle: Text(
                                  'ตำแหน่ง: ${box.toString()}',
                                  style: const TextStyle(
                                    color: Colors.teal,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            FloatingActionButton(
              onPressed: () => runObjectDetection(ImageSource.gallery),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(Icons.photo_library),
            ),
            const SizedBox(width: 16),
            FloatingActionButton(
              onPressed: () => runObjectDetection(ImageSource.camera),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              child: const Icon(Icons.camera_alt),
            ),
          ],
        ),
      ),
    );
  }
}

class BoxPainter extends CustomPainter {
  final List<Map<String, dynamic>> detections;
  final Size imageSize;
  final Size displaySize;

  BoxPainter(this.detections, this.imageSize, this.displaySize);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    for (var detection in detections) {
      final box = detection['box'] as List<dynamic>;
      final left = box[0] as double;
      final top = box[1] as double;
      final right = box[2] as double;
      final bottom = box[3] as double;

      final scaleX = size.width / imageSize.width;
      final scaleY = size.height / imageSize.height;

      final rect = Rect.fromLTWH(
        (left * scaleX).clamp(0.0, size.width),
        (top * scaleY).clamp(0.0, size.height),
        ((right - left) * scaleX).clamp(0.0, size.width - (left * scaleX)),
        ((bottom - top) * scaleY).clamp(0.0, size.height - (top * scaleY)),
      );

      canvas.drawRect(rect, paint);

      final textSpan = TextSpan(
        text: detection['title'],
        style: const TextStyle(
            color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold),
      );
      final textPainter = TextPainter(
        text: textSpan,
        maxLines: 1,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width);

      final offset = Offset(
        rect.left + (rect.width - textPainter.width) / 2,
        rect.top - textPainter.height - 4,
      );
      textPainter.paint(canvas, offset);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
