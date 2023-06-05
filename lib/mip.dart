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
    for (final word in words) {
      // Check if the word starts with '-' to identify an option
      if (word.startsWith('-')) {
        final key = word.substring(1);
        bool index = words.indexOf(word) + 1 < words.length;
        bool isNumeric =
            ImageProcessing.isNumeric(words[words.indexOf(word) + 1]);

        if (key == 'x' && index && isNumeric) {
          // If the option is 'x' and the next word is a number, parse it to int and save it as centerX
          centerX = int.parse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (key == 'y' && index && isNumeric) {
          // If the option is 'y' and the next word is a number, parse it to int and save it as centerY
          centerY = int.parse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (key == 'radius' && index && isNumeric) {
          // If the option is 'radius' and the next word is a number, parse it to double and save it as radius
          radius = double.tryParse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (key == 'blur' && index && isNumeric) {
          // If the option is 'blur' and the next word is a number, parse it to double and save it as gaussRadius
          gaussRadius = int.parse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (key == 'shift' && index && isNumeric) {
          // If the option is 'shift' and the next word is a number, parse it to double and save it as shift
          shift = int.parse(words[words.indexOf(word) + 1]);
          shouldApply[key] = true;
        } else if (shouldApply[key] != null) {
          // If the option is valid and doesn't require a value, set its value to true
          shouldApply[key] = true;

          if (key == 'vignette' && index && isNumeric) {
            // If the option is 'vignette' and the next word is a number, parse it to double and save it as vignetteThickness
            vignetteThickness = double.tryParse(words[words.indexOf(word) + 1]);
          }
        } else if (!isNumeric) {
          return;
        }
      } else if (shouldApply.containsKey(word)) {
        // If the word is a valid option and doesn't require a value, set its value to true
        shouldApply[word] = true;
      }
    }

    // This section of code takes the processed image and applies image processing filters based on the shouldApply map.
    // The shouldApply map is a Map<String, bool> which represents which filters should be applied to the image.

    img.Image processedImage = image;

    // Check if the 'p&b' flag is enabled
    if (shouldApply['p&b']!) {
      // Apply the black and white filter to the image
      processedImage = ImageProcessing.applyFilter(
          processedImage, ImageProcessing.convertToGrayscale);
    }

    // Check if the 'inverted' flag is enabled
    if (shouldApply['inverted']!) {
      // Apply the inverted color filter to the image
      processedImage = ImageProcessing.applyFilter(
          processedImage, ImageProcessing.applyInvertedColor);
    }

    // Check if the 'billboard' flag is enabled
    if (shouldApply['billboard']!) {
      // Apply the billboard filter to the image
      processedImage = ImageProcessing.applyFilter(
          processedImage, ImageProcessing.applyBillboard);
    }

    // Check if the 'sepia' flag is enabled
    if (shouldApply['sepia']!) {
      // Apply the sepia filter to the image
      processedImage = ImageProcessing.applyFilter(
          processedImage, ImageProcessing.applySepia);
    }

    // Check if the 'vignette' flag is enabled
    if (shouldApply['vignette']!) {
      // Apply the vignette filter to the image
      processedImage = ImageProcessing.applyFilter(
          processedImage,
          (image) =>
              ImageProcessing.applyVignette(image, vignetteThickness ?? 1.4));
    }

    // Check if the 'bulge' flag is enabled
    if (shouldApply['bulge']!) {
      // Apply the bulge filter to the image
      processedImage = ImageProcessing.applyFilter(
          processedImage,
          (image) => ImageProcessing.applyBulge(image,
              centerX: centerX, centerY: centerY, radius: radius));
    }

    // Check if the 'gaussian' flag is enabled
    if (shouldApply['gaussian']!) {
      // Apply the gaussian filter to the image
      processedImage = ImageProcessing.applyFilter(
          processedImage,
          (image) =>
              ImageProcessing.applyGaussianBlur(image, gaussRadius ?? 5));
    }

    // Check if the 'emboss' flag is enabled
    if (shouldApply['emboss']!) {
      // Apply the emboss convolution filter to the image
      processedImage = ImageProcessing.applyFilter(
          processedImage, ImageProcessing.applyEmboss);
    }

    // Check if the 'sobel' flag is enabled
    if (shouldApply['sobel']!) {
      // Apply the sobel edge detection filtering to the image
      processedImage = ImageProcessing.applyFilter(
          processedImage, ImageProcessing.applySobel);
    }

    // Check if the 'sketch' flag is enabled
    if (shouldApply['sketch']!) {
      // Apply the sketch filter to the image
      processedImage = ImageProcessing.applyFilter(
          processedImage, ImageProcessing.applySketch);
    }

    // Check if the 'chromatic' flag is enabled
    if (shouldApply['chromatic']!) {
      // Apply the chromatic aberration filter to the image
      processedImage = ImageProcessing.applyFilter(processedImage,
          (image) => ImageProcessing.applyChromatic(image, shift ?? 5));
    }

    // Get the sendPort from the arguments and send the processed image
    final sendPort = args['sendPort'] as SendPort;
    sendPort.send(processedImage);
  }
}
