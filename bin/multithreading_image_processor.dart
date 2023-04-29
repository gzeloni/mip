import 'dart:io';
// import 'package:multithreading_image_processor/black_and_white.dart';
import 'package:multithreading_image_processor/functions.dart';

void main() {
  stdout.write("> ");
  String? read = stdin.readLineSync();
  splitWords(read.toString());
}
