import 'dart:io';
import 'package:multithreading_image_processor/black_and_white.dart';
import 'package:multithreading_image_processor/words_spliter.dart';

void main() {
  final Mip mip = Mip();
  final WordsSplitter wordsSplitter = WordsSplitter();
  // mip.mip();
  stdout.write("> ");
  String? read = stdin.readLineSync();
  wordsSplitter.split_words(read.toString());
}
