import 'dart:io';
import 'package:nyxx/nyxx.dart';

// Function to log errors to a file
Future<void> logError(dynamic e, String filename) async {
  final file = File(filename);
  final sink = file.openWrite(mode: FileMode.append);
  sink.write('Error: ${DateTime.now().toString()}\n${e.toString()}\n\n');
  await sink.flush();
  await sink.close();
}

// Function to handle and send error messages as an embed
Future<void> sendEmbedMessageErrorHandler(
    Object e, IMessageReceivedEvent event, INyxxWebsocket bot) async {
  // Fetch the owner of the bot
  final owner = await bot.fetchUser(Snowflake(event.message.author.id));

  try {
    // Send an error message to the bot owner
    await owner.sendMessage(MessageBuilder.content(
        'Não tenho permissão de enviar mensagens no canal <#${event.message.channel.id}>'));
  } catch (e) {
    // If sending the error message fails, log the error to a file
    await logError(e, 'errors/discord_errors.log');
  }
}
