import 'package:image/image.dart' as img;
import 'package:multithreading_image_processor/mip.dart';

List<String> splitWords(String words) {
  List<String> result = words.split(" ");
  if (result.contains('filter')) {
    final Mip mip = Mip(words: result);
    mip.mip();
  }
  return result;
}

img.Image applyBlackAndWhite(img.Image image) {
  // Converte a imagem para preto e branco.
  final grayscale = img.grayscale(image);
  // Retorna a imagem resultante.
  return grayscale;
}

img.Image applyInvertedColor(img.Image image) {
  // Converte a imagem para preto e branco.
  final invert = img.invert(image);
  // Retorna a imagem resultante.
  return invert;
}

img.Image applyVignette(img.Image image, double? amount) {
  // Converte a imagem para preto e branco.
  final vignette = img.vignette(image);
  if (amount != null) {
    final vignetteAmount = img.vignette(vignette, amount: amount);
    return vignetteAmount;
  }
  // Retorna a imagem resultante.
  return vignette;
}

img.Image applyBillboard(img.Image image) {
  // Converte a imagem para preto e branco.
  final invert = img.billboard(image);
  // Retorna a imagem resultante.
  return invert;
}
