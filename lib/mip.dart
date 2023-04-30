import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:multithreading_image_processor/functions.dart';
import 'package:http/http.dart' as http;

class Mip {
  final List<String> words;
  Mip({required this.words});

  Future<void> mip(String imageLink, String filename) async {
    try {
      final response = await http.get(Uri.parse(imageLink));
      final bytes = response.bodyBytes;
      final image = img.decodeImage(bytes);

      final receivePort = ReceivePort();
      await Isolate.spawn(
        imageProcessor,
        {
          'sendPort': receivePort.sendPort,
          'image': image,
          'words': words,
        },
      );
      final newImage = await receivePort.first as img.Image;
      await File(filename).writeAsBytes(img.encodePng(newImage));
    } catch (e) {
      print(e.toString());
    }
  }

  static void imageProcessor(Map<String, dynamic> args) async {
    final image = args['image'] as img.Image;
    final words = args['words'] as List<String>;

    final shouldApply = <String, bool>{
      'p&b': false,
      'inverted': false,
      'vignette': false,
      'billboard': false,
      'sepia': false,
      'bulge': false,
    };

    double? vignetteThickness;

    for (final word in words) {
      if (shouldApply.containsKey(word)) {
        shouldApply[word] = true;
      } else if (word == 'with') {
        final nextWordIndex = words.indexOf(word) + 1;
        if (nextWordIndex < words.length &&
            shouldApply.containsKey(words[nextWordIndex]) &&
            nextWordIndex + 1 < words.length &&
            ImageProcessing.isNumeric(words[nextWordIndex + 1])) {
          shouldApply[words[nextWordIndex]] = true;
          if (words[nextWordIndex] == 'vignette') {
            vignetteThickness = double.tryParse(words[nextWordIndex + 1]);
          }
        }
      }
    }

    img.Image processedImage = image;

    if (shouldApply['p&b']!) {
      processedImage = ImageProcessing.applyBlackAndWhite(image);
    }
    if (shouldApply['inverted']!) {
      processedImage = ImageProcessing.applyInvertedColor(image);
    }
    if (shouldApply['billboard']!) {
      processedImage = ImageProcessing.applyBillboard(processedImage);
    }
    if (shouldApply['sepia']!) {
      processedImage = ImageProcessing.applySepia(processedImage);
    }
    if (shouldApply['vignette']!) {
      processedImage = ImageProcessing.applyVignette(
          processedImage, vignetteThickness ?? 1.4);
    }
    if (shouldApply['bulge']!) {
      processedImage = ImageProcessing.appyBulge(processedImage);
    }
    final sendPort = args['sendPort'] as SendPort;
    sendPort.send(processedImage);
  }
}
