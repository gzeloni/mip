import 'dart:io';

import 'package:multithreading_image_processor/config/config.dart';
import 'package:multithreading_image_processor/functions.dart';
import 'package:multithreading_image_processor/mip.dart';
import 'package:multithreading_image_processor/utils/commands_list.dart';
import "package:nyxx/nyxx.dart";

// Main function
void bot() {
  // Create new bot instance
  final bot = NyxxFactory.createNyxxWebsocket(
      Config.token(),
      GatewayIntents.allUnprivileged |
          GatewayIntents.allPrivileged |
          GatewayIntents.messageContent)
    ..registerPlugin(Logging())
    ..registerPlugin(CliIntegration())
    ..registerPlugin(IgnoreExceptions())
    ..connect();

  bot.eventsWs.onReady.listen((e) {
    print("Ready!");
  });

  bot.eventsWs.onMessageReceived.listen(
    (e) async {
      if (e.message.content.startsWith("&make") &&
          e.message.content.length >= 7) {
        final String filename = fileName().toString();
        bool exists = false;
        List<String> links = [];
        final splitContent = e.message.content.split(" ");
        for (var e in splitContent) {
          if (e.contains("http://") || e.contains("https://")) {
            links.add(e);
            exists = true;
          }
        }
        if (exists == true) {
          if (links.length > 1) {
            e.message.channel.sendMessage(MessageBuilder.content(
                "Há mais de um link na mensagem! Por favor, insira apenas um link após o comando `&make`."));
            return;
          }
          e.message.channel.sendMessage(
              MessageBuilder.content("Aguarde a imagem ser processada..."));
          final Mip mip = Mip(words: splitContent);
          await mip.mip(links[0], filename).whenComplete(() {
            List<AttachmentBuilder> files = [
              AttachmentBuilder.file(File(filename))
            ];
            e.message.channel
                .sendMessage(MessageBuilder.files(files))
                .whenComplete(() {
              File(filename).delete();
            });
          });
        } else {
          e.message.channel.sendMessage(MessageBuilder.content(
              "Não há link após o comando make ou o link não foi encontrado na mensagem!"));
        }
      }

      if (e.message.content.startsWith("&help")) {
        e.message.channel.sendMessage(
          MessageBuilder.embed(
            EmbedBuilder(
              author: EmbedAuthorBuilder(
                iconUrl:
                    "https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32",
                name: 'MIP - Multithreading Image Processor',
              ),
              title: 'COMMANDS',
              description: commands,
              footer: EmbedFooterBuilder(
                iconUrl:
                    "https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32",
                text: 'For more information, @Naive Bayes',
              ),
            ),
          ),
        );
      }
    },
  );
}
