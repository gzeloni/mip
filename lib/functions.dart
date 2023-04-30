import 'package:image/image.dart' as img;

class ImageProcessing {
  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  static String fileName() {
    DateTime date = DateTime.now();
    String iso8601 = date.toIso8601String();
    return 'assets/$iso8601-output.png';
  }

  static img.Image applyBlackAndWhite(img.Image image) {
    final grayscale = img.grayscale(image);
    return grayscale;
  }

  static img.Image applyInvertedColor(img.Image image) {
    final invert = img.invert(image);
    return invert;
  }

  static img.Image applyVignette(img.Image image, double amount) {
    final vignette = img.vignette(image, amount: amount);
    return vignette;
  }

  static img.Image applyBillboard(img.Image image) {
    final invert = img.billboard(image);
    return invert;
  }

  static img.Image applySepia(img.Image image) {
    final invert = img.sepia(image);
    return invert;
  }

  static img.Image appyBulge(img.Image image) {
    final bulge = img.bulgeDistortion(image);
    return bulge;
  }
}
