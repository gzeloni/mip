import 'package:multithreading_image_processor/config/config.dart';
import 'package:multithreading_image_processor/models/bot_commands/commands.dart';
import 'package:multithreading_image_processor/models/log_function.dart';
import 'package:multithreading_image_processor/utils/text_list.dart';
import "package:nyxx/nyxx.dart";

void botv1_6() {
  // Create Nyxx bot instance with necessary intents
  final bot = NyxxFactory.createNyxxWebsocket(
      Config.getDiscordToken(),
      GatewayIntents.allUnprivileged |
          GatewayIntents.allPrivileged |
          GatewayIntents.messageContent)
    ..registerPlugin(Logging());

  // Listener for when the bot is ready
  bot.eventsWs.onReady.listen((event) {
    print("Ready!");
  });

  BotCommands.commands(bot);

  bot.eventsWs.onSelfMention.listen((event) async {
    final content = event.message.content;
    if (content.startsWith('<') && content.length == 21) {
      try {
        await event.message.channel.sendMessage(
            MessageBuilder.content("Digite &help para ver meus comandos"));
      } catch (e) {
        sendEmbedMessageErrorHandler(e, event, bot);
      }
    } else {
      try {
        await event.message.channel
            .sendMessage(MessageBuilder.content(randomText()));
      } catch (e) {
        sendEmbedMessageErrorHandler(e, event, bot);
      }
    }
  });

  bot.connect();
}
