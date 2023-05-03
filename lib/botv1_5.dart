import 'dart:io';
import 'package:multithreading_image_processor/config/config.dart';
import 'package:multithreading_image_processor/functions.dart';
import 'package:multithreading_image_processor/mip.dart';
import 'package:multithreading_image_processor/models/log_function.dart';
import 'package:multithreading_image_processor/utils/commands_list.dart';
import 'package:multithreading_image_processor/utils/text_list.dart';
import "package:nyxx/nyxx.dart";

void botv1_5() {
  // Create Nyxx bot instance with necessary intents
  final bot = NyxxFactory.createNyxxWebsocket(
      Config.getToken(),
      GatewayIntents.allUnprivileged |
          GatewayIntents.allPrivileged |
          GatewayIntents.messageContent)
    ..registerPlugin(Logging());

  // Listener for when the bot is ready
  bot.eventsWs.onReady.listen((event) {
    print("Ready!");
  });

  // Listener for when a message is received
  bot.eventsWs.onMessageReceived.listen((event) async {
    final content = event.message.content;
    String? attachmentImage;

    if (event.message.author.bot) {
      // Ignore messages sent by bots
      return;
    }

    // Check if the message starts with the "&make" command
    if (content.startsWith('&make') && content.length >= 7) {
      for (var a in event.message.attachments) {
        attachmentImage = a.url;
      }
      // Extract image links from the message content
      final links = content
          .split(' ')
          .where((element) =>
              element.contains('http://') || element.contains('https://'))
          .toList();

      // Check if there are no links and if there is a non-null attachment
      if (links.isEmpty && attachmentImage != null) {
        links.add(attachmentImage);
      }
      // If there's not exactly one link, send an error message and return
      if (links.length != 1) {
        try {
          await event.message.channel.sendMessage(MessageBuilder.content(
              'Por favor, insira apenas um link após o comando `&make`.'));
        } catch (e) {
          await logError(e);
        }
        return;
      }

      // Generate a unique filename for the processed image
      final filename = ImageProcessing.fileName().toString();
      // Send a message indicating that the image is being processed
      try {
        await event.message.channel.sendMessage(
            MessageBuilder.content('Aguarde a imagem ser processada...'));
      } catch (e) {
        await logError(e);
      }

      // Create a new Mip instance with the message content
      final mip = Mip(words: content.split(' '));
      await mip.mip(links[0], filename);

      // Send the processed image back to the Discord channel
      final files = [AttachmentBuilder.file(File(filename))];
      try {
        await event.message.channel.sendMessage(MessageBuilder.files(files));
      } catch (e) {
        await logError(e);
      }

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
          name: 'MIP - Multithreading Image Processor V1.5',
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
      try {
        await event.message.channel.sendMessage(MessageBuilder.embed(embed));
      } catch (e) {
        // send DM to the bot owner if the embed message fails to send
        final owner = await bot.fetchUser(Snowflake(event.message.author.id));
        // try send DM, if it fails, print the error
        try {
          await owner.sendMessage(MessageBuilder.content(
              'Não tenho permissão de enviar mensagens no canal <#${event.message.channel.id}>'));
        } catch (e) {
          await logError(e);
        }
      }
    }

    // Check if the message starts with the "&updates" command
    if (content.startsWith('&updates')) {
      // Create an embed message with the latest updates
      final embed = EmbedBuilder(
        author: EmbedAuthorBuilder(
          iconUrl:
              'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
          name: 'MIP - Multithreading Image Processor V1.5',
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
      try {
        await event.message.channel.sendMessage(MessageBuilder.embed(embed));
      } catch (e) {
        await logError(e);
      }
    }
  });

  bot.eventsWs.onSelfMention.listen((event) async {
    final content = event.message.content;
    if (content.startsWith('<') && content.length == 21) {
      try {
        await event.message.channel.sendMessage(
            MessageBuilder.content("Digite &help para ver meus comandos"));
      } catch (e) {
        await logError(e);
      }
    } else {
      try {
        await event.message.channel
            .sendMessage(MessageBuilder.content(randomText()));
      } catch (e) {
        await logError(e);
      }
    }
  });

  bot.connect();
}
