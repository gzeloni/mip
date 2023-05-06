/// This code is a Dart class called Mip that stands for Multithreading Image Processor.
/// It includes a mip method that processes an image from a given link and saves it to a given file name.
/// The processing can be customized with different options, such as applying a black and white filter,
// an inverted color filter, a vignette effect, a billboard effect, a sepia filter, and a bulge distortion effect.

/// The class also includes a static imageProcessor method that processes the image in a separate isolate,
// which allows for multithreading and improves performance.
/// The words parameter in the constructor is a list of strings that represent the different processing options.

import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:multithreading_image_processor/models/functions.dart';
import 'package:http/http.dart' as http;

class Mip {
  final List<String> words;
  Mip({required this.words});

  Future<void> mip(String imageLink, String filename) async {
    try {
      final response = await http.get(Uri.parse(imageLink));
      final bytes = response.bodyBytes;
      final image = img.decodeImage(bytes);

      // Spawn an isolate to process the image
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

  // Method that processes the image in a separate isolate
  static void imageProcessor(Map<String, dynamic> args) async {
    final image = args['image'] as img.Image;
    final words = args['words'] as List<String>;

    // Set default options for processing
    final shouldApply = <String, bool>{
      'p&b': false,
      'inverted': false,
      'vignette': false,
      'billboard': false,
      'sepia': false,
      'bulge': false,
      'gaussian': false,
      'emboss': false,
      'sobel': false
    };

    // Initialize variables for vignette and bulge options
    double? vignetteThickness;
    int? centerX;
    int? centerY;
    int? gaussRadius;
    double? radius;

    // Parse the options from the list of words
    for (final word in words) {
      // check if word starts with '-' to identify an option
      if (word.startsWith('-')) {
        final key = word.substring(1);
        bool index = words.indexOf(word) + 1 < words.length;
        bool isNumeric =
            ImageProcessing.isNumeric(words[words.indexOf(word) + 1]);
        if (key == 'x' && index && isNumeric) {
          // if option is 'x' and the next word is a number, parse it to int and save it as centerX
          centerX = int.parse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (key == 'y' && index && isNumeric) {
          // if option is 'y' and the next word is a number, parse it to int and save it as centerY
          centerY = int.parse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (key == 'radius' && index && isNumeric) {
          // if option is 'radius' and the next word is a number, parse it to double and save it as radius
          radius = double.tryParse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (key == 'blur' && index && isNumeric) {
          // if option is 'radius' and the next word is a number, parse it to double and save it as radius
          gaussRadius = int.parse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (shouldApply.containsKey(key)) {
          // if option is valid and doesn't require a value, set its value to true
          shouldApply[key] = true;
          if (key == 'vignette' && index && isNumeric) {
            // if option is 'vignette' and the next word is a number, parse it to double and save it as vignetteThickness
            vignetteThickness = double.tryParse(words[words.indexOf(word) + 1]);
          }
        }
      } else if (shouldApply.containsKey(word)) {
        // if word is a valid option and doesn't require a value, set its value to true
        shouldApply[word] = true;
      }
    }

    ///This section of code takes in the processed image and applies image processing filters based on the shouldApply map.
    ///The shouldApply map is a Map<String, bool> which represents which filters should be applied to the image.

    img.Image processedImage = image;

    // Check if 'p&b' flag is enabled
    if (shouldApply['p&b']!) {
      // Apply black and white filter to the image
      processedImage = ImageProcessing.applyBlackAndWhite(image);
    }

    // Check if 'inverted' flag is enabled
    if (shouldApply['inverted']!) {
      // Apply inverted color filter to the image
      processedImage = ImageProcessing.applyInvertedColor(image);
    }

    // Check if 'billboard' flag is enabled
    if (shouldApply['billboard']!) {
      // Apply billboard filter to the image
      processedImage = ImageProcessing.applyBillboard(processedImage);
    }

    // Check if 'sepia' flag is enabled
    if (shouldApply['sepia']!) {
      // Apply sepia filter to the image
      processedImage = ImageProcessing.applySepia(processedImage);
    }

    // Check if 'vignette' flag is enabled
    if (shouldApply['vignette']!) {
      // Apply vignette filter to the image
      processedImage = ImageProcessing.applyVignette(
          processedImage, vignetteThickness ?? 1.4);
    }

    // Check if 'bulge' flag is enabled
    if (shouldApply['bulge']!) {
      // Apply bulge filter to the image
      processedImage = ImageProcessing.appyBulge(processedImage,
          centerX: centerX, centerY: centerY, radius: radius);
    }

    // Check if 'gaussian' flag is enabled
    if (shouldApply['gaussian']!) {
      // Apply gaussian filter to the image
      processedImage =
          ImageProcessing.applyGaussianBlur(processedImage, gaussRadius ?? 5);
    }

    // Check if 'emboss' flag is enabled
    if (shouldApply['emboss']!) {
      // Apply emboss convolution filter to the image
      processedImage = ImageProcessing.applyEmboss(processedImage);
    }

    // Check if 'sobel' flag is enabled
    if (shouldApply['sobel']!) {
      // Apply sobel edge detection filtering to the image
      processedImage = ImageProcessing.applySobel(processedImage);
    }

    // Get the sendPort from the arguments and send the processed image
    final sendPort = args['sendPort'] as SendPort;
    sendPort.send(processedImage);
  }
}
