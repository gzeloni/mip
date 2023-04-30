import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:multithreading_image_processor/functions.dart';
import 'package:http/http.dart' as http;

class Mip {
  List<String> words;
  Mip({required this.words});

  void mip(String imageLink) async {
    try {
      // Caminho para a imagem a ser processada.
      // const imagePath = 'assets/lena.png';
      final response = await http.get(Uri.parse(imageLink));
      // Carrega a imagem do disco.
      final bytes = response.bodyBytes;
      final image = img.decodeImage(bytes);
      // Cria um canal de comunicação para enviar a imagem para o isolate.
      final receivePort = ReceivePort();
      // Cria um isolate e envia o canal de comunicação como argumento.
      await Isolate.spawn(
        imageProcessor,
        {'sendPort': receivePort.sendPort, 'image': image},
      );
      // Aguarda o recebimento da mensagem contendo a imagem processada.
      final newImage = await receivePort.first as img.Image;
      // Salva a imagem processada no disco.
      await File('assets/output.png').writeAsBytes(img.encodePng(newImage));
    } catch (e) {
      print(e.toString());
    }
  }

  void imageProcessor(Map<String, dynamic> args) async {
    try {
      // Obtém a imagem enviada pelo processo principal.
      final image = args['image'] as img.Image;
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
      img.Image processedImage;

      if (shouldApplyInvertedColorWithBlackAndWhite) {
        processedImage = applyInvertedColor(applyBlackAndWhite(image));
      } else if (shouldApplyBlackAndWhite) {
        processedImage = applyBlackAndWhite(image);
      } else if (shouldApplyInvertedColor) {
        processedImage = applyInvertedColor(image);
      } else {
        processedImage = image;
      }
      if (shouldApplyBillboard) {
        processedImage = applyBillboard(image);
      }
      if (shouldApplySepia) {
        processedImage = applySepia(image);
      }
      if (shouldApplyVignette) {
        processedImage = applyVignette(processedImage);
      }

      // Envia a imagem processada de volta para o processo principal.
      final sendPort = args['sendPort'] as SendPort;
      sendPort.send(processedImage);
    } catch (e) {
      print(e.toString());
    }
  }
}
