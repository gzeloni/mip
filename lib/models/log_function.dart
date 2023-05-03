import 'dart:io';

import 'package:nyxx/nyxx.dart';

Future<void> logError(dynamic e) async {
  final file = File('error.log');
  final sink = file.openWrite(mode: FileMode.append);
  sink.write('Error: ${DateTime.now().toString()}\n${e.toString()}\n\n');
  await sink.flush();
  await sink.close();
}

Future<void> sendEmbedMessageErrorHandler(
    Object e, IMessageReceivedEvent event, INyxxWebsocket bot) async {
  final owner = await bot.fetchUser(Snowflake(event.message.author.id));
  try {
    await owner.sendMessage(MessageBuilder.content(
        'Não tenho permissão de enviar mensagens no canal <#${event.message.channel.id}>'));
  } catch (e) {
    await logError(e);
  }
}
