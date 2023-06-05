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
  static String getFileName(bool isGif) {
    final date = DateTime.now();
    final iso8601 = date.toIso8601String();
    return isGif ? 'assets/$iso8601-output.gif' : 'assets/$iso8601-output.png';
  }

  /// This method applies a filter to the given image.
  /// @param [image] The image to apply the filter to.
  /// @param [filterFunction] The filter function to apply.
  /// @return Returns a new image with the filter applied.
  static img.Image applyFilter(
      img.Image image, img.Image Function(img.Image) filterFunction) {
    return filterFunction(image);
  }

  /// Filter functions

  static img.Image convertToGrayscale(img.Image image) {
    return img.grayscale(image);
  }

  static img.Image applyInvertedColor(img.Image image) {
    return img.invert(image);
  }

  static img.Image applyVignette(img.Image image, double amount) {
    return img.vignette(image, amount: amount);
  }

  static img.Image applyBillboard(img.Image image) {
    return img.billboard(image);
  }

  static img.Image applySepia(img.Image image) {
    return img.sepia(image);
  }

  static img.Image applyBulge(img.Image image,
      {int? centerX, int? centerY, num? radius}) {
    return img.bulgeDistortion(image,
        centerX: centerX, centerY: centerY, radius: radius);
  }

  static img.Image applyGaussianBlur(img.Image image, int radius) {
    return img.gaussianBlur(image, radius: radius);
  }

  static img.Image applyEmboss(img.Image image) {
    return img.emboss(image);
  }

  static img.Image applySobel(img.Image image) {
    return img.sobel(image);
  }

  static img.Image applySketch(img.Image image) {
    return img.sketch(image);
  }

  static img.Image applyChromatic(img.Image image, int shift) {
    return img.chromaticAberration(image, shift: shift);
  }
}
