import 'dart:io';
import 'package:multithreading_image_processor/config/config.dart';
import 'package:multithreading_image_processor/functions.dart';
import 'package:multithreading_image_processor/mip.dart';
import 'package:multithreading_image_processor/utils/commands_list.dart';
import "package:nyxx/nyxx.dart";

void botv2() {
  // Create Nyxx bot instance with necessary intents
  final bot = NyxxFactory.createNyxxWebsocket(
      Config.getToken(),
      GatewayIntents.allUnprivileged |
          GatewayIntents.allPrivileged |
          GatewayIntents.messageContent);

  // Listener for when the bot is ready
  bot.eventsWs.onReady.listen((event) {
    print("Ready!");
  });

  // Listener for when a message is received
  bot.eventsWs.onMessageReceived.listen((event) async {
    final content = event.message.content;

    // Dont process message when not send in guild context
    if (event.message.guild != null) {
      return;
    }
    // Check if the message starts with the "&make" command
    if (content.startsWith('&make') && content.length >= 7) {
      // Extract image links from the message content
      final links = content
          .split(' ')
          .where((element) =>
              element.contains('http://') || element.contains('https://'))
          .toList();

      // If there's not exactly one link, send an error message and return
      if (links.length != 1) {
        event.message.channel.sendMessage(MessageBuilder.content(
            'Por favor, insira um link e os parâmetros após o comando `&make`.'));
        return;
      }

      // Generate a unique filename for the processed image
      final filename = ImageProcessing.fileName().toString();
      // Send a message indicating that the image is being processed
      event.message.channel.sendMessage(
          MessageBuilder.content('Aguarde a imagem ser processada...'));

      // Create a new Mip instance with the message content
      final mip = Mip(words: content.split(' '));
      await mip.mip(links[0], filename);

      // Send the processed image back to the Discord channel
      final files = [AttachmentBuilder.file(File(filename))];
      await event.message.channel.sendMessage(MessageBuilder.files(files));

      // Delete the processed image file to free up disk space
      File(filename).delete();
    }

    // Check if the message starts with the "&help" command
    if (content.startsWith('&help')) {
      // Create an embed message with the list of available commands
      final embed = EmbedBuilder(
        author: EmbedAuthorBuilder(
          iconUrl:
              'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
          name: 'MIP - Multithreading Image Processor V1.4',
        ),
        title: 'COMMANDS',
        description: commands,
        footer: EmbedFooterBuilder(
          iconUrl:
              'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
          text: 'For more information, Naive Bayes#9556',
        ),
      );

      // Send the embed message to the Discord channel
      await event.message.channel.sendMessage(MessageBuilder.embed(embed));
    }

    // Check if the message starts with the "&updates" command
    if (content.startsWith('&updates')) {
      // Create an embed message with the latest updates
      final embed = EmbedBuilder(
        author: EmbedAuthorBuilder(
          iconUrl:
              'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
          name: 'MIP - Multithreading Image Processor V1.4',
        ),
        title: 'UPDATES',
        description: updates,
        footer: EmbedFooterBuilder(
          iconUrl:
              'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
          text: 'For more information, Naive Bayes#9556',
        ),
      );

      // Send the embed message to the Discord channel
      await event.message.channel.sendMessage(MessageBuilder.embed(embed));
    }
  });

  bot.connect();
}
