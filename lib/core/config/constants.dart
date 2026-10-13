/// Application-wide constants
class AppConstants {
  // URLs
  static const String projectUrl = 'https://github.com/nexina/omni-prism';
  static const String facebookUrl = 'https://www.facebook.com/nexina.fb/';
  static const String omniUrl = 'https://nexina.github.io/omni';

  // Image viewer settings
  static const int imageCacheSize = 10;
  static const int thumbnailWidth = 50;
  static const int thumbnailHeight = 50;

  // Window settings
  static const double defaultWindowWidth = 800;
  static const double defaultWindowHeight = 600;

  // Animation durations
  static const int fadeAnimationDuration = 500;
  static const int hoverAnimationDuration = 200;
  static const int pageTransitionDuration = 500;
  static const int scrollAnimationDuration = 150;

  // UI dimensions
  static const double topBarHeight = 50.0;
  static const double navButtonWidth = 60.0;
  static const double navButtonHeight = 250.0;
  static const double overviewItemWidth = 50.0;
  static const double paddingSmall = 4.0;
  static const double paddingMedium = 8.0;
  static const double paddingLarge = 12.0;
  static const double paddingXLarge = 18.0;
  static const double largeIconSize = 30.0;
  static const double aboutIconSize = 200.0;

  // Zoom settings
  static const double minScale = 0.1;
  static const double maxScale = 4.0;
  static const double doubleTapZoomFactor = 3.0;
  static const double minScaleFactor = 0.1;

  // Colors
  static const int backgroundColorARGB = 0xFF1C1C1C;
  static const int topBarBackgroundARGB = 0xCC0C0C0C;
  static const int buttonBackgroundARGB = 0xFF333333;
  static const int overviewBackgroundARGB = 0xFF414141;
  static const int errorBackgroundARGB = 0xFF000000;
  static const int errorTextColorARGB = 0xFFFF0000;

  // Supported image extensions (with dot prefix)
  static const List<String> supportedImageExtensions = [
    '.jpg',
    '.png',
    '.jpeg',
    '.gif',
    '.webp',
    '.bmp',
    '.tiff',
    '.svg',
    '.eps',
    '.raw',
    '.cr2',
    '.nef',
    '.orf',
    '.sr2',
    '.pef',
    '.dng',
    '.x3f',
    '.arw',
    '.rw2',
    '.rwl',
    '.tif',
    '.heic',
    '.indd',
    '.ai',
    '.psd',
    '.svgz',
    '.pdf',
    '.pct',
    '.wmf',
    '.emf',
    '.ico',
    '.icon',
  ];

  // Asset paths
  static const String appIconPath = 'assets/icons/omni_prism_ic.png';
  static const String companyIconPath = 'assets/icons/nexina_white.png';
  static const String defaultBackgroundPath = 'assets/images/default.jpg';

  // Fonts
  static const String fontFamily = 'Inria Sans';

  // App info
  static const String appName = 'Omni Prism';
  static const String appVersion = '1.0.1';
}