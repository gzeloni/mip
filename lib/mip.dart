/// This code is a Dart class called MultithreadingImageProcessor that implements a multithreading image processing functionality.
/// The class includes a method called mip, which processes an image from a given link and saves it to a specified file name.
/// The processing options can be customized, such as applying a black and white filter, inverted color filter, vignette effect,
/// billboard effect, sepia filter, and bulge distortion effect.

/// The class also includes a static method called imageProcessor that processes the image in a separate isolate,
/// allowing for multithreading and improved performance.
/// The 'words' parameter in the constructor is a list of strings that represents the different processing options.

import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:multithreading_image_processor/constants/options.dart';
import 'package:multithreading_image_processor/models/filters.dart';
import 'package:http/http.dart' as http;
import 'package:multithreading_image_processor/models/log_function.dart';

class MultithreadingImageProcessor {
  final List<String> words;

  MultithreadingImageProcessor({required this.words});

  /// Method that processes an image using multithreading and saves it to a file.
  Future<void> mip(String imageLink, String filename) async {
    try {
      final uri = Uri.parse(imageLink);
      final isGif = uri.path.toLowerCase().contains('.gif');
      final response = await http.get(uri);
      final bytes = response.bodyBytes;
      final image = isGif ? img.decodeGif(bytes) : img.decodeImage(bytes);

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

      // Write the processed image to a file
      try {
        final file = File(filename);
        await file.writeAsBytes(
          isGif ? img.encodeGif(newImage) : img.encodePng(newImage),
        );
      } on FileSystemException catch (e) {
        logError('Error in file system while saving the image: $e',
            'errors/OS_errors.log');
      } catch (e) {
        logError(
            'Unknown error while saving the image: $e', 'errors/OS_errors.log');
      }
    } on IsolateSpawnException catch (e) {
      logError('Error creating the isolate: $e', 'errors/isolate_errors.log');
    } on RemoteError catch (e) {
      logError('Remote error: $e', 'errors/isolate_errors.log');
    } catch (e) {
      logError('Unknown error: $e', 'errors/unknown_errors.log');
    }
  }

  /// Method that processes the image in a separate isolate.
  static void imageProcessor(Map<String, dynamic> args) async {
    final image = args['image'] as img.Image;
    final words = args['words'] as List<String>;

    // Parse the options from the list of words
    Map<String, Function> options = {
      'x': (String value) {
        centerX = int.parse(value);
      },
      'y': (String value) {
        centerY = int.parse(value);
      },
      'radius': (String value) {
        radius = double.tryParse(value);
      },
      'blur': (String value) {
        gaussRadius = int.parse(value);
      },
      'shift': (String value) {
        shift = int.parse(value);
      },
      'vignette': (String value) {
        vignetteThickness = double.tryParse(value);
      },
    };

    for (final word in words) {
      if (word.startsWith('-')) {
        final key = word.substring(1);
        final index = words.indexOf(word) + 1 < words.length;
        final isNumeric =
            ImageProcessing.isNumeric(words[words.indexOf(word) + 1]);

        if (options.containsKey(key) && index && isNumeric) {
          options[key]!(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (shouldApply[key] != null) {
          shouldApply[key] = true;
          if (key == 'vignette' && index && isNumeric) {
            vignetteThickness = double.tryParse(words[words.indexOf(word) + 1]);
          }
        } else if (!isNumeric) {
          return;
        }
      } else if (shouldApply.containsKey(word)) {
        shouldApply[word] = true;
      }
    }

    // This section of code takes the processed image and applies image processing filters based on the shouldApply map.
    // The shouldApply map is a Map<String, bool> which represents which filters should be applied to the image.

    img.Image processedImage = image;

    Map<String, img.Image Function(img.Image)> filters = {
      'p&b': ImageProcessing.convertToGrayscale,
      'inverted': ImageProcessing.applyInvertedColor,
      'billboard': ImageProcessing.applyBillboard,
      'sepia': ImageProcessing.applySepia,
      'vignette': (image) =>
          ImageProcessing.applyVignette(image, vignetteThickness ?? 1.4),
      'bulge': (image) => ImageProcessing.applyBulge(image,
          centerX: centerX, centerY: centerY, radius: radius),
      'gaussian': (image) =>
          ImageProcessing.applyGaussianBlur(image, gaussRadius ?? 5),
      'emboss': ImageProcessing.applyEmboss,
      'sobel': ImageProcessing.applySobel,
      'sketch': ImageProcessing.applySketch,
      'chromatic': (image) => ImageProcessing.applyChromatic(image, shift ?? 5),
    };

    for (final entry in shouldApply.entries) {
      if (entry.value) {
        final key = entry.key;
        if (filters.containsKey(key)) {
          processedImage =
              ImageProcessing.applyFilter(processedImage, filters[key]!);
        }
      }
    }

    // Get the sendPort from the arguments and send the processed image
    final sendPort = args['sendPort'] as SendPort;
    sendPort.send(processedImage);
  }
}
