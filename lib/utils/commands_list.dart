String commands = '''
&make <link> parameters (the link can be added anywhere in the command)\n
p&b: Apply a black and white filter to the image\n
inverted: Apply a inverted color filter to the image\n
billboard: Apply a billboard (the image is made up of dots) filter to the image\n
sepia: Apply a sepia (shades of yellow) filter to the image\n
bulge: Apply a bulge effect to the image [-x, -y, -radius]\n
vignette: Apply a vignette to the image (for custom values, use a hyphen "&make -vignette 1.3")\n
gaussian: Apply a blur effect to the image [-blur]\n
emboss: Apply a emboss convolution filter to the given image''';

String updates = '''
Now the "bulge" command has three options to manipulate the distortion shape. They are: x, y, and radius.\n
Two new commands!\nType "gaussian" to make a blur in the image or "emboss" to make a emboss convolution.
The "gaussian" command has one option to manipulate the blur. Type -blur <value> after "gaussian".\n
To use these new commands, it's necessary to add a hyphen before the option, for example: 
"&make bulge -x 10 -y 100 -radius 50 <image link>"
"&make gaussian -blur 10 <image link>"\n
These options will be extended to the other commands in the upcoming updates.
''';
