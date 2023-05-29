import 'package:multithreading_image_processor/config/config.dart';
import 'package:multithreading_image_processor/models/bot_commands/commands.dart';
import "package:nyxx/nyxx.dart";

void botv1_8() {
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

  bot.connect();
}
