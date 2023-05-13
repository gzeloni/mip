// import 'package:image/image.dart' as img;
// import 'dart:math' as math;
// import 'dart:typed_data';

// class HOG {
//   static img.Image applyHOG(img.Image image) {
//     final resizeImage = img.copyResize(image, width: 22, height: 22);
//     final grayscale = img.grayscale(resizeImage);
//     final sobelX = img.sobel(grayscale);
//     final sobelY = img.sobel(grayscale);

//     // Calcula magnitudes e ângulos de gradiente
//     final magnitudes =
//         img.Image(width: grayscale.width, height: grayscale.height);
//     final angles = img.Image(width: grayscale.width, height: grayscale.height);

//     for (var y = 0; y < grayscale.height; y++) {
//       for (var x = 0; x < grayscale.width; x++) {
//         final dx = sobelX.getPixel(x, y).x;
//         final dy = sobelY.getPixel(x, y).y;
//         final magnitude = math.sqrt(dx * dx + dy * dy).toInt();
//         final angle = (math.atan2(dy, dx) + math.pi) * 180.0 ~/ math.pi;
//         magnitudes.setPixel(
//             x, y, image.getColor(magnitude, magnitude, magnitude));
//         angles.setPixel(x, y, image.getColor(angle, angle, angle));
//       }
//     }

//     // Calcula histogramas de gradiente orientado em células de 8x8 pixels
//     final cellSize = 8;
//     final numBins = 9;
//     final histWidth = grayscale.width ~/ cellSize;
//     final histHeight = grayscale.height ~/ cellSize;
//     final histograms =
//         List.generate(histWidth * histHeight, (_) => List.filled(numBins, 0.0));

//     for (var y = 0; y < grayscale.height; y++) {
//       for (var x = 0; x < grayscale.width; x++) {
//         final cellX = x ~/ cellSize;
//         final cellY = y ~/ cellSize;
//         final pixelValue = angles.getPixel(x, y);
//         final red = pixelValue.r;
//         final green = pixelValue.g;
//         final blue = pixelValue.b;
//         final magnitude = math.sqrt(red * red + green * green + blue * blue);
//         final bin = (magnitude * numBins / 180).floor();
//         if (bin >= numBins) {
//           print('bin: $bin');
//         } else {
//           histograms[cellY * histWidth + cellX][bin] +=
//               magnitudes.getPixel(x, y).r.toDouble();
//         }
//       }
//     }

//     // Normaliza os histogramas de cada bloco
//     final blockSize = 2;
//     final blockStride = 1;
//     final eps = 1e-5;

//     for (var y = 0; y < histHeight - blockSize + 1; y += blockStride) {
//       for (var x = 0; x < histWidth - blockSize + 1; x += blockStride) {
//         var sum = 0.0;

//         for (var i = 0; i < blockSize;) {
//           for (var j = 0; j < blockSize; j++) {
//             final histogram = histograms[(y + i) * histWidth + x + j];
//             for (var k = 0; k < numBins; k++) {
//               sum += histogram[k] * histogram[k];
//             }
//           }
//           final norm = math.sqrt(sum + eps);
//           for (var i = 0; i < blockSize; i++) {
//             for (var j = 0; j < blockSize; j++) {
//               final histogram = histograms[(y + i) * histWidth + x + j];
//               for (var k = 0; k < numBins; k++) {
//                 histogram[k] /= norm;
//               }
//             }
//           }
//         }
//       }
//     }
//     // Concatena os histogramas normalizados em um vetor de características
//     final featureSize = (histWidth ~/ blockStride) *
//         (histHeight ~/ blockStride) *
//         blockSize *
//         blockSize *
//         numBins;
//     final featureVector = Float32List(featureSize);
//     var index = 0;

//     for (var y = 0; y < histHeight - blockSize + 1; y += blockStride) {
//       for (var x = 0; x < histWidth - blockSize + 1; x += blockStride) {
//         for (var i = 0; i < blockSize; i++) {
//           for (var j = 0; j < blockSize; j++) {
//             final histogram = histograms[(y + i) * histWidth + x + j];
//             for (var k = 0; k < numBins; k++) {
//               featureVector[index++] = histogram[k];
//             }
//           }
//         }
//       }
//     }
//     print(featureVector);

//     List bw = [];
//     List<int> bwList = [];
//     for (var y = 0; y < resizeImage.height - 1; y++) {
//       List<int> bwLine = [];
//       for (var x = 0; x < resizeImage.width - 1; x++) {
//         final dx = resizeImage.getPixel(x, y);
//         final red = dx.r;
//         final blue = dx.b;
//         final green = dx.g;
//         final media = (red + blue + green) / 3;
//         bwLine.add(media.toInt());
//         bwList.add(media.toInt());
//       }
//       bw.add(Uint8List.fromList(bwLine));
//     }

//     return resizeImage;
//   }
// }
