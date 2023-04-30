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

    bool shouldApplyBlackAndWhite =
        words.contains('p&b') && words.every((e) => e != 'inverted');
    bool shouldApplyInvertedColor =
        words.contains('inverted') && words.every((e) => e != 'p&b');
    bool shouldApplyInvertedColorWithBlackAndWhite =
        words.contains('inverted') && words.contains('p&b');
    bool shouldApplyVignette =
        words.contains('with') && words.contains('vignette');
    bool shouldApplyBillboard = words.contains('billboard');
    bool shouldApplySepia = words.contains('sepia');
    bool shouldApplyBulge = words.contains('bulge');

    img.Image processedImage;
    try {
      if (shouldApplyInvertedColorWithBlackAndWhite) {
        processedImage = ImageProcessing.applyInvertedColor(
            ImageProcessing.applyBlackAndWhite(image));
      } else if (shouldApplyBlackAndWhite) {
        processedImage = ImageProcessing.applyBlackAndWhite(image);
      } else if (shouldApplyInvertedColor) {
        processedImage = ImageProcessing.applyInvertedColor(image);
      } else {
        processedImage = image;
      }
      if (shouldApplyBillboard) {
        processedImage = ImageProcessing.applyBillboard(image);
      }
      if (shouldApplySepia) {
        processedImage = ImageProcessing.applySepia(image);
      }
      if (shouldApplyVignette) {
        if (ImageProcessing.isNumeric(words.last)) {
          processedImage = ImageProcessing.applyVignette(
              processedImage, double.tryParse(words.last)!);
        } else {
          processedImage = ImageProcessing.applyVignette(processedImage, 1.4);
        }
      }
      if (shouldApplyBulge) {
        processedImage = ImageProcessing.appyBulge(image);
      }

      final sendPort = args['sendPort'] as SendPort;
      sendPort.send(processedImage);
    } catch (e) {
      print(e.toString());
    }
  }
}
