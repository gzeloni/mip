import 'dart:io';

import 'package:multithreading_image_processor/data/urls_list.dart';
import 'package:multithreading_image_processor/mip.dart';
import 'package:multithreading_image_processor/models/functions.dart';
import 'package:multithreading_image_processor/models/gifs.dart';
import 'package:multithreading_image_processor/models/log_function.dart';
import 'package:multithreading_image_processor/utils/commands_list.dart';
import 'package:nyxx/nyxx.dart';

class BotCommands {
  static void commands(INyxxWebsocket bot) {
    // Listener for when a message is received
    bot.eventsWs.onMessageReceived.listen((event) async {
      final content = event.message.content;
      final words = content.split(' ');
      String? attachmentImage;
      bool isGif = false;

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
        // Check if any of the links are GIFs
        for (final link in links) {
          if (link.contains('.gif')) {
            isGif = true;
            break;
          }
        }
        // If there's not exactly one link, send an error message and return
        if (links.length != 1) {
          try {
            await event.message.channel.sendMessage(MessageBuilder.content(
                'Por favor, insira apenas um link após o comando `&make`.'));
          } catch (e) {
            sendEmbedMessageErrorHandler(e, event, bot);
          }
          return;
        }

        // Generate a unique filename for the processed image
        final filename = ImageProcessing.fileName(isGif).toString();
        // Send a message indicating that the image is being processed
        try {
          await event.message.channel.sendMessage(
              MessageBuilder.content('Aguarde a imagem ser processada...'));
        } catch (e) {
          sendEmbedMessageErrorHandler(e, event, bot);
        }

        // Create a new Mip instance with the message content
        final mip = Mip(words: content.split(' '));
        await mip.mip(links[0], filename);

        // Send the processed image back to the Discord channel
        final files = [AttachmentBuilder.file(File(filename))];
        try {
          await event.message.channel.sendMessage(MessageBuilder.files(files));
        } catch (e) {
          sendEmbedMessageErrorHandler(e, event, bot);
        }

        // Delete the processed image file to free up disk space
        File(filename).delete();
      }

      // Check if the message starts with the "&help" command
      if (content.startsWith('&help') && content.length <= 7) {
        // Create an embed message with the list of available commands
        final embed = EmbedBuilder(
          author: EmbedAuthorBuilder(
            iconUrl:
                'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
            name: 'MIP - Multithreading Image Processor V1.5',
          ),
          title: 'COMMANDS',
          description: commandsList,
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
          sendEmbedMessageErrorHandler(e, event, bot);
        }
      }

      // Check if the message starts with the "&updates" command
      if (content.startsWith('&updates') && content.length <= 7) {
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
          sendEmbedMessageErrorHandler(e, event, bot);
        }
      }

      if (content.startsWith('&gif') && content.length >= 7) {
        // If there's not exactly one link, send an error message and return
        if (words.length < 2) {
          try {
            await event.message.channel.sendMessage(MessageBuilder.content(
                'Por favor, insira o termo da pesquisa após o comando " <gif " !'));
          } catch (e) {
            sendEmbedMessageErrorHandler(e, event, bot);
          }
          return;
        } else {
          try {
            String termos = words.sublist(1).join(' ');
            await getBartGifs(termos);
            var randomItem = (gifUrls..shuffle()).first;
            await event.message.channel
                .sendMessage(MessageBuilder.content(randomItem.toString()));
            gifUrls.clear();
          } catch (e) {
            sendEmbedMessageErrorHandler(e, event, bot);
          }
        }
      }
    });
  }
}
