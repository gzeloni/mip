String commandsList = '''
&make <link> parameters (the link can be added anywhere in the command)\n
p&b: Apply a black and white filter to the image\n
inverted: Apply a inverted color filter to the image\n
billboard: Apply a billboard (the image is made up of dots) filter to the image\n
sepia: Apply a sepia (shades of yellow) filter to the image\n
bulge: Apply a bulge effect to the image [-x, -y, -radius]\n
vignette: Apply a vignette to the image (for custom values, use a hyphen "&make -vignette 1.3")\n
gaussian: Apply a blur effect to the image [-blur]\n
emboss: Apply a emboss convolution filter to the given image\n
sobel: Apply a sobel edge detection filter to the given image.''';

String updates = '''
Multithreading Image Processor version 1.7 released!
Offensive words blocked on "&gif" command
''';
