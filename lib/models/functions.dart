/// This class provides methods for processing images using the image package.
import 'package:image/image.dart' as img;

class ImageProcessing {
  /// This method checks if a given string is numeric or not.
  /// @param [s] The string to check.
  /// @return Returns true if the string is numeric, else false.
  static bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  /// This method returns a file name for the processed image based on the current date and time.
  /// @return Returns a string representing the file name.
  static String fileName() {
    DateTime date = DateTime.now();
    String iso8601 = date.toIso8601String();
    return 'assets/$iso8601-output.png';
  }

  /// This method applies a black and white filter to the given image.
  /// @param [image] The image to apply the filter to.
  /// @return Returns a new image with the filter applied.
  static img.Image applyBlackAndWhite(img.Image image) {
    final grayscale = img.grayscale(image);
    return grayscale;
  }

  /// This method applies an inverted color filter to the given image.
  /// @param [image] The image to apply the filter to.
  /// @return Returns a new image with the filter applied.
  static img.Image applyInvertedColor(img.Image image) {
    final invert = img.invert(image);
    return invert;
  }

  /// This method applies a vignette filter to the given image.
  /// @param [image] The image to apply the filter to.
  /// @param [amount] The amount of vignette to apply.
  /// @return Returns a new image with the filter applied.
  static img.Image applyVignette(img.Image image, double amount) {
    final vignette = img.vignette(image, amount: amount);
    return vignette;
  }

  /// This method applies a billboard filter to the given image.
  /// @param [image] The image to apply the filter to.
  /// @return Returns a new image with the filter applied.
  static img.Image applyBillboard(img.Image image) {
    final invert = img.billboard(image);
    return invert;
  }

  /// This method applies a sepia filter to the given image.
  /// @param [image] The image to apply the filter to.
  /// @return Returns a new image with the filter applied.
  static img.Image applySepia(img.Image image) {
    final invert = img.sepia(image);
    return invert;
  }

  /// This method applies a bulge distortion filter to the given image.
  /// @param [image] The image to apply the filter to.
  /// @param [centerX] The x-coordinate of the center of the bulge.
  /// @param [centerY] The y-coordinate of the center of the bulge.
  /// @param [radius] The radius of the bulge.
  /// @return Returns a new image with the filter applied.
  static img.Image appyBulge(img.Image image,
      {int? centerX, int? centerY, num? radius}) {
    final bulge = img.bulgeDistortion(image,
        centerX: centerX, centerY: centerY, radius: radius);
    return bulge;
  }

  /// This method applies a gaussian blur filter to the given image.
  /// @param [image] The image to apply the filter to.
  /// @param [radius] The radius of the gaussian blur.
  static img.Image applyGaussianBlur(img.Image image, int radius) {
    final invert = img.gaussianBlur(image, radius: radius);
    return invert;
  }

  /// This method applies a emboss convolution filter to the given image.
  /// @param [image] The image to apply the filter to.
  static img.Image applyEmboss(img.Image image) {
    final invert = img.emboss(image);
    return invert;
  }

  static img.Image applyAdjustColor(
    img.Image image, {
    num? contrast,
    num? saturation,
    num? brightness,
    num? gamma,
    num? exposure,
    num? hue,
  }) {
    final invert = img.adjustColor(image,
        contrast: contrast,
        saturation: saturation,
        brightness: brightness,
        gamma: gamma,
        exposure: exposure,
        hue: hue,
        amount: 1);
    return invert;
  }

  static img.Image applySobel(img.Image image) {
    final resize = img.copyResize(image, width: 128, height: 64);
    final apSobel = img.sobel(resize);
    final apLuminance = img.luminanceThreshold(apSobel);
    final uint8 = apLuminance.toUint8List();
    print(uint8.toString());
    return apLuminance;
  }
}
