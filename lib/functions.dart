import 'package:multithreading_image_processor/mip.dart';

List<String> splitWords(String words) {
  List<String> result = words.split(" ");
  if (result.contains('filter')) {
    final Mip mip = Mip(words: result);
    mip.mip();
  }
  return result;
}
