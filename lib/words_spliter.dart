import 'package:multithreading_image_processor/black_and_white.dart';

class WordsSplitter {
  List<String> splitWords(String words) {
    List<String> result = words.split(" ");
    if (result.contains("filtro") && result.contains("p&b")) {
      Mip mip = Mip();
      mip.mip();
    }
    return result;
  }
}
