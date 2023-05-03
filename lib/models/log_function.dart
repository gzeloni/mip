import 'dart:io';

Future<void> logError(dynamic e) async {
  final file = File('error.log');
  final sink = file.openWrite(mode: FileMode.append);
  sink.write('Error: ${DateTime.now().toString()}\n${e.toString()}\n');
  await sink.flush();
  await sink.close();
}
