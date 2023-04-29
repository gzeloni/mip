import 'dart:io';
import 'dart:isolate';
import 'package:image/image.dart' as img;

class Mip {
  void mip() async {
    // Caminho para a imagem a ser processada.
    const imagePath = 'assets/input.jpeg';
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
    await File('assets/output.jpeg').writeAsBytes(img.encodePng(newImage));
  }

  void imageProcessor(Map<String, dynamic> args) async {
    // Obtém a imagem enviada pelo processo principal.
    final image = args['image'] as img.Image;
    // Cria uma nova imagem com o filtro preto e branco aplicado.
    final newImage = applyBlackAndWhiteFilter(image);
    // Envia a imagem processada de volta para o processo principal.
    final sendPort = args['sendPort'] as SendPort;
    sendPort.send(newImage);
  }

  img.Image applyBlackAndWhiteFilter(img.Image image) {
    // Converte a imagem para preto e branco.
    final grayscale = img.grayscale(image);
    // Inverte a imagem em escala de cinza para obter o filtro preto e branco.
    final inverted = img.invert(grayscale);
    // Retorna a imagem resultante.
    return inverted;
  }
}
