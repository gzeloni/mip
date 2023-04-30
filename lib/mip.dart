import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;
import 'package:multithreading_image_processor/functions.dart';

class Mip {
  List<String> words;
  Mip({required this.words});

  void mip() async {
    // Caminho para a imagem a ser processada.
    const imagePath = 'assets/lena.png';
    // Carrega a imagem do disco.
    final bytes = await File(imagePath).readAsBytes();
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
  }

  void imageProcessor(Map<String, dynamic> args) async {
    // Obtém a imagem enviada pelo processo principal.
    final image = args['image'] as img.Image;
    bool shouldApplyBlackAndWhite =
        words.contains('p&b') && words.every((e) => e != 'inverted');
    bool shouldApplyInvertedColor =
        words.contains('inverted') && words.every((e) => e != 'p&b');
    bool shouldApplyVignette =
        words.contains('with') && words.contains('vignette');
    bool shouldApplyBillboard = words.contains('billboard');
    img.Image processedImage;

    if (shouldApplyBlackAndWhite && shouldApplyInvertedColor) {
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
    if (shouldApplyVignette) {
      stdout.write("Vignette value:  ");
      double? read = double.parse(stdin.readLineSync()!);
      processedImage = applyVignette(processedImage, read);
    }

    // Envia a imagem processada de volta para o processo principal.
    final sendPort = args['sendPort'] as SendPort;
    sendPort.send(processedImage);
  }
}
