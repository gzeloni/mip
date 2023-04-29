import 'package:multithreading_image_processor/mip.dart';

class WordsSplitter {
  List<String> split_words(String words) {
    List<String> result = words.split(" ");
    if (result.contains("filtro") && result.contains("p&b")) {
      Mip mip = Mip();
      mip.mip();
    }
    return result;
  }
}
