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
    int? centerX;
    int? centerY;
    double? radius;

    for (final word in words) {
      if (word.startsWith('-')) {
        final key = word.substring(1);
        if (key == 'x' &&
            words.indexOf(word) + 1 < words.length &&
            ImageProcessing.isNumeric(words[words.indexOf(word) + 1])) {
          centerX = int.parse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (key == 'y' &&
            words.indexOf(word) + 1 < words.length &&
            ImageProcessing.isNumeric(words[words.indexOf(word) + 1])) {
          centerY = int.parse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (key == 'radius' &&
            words.indexOf(word) + 1 < words.length &&
            ImageProcessing.isNumeric(words[words.indexOf(word) + 1])) {
          radius = double.tryParse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (shouldApply.containsKey(key)) {
          shouldApply[key] = true;
          if (key == 'vignette' &&
              words.indexOf(word) + 1 < words.length &&
              ImageProcessing.isNumeric(words[words.indexOf(word) + 1])) {
            vignetteThickness = double.tryParse(words[words.indexOf(word) + 1]);
          }
        }
      } else if (shouldApply.containsKey(word)) {
        shouldApply[word] = true;
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
      processedImage = ImageProcessing.appyBulge(processedImage,
          centerX: centerX, centerY: centerY, radius: radius);
      print('Bulge aplicado com sucesso');
    }
    final sendPort = args['sendPort'] as SendPort;
    sendPort.send(processedImage);
  }
}
