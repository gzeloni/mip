import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:multithreading_image_processor/constants/offensive_words_28_languages/all_offensive_words_list.dart';
import 'package:multithreading_image_processor/data/urls_list.dart';
import 'package:multithreading_image_processor/mip.dart';
import 'package:multithreading_image_processor/models/filters.dart';
import 'package:multithreading_image_processor/models/get_offensive_terms.dart';
import 'package:multithreading_image_processor/models/gifs.dart';
import 'package:multithreading_image_processor/models/log_function.dart';
import 'package:multithreading_image_processor/utils/commands_list.dart';
import 'package:multithreading_image_processor/utils/text_list.dart';
import 'package:nyxx/nyxx.dart';

class BotCommands {
  static void commands(INyxxWebsocket bot) {
    // Listener for when a message is received
    bot.eventsWs.onMessageReceived.listen(
      (event) async {
        final content = event.message.content;
        final words = content.split(' ');
        String? attachmentImage;
        bool isGif = false;
        bool linkIsValid = false;
        Trie trie = Trie();

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
              sendEmbedMessageErrorHandler(e, event, bot);
            }
            return;
          }

          for (final link in links) {
            // Check if any of the links are GIFs
            if (link.contains('.gif')) {
              isGif = true;
            }
            // Check if the link is valid
            try {
              final response = await http
                  .head(Uri.parse(link)); // Send a HEAD request to the link
              if (response.statusCode == HttpStatus.ok) {
                // Check if the response status code is OK (200)
                final contentType = response.headers[
                    'content-type']; // Get the content-type header from the response
                final mimeType =
                    lookupMimeType(link); // Get the MIME type from the link
                if (mimeType?.startsWith('image/') == true ||
                    contentType?.startsWith('image/') == true) {
                  // Check if the link is an image
                  linkIsValid = true;
                } else {
                  await event.message.channel.sendMessage(
                      MessageBuilder.content(
                          'O link inserido não contém uma imagem!'));
                }
              } else {
                return; // Invalid response status code
              }
            } catch (e) {
              await event.message.channel.sendMessage(
                  MessageBuilder.content('O link inserido não é válido.'));
            }
          }

          if (linkIsValid) {
            // Process the image
            final filename = ImageProcessing.getFileName(isGif).toString();
            try {
              await event.message.channel.sendMessage(MessageBuilder.content(
                  'Por favor aguarde enquanto a imagem é processada...'));
            } catch (e) {
              sendEmbedMessageErrorHandler(e, event, bot);
            }

            final mip = MultithreadingImageProcessor(words: words);
            await mip.mip(links[0], filename);

            final files = [AttachmentBuilder.file(File(filename))];
            try {
              await event.message.channel
                  .sendMessage(MessageBuilder.files(files));
            } catch (e) {
              sendEmbedMessageErrorHandler(e, event, bot);
            }

            File(filename).delete();
          } else {
            return;
          }
        }

        if (content.startsWith('&help') && content.length <= 7) {
          // Respond with a help message
          final embed = EmbedBuilder(
            author: EmbedAuthorBuilder(
              iconUrl:
                  'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
              name: 'MIP - Multithreading Image Processor V1.8',
            ),
            title: '- COMMANDS -',
            description: commandsList,
            footer: EmbedFooterBuilder(
              iconUrl:
                  'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
              text: 'For more information, Naive Bayes#9556',
            ),
          );

          try {
            await event.message.channel
                .sendMessage(MessageBuilder.embed(embed));
          } catch (e) {
            sendEmbedMessageErrorHandler(e, event, bot);
          }
        }

        if (content.startsWith('&updates') && content.length <= 9) {
          // Respond with an updates message
          final embed = EmbedBuilder(
            author: EmbedAuthorBuilder(
              iconUrl:
                  'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
              name: 'MIP - Multithreading Image Processor V1.8',
            ),
            title: '- UPDATES -',
            description: updates,
            footer: EmbedFooterBuilder(
              iconUrl:
                  'https://cdn.discordapp.com/app-icons/998373616691449996/eabdfb3b287b8c69b38d1d399884b54e.png?size=32',
              text: 'For more information, Naive Bayes#9556',
            ),
          );

          try {
            await event.message.channel
                .sendMessage(MessageBuilder.embed(embed));
          } catch (e) {
            sendEmbedMessageErrorHandler(e, event, bot);
          }
        }

        if (content.startsWith('&gif') && content.length >= 7) {
          for (final list in allOffensiveWords) {
            for (final word in list) {
              trie.insert(word);
            }
          }

          List<String> offensiveWords = verifyOffensiveWords(words, trie);

          if (offensiveWords.isNotEmpty) {
            // Check if there are any offensive words
            try {
              await event.message.channel.sendMessage(MessageBuilder.content(
                  'Você não pode pesquisar usando esses termos!'));
            } catch (e) {
              sendEmbedMessageErrorHandler(e, event, bot);
            }
            return;
          } else {
            if (words.length < 2) {
              // Check if there is a search term after the command
              try {
                await event.message.channel.sendMessage(MessageBuilder.content(
                    'Por favor, insira o termo da pesquisa após o comando " <gif " !'));
              } catch (e) {
                sendEmbedMessageErrorHandler(e, event, bot);
              }
              return;
            } else {
              // Get gifs and send a random one
              try {
                String terms = words.sublist(1).join('-');
                await getGifs(terms);
                var randomItem = (gifUrls..shuffle()).first;
                await event.message.channel
                    .sendMessage(MessageBuilder.content(randomItem.toString()));
                gifUrls.clear();
              } catch (e) {
                sendEmbedMessageErrorHandler(e, event, bot);
              }
            }
          }
        }

        if (content.startsWith('&ping') && content.length <= 7) {
          // Respond with a pong message
          try {
            await event.message.channel
                .sendMessage(MessageBuilder.content('Pong!'));
          } catch (e) {
            sendEmbedMessageErrorHandler(e, event, bot);
          }
        }
      },
    );

    bot.eventsWs.onSelfMention.listen(
      (event) async {
        final content = event.message.content;
        if (content.startsWith('<') && content.length == 21) {
          // Respond with a help message when the bot is mentioned
          try {
            await event.message.channel.sendMessage(
                MessageBuilder.content("Digite &help para ver meus comandos"));
          } catch (e) {
            sendEmbedMessageErrorHandler(e, event, bot);
          }
        } else {
          // Respond with a random text message
          try {
            await event.message.channel
                .sendMessage(MessageBuilder.content(randomText()));
          } catch (e) {
            sendEmbedMessageErrorHandler(e, event, bot);
          }
        }
      },
    );
  }
}
