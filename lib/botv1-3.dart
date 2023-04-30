import 'dart:io';
import 'package:multithreading_image_processor/config/config.dart';
import 'package:multithreading_image_processor/functions.dart';
import 'package:multithreading_image_processor/mip.dart';
import 'package:multithreading_image_processor/utils/commands_list.dart';
import "package:nyxx/nyxx.dart";

void botv2() {
  final bot = NyxxFactory.createNyxxWebsocket(
      Config.getToken(),
      GatewayIntents.allUnprivileged |
          GatewayIntents.allPrivileged |
          GatewayIntents.messageContent);

  bot.eventsWs.onReady.listen((event) {
    print("Ready!");
  });

  bot.eventsWs.onMessageReceived.listen((event) async {
    final content = event.message.content;

    if (content.startsWith('&make') && content.length >= 7) {
      final links = content
          .split(' ')
          .where((element) =>
              element.contains('http://') || element.contains('https://'))
          .toList();

      if (links.length != 1) {
        event.message.channel.sendMessage(MessageBuilder.content(
            'Por favor, insira um link e os parâmetros após o comando `&make`.'));
        return;
      }

      final filename = ImageProcessing.fileName().toString();
      event.message.channel.sendMessage(
          MessageBuilder.content('Aguarde a imagem ser processada...'));

      final mip = Mip(words: content.split(' '));
      await mip.mip(links[0], filename);

      final files = [AttachmentBuilder.file(File(filename))];
      await event.message.channel.sendMessage(MessageBuilder.files(files));
      File(filename).delete();
    }

    if (content.startsWith('&help')) {
      final embed = EmbedBuilder(
        author: EmbedAuthorBuilder(
          iconUrl:
              'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
          name: 'MIP - Multithreading Image Processor V1.3',
        ),
        title: 'COMMANDS',
        description: commands,
        footer: EmbedFooterBuilder(
          iconUrl:
              'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
          text: 'For more information, Naive Bayes#9556',
        ),
      );

      await event.message.channel.sendMessage(MessageBuilder.embed(embed));
    }
  });

  bot.connect();
}
