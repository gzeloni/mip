import 'package:multithreading_image_processor/config/config.dart';
import 'package:multithreading_image_processor/data/urls_list.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List<dynamic>> getBartGifs(String searchTerm) async {
  String apiKey = Config.getGiphyToken();
  String url =
      'https://api.giphy.com/v1/gifs/search?q=$searchTerm&api_key=$apiKey&limit=10';

  await http.get(Uri.parse(url)).then((response) {
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> gifs = data['data'];
      for (var gif in gifs) {
        String gifUrl = gif['images']['original']['url'];
        gifUrls.add(gifUrl);
      }
    } else {
      print('Erro ao buscar gifs: ${response.statusCode}');
    }
  });

  return gifUrls;
}
