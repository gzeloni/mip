#!/bin/bash
mkdir assets/ lib/config/ errors/
touch lib/utils/text_list.dart lib/config/config.dart
echo "List textList = ['put some words here',];String randomText(){var randomItem = (textList..shuffle()).first;return randomItem.toString();}" > lib/utils/text_list.dart
echo "class Config{static const String _discordToken='your discord token here';static const String _giphyToken='your gif token here';static String getDiscordToken(){return _discordToken;}static String getGiphyToken(){return _giphyToken;}}" > lib/config/config.dart
dart pub get
echo "EDIT THE FILES: [mip/lib/config/config.dart] AND [mip/lib/utils/text_list.dart]"
