import 'dart:io';

import 'package:multithreading_image_processor/config/config.dart';
import 'package:multithreading_image_processor/mip.dart';
import "package:nyxx/nyxx.dart";

// Main function
void bot() {
  // Create new bot instance
  final bot = NyxxFactory.createNyxxWebsocket(
      Config.token(),
      GatewayIntents.allUnprivileged |
          GatewayIntents
              .messageContent) // Here we use the privilegied intent message content to receive incoming messages.
    ..registerPlugin(Logging()) // Default logging plugin
    ..registerPlugin(
        CliIntegration()) // Cli integration for nyxx allows stopping application via SIGTERM and SIGKILl
    ..registerPlugin(
        IgnoreExceptions()) // Plugin that handles uncaught exceptions that may occur
    ..connect();

  // Listen to ready event. Invoked when bot is connected to all shards. Note that cache can be empty or not incomplete.
  bot.eventsWs.onReady.listen((e) {
    print("Ready!");
  });

  // Listen to all incoming messages
  bot.eventsWs.onMessageReceived.listen((e) async {
    // Check if message content equals "!ping"
    if (e.message.content.startsWith("&make")) {
      // Send "Pong!" to channel where message was received
      final splitContent = e.message.content.split(" ");
      final Mip mip = Mip(words: splitContent);
      if (splitContent[1].startsWith("http")) {
        mip.mip(splitContent[1]);
        e.message.channel
            .sendMessage(MessageBuilder.content("Aguarde 2 segundos..."));
        Future.delayed(Duration(seconds: 2), () {
          List<AttachmentBuilder> files = [
            AttachmentBuilder.file(File('assets/output.png'))
          ];
          e.message.channel
              .sendMessage(MessageBuilder.files(files))
              .whenComplete(() {
            File('assets/output.png').delete();
          });
        });
      } else {
        e.message.channel.sendMessage(MessageBuilder.content(
            "Não há link após o comando make ou o link não foi encontrado na mensagem!"));
      }
    }

    if (e.message.content.startsWith("&help")) {
      e.message.channel.sendMessage(MessageBuilder.embed(
        EmbedBuilder(
            author: EmbedAuthorBuilder(
              iconUrl:
                  "https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32",
              name: 'MIP - Multithreading Image Processor',
            ),
            title: 'COMMANDS',
            description: '''
              &make <link> parameters\n
              p&b: Apply a black and white filter to the image\n
              inverted: Apply a inverted color filter to the image\n
              billboard: Apply a billboard (the image is made up of dots) filter to the image\n
              sepia: Apply a sepia (shades of yellow) filter to the image\n
              with vignette: Apply a vignette with 1.5 value (custom values ​in next update) to the image
            ''',
            footer: EmbedFooterBuilder(
                iconUrl:
                    "https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32",
                text: 'For more information, @Naive Bayes')),
      ));
    }
  });
}
