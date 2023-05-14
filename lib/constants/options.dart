// Set default options for processing
Map<String, bool> shouldApply = <String, bool>{
  'p&b': false,
  'inverted': false,
  'vignette': false,
  'billboard': false,
  'sepia': false,
  'bulge': false,
  'gaussian': false,
  'emboss': false,
  'sobel': false,
  'sketch': false,
  'chromatic': false,
};

// Initialize variables for vignette and bulge options
double? vignetteThickness;
int? centerX;
int? centerY;
int? gaussRadius;
int? shift;
double? radius;
