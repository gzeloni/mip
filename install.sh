#!/bin/bash
mkdir mip/assets mip/lib/config
touch mip/lib/utils/text_list.dart mip/lib/config/config.dart
echo "List textList = ['put some words here',];String randomText(){var randomItem = (textList..shuffle()).first;return randomItem.toString();}" > mip/lib/utils/text_list.dart
echo "class Config{static const String _discordToken='your discord token here';static const String _giphyToken='your gif token here';static String getDiscordToken(){return _discordToken;}static String getGiphyToken(){return _giphyToken;}}" > mip/lib/config/config.dart
dart pub get -C mip
echo "EDIT THE FILES: [mip/lib/config/config.dart] AND [mip/lib/utils/text_list.dart]"
