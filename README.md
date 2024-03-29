# Multithreading Image Processor - MIP

#### Multithreading Image Processor (MIP) is a project aimed at developing a fast and highly customizable image processing system using the Dart programming language's [dart:io](https://api.dart.dev/stable/2.19.6/dart-io/dart-io-library.html), [dart:isolate](https://api.dart.dev/stable/2.19.6/dart-isolate/dart-isolate-library.html), and [image](https://pub.dev/packages/image) package, as well as the [nyxx](https://pub.dev/packages/nyxx) package for Discord bots.

## Output examples:

| Without filter | P&B filter | Inverted filter |
|---|---|---|
| ![Image](output_examples/sem_filtro.jpeg) | ![Image](output_examples/p_b.png) | ![Image](output_examples/inverted.png) |

| Billboard filter | Sepia filter | Bulge filter |
|---|---|---|
| ![Image](output_examples/billboard.png) | ![Image](output_examples/sepia.png) | ![Image](output_examples/bulge.png) |

| Vignette filter | Gaussian filter | Emboss filter |
|---|---|---|
| ![Image](output_examples/vignette.png) | ![Image](output_examples/gaussian.png) | ![Image](output_examples/emboss.png) |

| Sobel filter |
|---|
| ![Image](output_examples/sobel.png) |

#### You can combine the filters and use flags, such as: "&make bulge -x 20 -y 30 -radius 160 image \<link here\>"

## GIF Support
#### In update 1.6, support for processing GIFs was added.
#### The "&gif" command was also added, which makes it possible to search for GIFs, using the GIPHY API.

## The goal
#### The goal of this project is to provide a bot-based interface for users to submit image processing requests, which are then completed and returned with the specified filters applied.

## Commands
#### The command system for MIP is highly versatile, with new options and flags being added regularly. Some of the current available commands include:
    &make <link> parameters (the link can be added anywhere in the command)
    p&b: Apply a black and white filter to the image
    inverted: Apply an inverted color filter to the image
    billboard: Apply a billboard (the image is made up of dots) filter to the image
    sepia: Apply a sepia (shades of yellow) filter to the image
    bulge: Apply a bulge effect to the image (try it, it's funny!)
    vignette: Apply a vignette to the image (you can add a custom value, like "with vignette 0.8")
    gaussian: Apply a blur effect to the image [-blur]
    emboss: Apply a emboss convolution filter to the given image
    sobel: Apply a sobel edge detection filter to the given image
    gif: performs a search for 10 gifs according to the search term, stores it in a list and returns a random GIF from the list.

#### Flags
##### Bulge command:
    x sets the X position of the distortion to be generated in the image.
    y sets the Y position of the distortion to be generated in the image.
    radius sets the size of the radius of the distortion to be generated in the image.
    "&make bulge -x 10 -y -4 -radius 160 <link>"

##### Vignette command:
    If you write vignette with a (-), you'll be able to control the weight of the vignette.
    "&make -vignette 1.4 <link>"

##### Gaussian command:
    The gaussian filter has the flag "-blur" to control the blur of the filter.
    "&make gaussian -blur 6 <link>"
    
## How to run?
#### To run this program, you need a discord API and a GIPHY API.
First, run the `install.sh`
Then edit the file named `config.dart` inside the `lib/config/` folder:
```dart
class Config {
  static const String _discordToken =
      "<TOKEN>";

  static const String _giphyToken = '<TOKEN>';

  static String getDiscordToken() {
    return _discordToken;
  }

  static String getGiphyToken() {
    return _giphyToken;
  }
}
```

#### And finally, edit the file in `lib/utils/` with the name `text_list.dart`: 
```dart
List textList = [
  'Put some answers inside this list',
  'These are the responses',
  'for when someone tags the bot',
  'and types something after the @',
  'example: "@MIP I hate you"',
];

String randomText() {
  var randomItem = (textList..shuffle()).first;
  return randomItem.toString();
}
```

## Does it work with Flutter?
#### While MIP is not currently compatible with Flutter, it is part of the project's future plans to make it possible to use via the NetworkImage object and Image.network() widget.
