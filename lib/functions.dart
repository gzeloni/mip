import 'package:image/image.dart' as img;
// List<String> splitWords(String words) {
//   List<String> result = words.split(" ");
//   if (result.contains('filter')) {
//     final Mip mip = Mip(words: result);
//     // mip.mip();
//   }
//   return result;
// }

bool isNumeric(String s) {
  // ignore: unnecessary_null_comparison
  if (s == null) {
    return false;
  }
  return double.tryParse(s) != null;
}

String fileName() {
  DateTime date = DateTime.now();
  String iso8601 = date.toIso8601String();
  return 'assets/$iso8601-output.png';
}

img.Image applyBlackAndWhite(img.Image image) {
  final grayscale = img.grayscale(image);
  return grayscale;
}

img.Image applyInvertedColor(img.Image image) {
  final invert = img.invert(image);
  return invert;
}

img.Image applyVignette(img.Image image, double? amount) {
  final vignette = img.vignette(image, amount: amount!);
  return vignette;
}

img.Image applyBillboard(img.Image image) {
  final invert = img.billboard(image);
  return invert;
}

img.Image applySepia(img.Image image) {
  final invert = img.sepia(image);
  return invert;
}

img.Image appyBulge(img.Image image) {
  final bulge = img.bulgeDistortion(image);
  return bulge;
}
