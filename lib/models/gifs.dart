import 'package:multithreading_image_processor/config/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:multithreading_image_processor/data/urls_list.dart';

// Function to fetch GIFs from the Giphy API
Future<List<dynamic>> getGifs(String searchTerm) async {
  String apiKey = Config.getGiphyToken();
  String url =
      'https://api.giphy.com/v1/gifs/search?q=$searchTerm&api_key=$apiKey&limit=10';
  try {
    var response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      // Decode the response body
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> gifs = data['data'];

      // Extract the GIF URLs from the response and add them to the list
      for (var gif in gifs) {
        String gifUrl = gif['images']['original']['url'];
        gifUrls.add(gifUrl);
      }
    } else {
      print('Error fetching GIFs: ${response.statusCode}');
    }
  } catch (e) {
    print('Error fetching GIFs: $e');
  }

  return gifUrls;
}
