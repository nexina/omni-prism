/// File type definitions and extension lists for the application.
/// Extensions are stored without the leading dot (e.g., 'jpg' not '.jpg').
class FileTypes {
  // Private constructor to prevent instantiation
  FileTypes._();

  // Document extensions
  static const List<String> documents = [
    'pdf',
    'docx',
    'xlsx',
    'pptx',
    // 'doc',
    // 'odt',
    // 'rtf',
    // 'xls',
    // 'ppt',
  ];

  // Image extensions
  static const List<String> images = [
    'jpg',
    'jpeg',
    'png',
    'gif',
    'webp',
    'bmp',
    'wbmp',
    'svg',
    'heic',
    'ico',
    'tif',
    'tiff',
    'raw',
    'cr2',
    'nef',
    'orf',
    'sr2',
    'pef',
    'dng',
    'x3f',
    'arw',
    'rw2',
    'rwl',
    'eps',
    'svgz',
    'psd',
    'ai',
    'indd',
    'pdf',
    'pct',
    'wmf',
    'emf',
  ];

  // Video extensions
  static const List<String> videos = [
    'avi',
    'flv',
    'mkv',
    'mov',
    'mp4',
    'mpg',
    'mpeg',
    '3gp',
    'webm',
    'wmv',
    'm4v',
    'vob',
    'ts',
  ];

  // Audio extensions
  static const List<String> audios = [
    'mp3',
    'wav',
    'flac',
    'ogg',
    'wma',
    'aiff',
    'aac',
    'mka',
    'ac3',
    'mid',
    'midi',
    'm4a',
    // 'amr',
    // 'dts',
    // 'ra',
  ];

  // Archive extensions
  static const List<String> archives = [
    'zip',
    'cbz',
    'tar',
    'gz',
    'tgz',
    'tar.gz',
    'bz2',
    'tbz',
    'tbz2',
    'tar.bz2',
    'xz',
    'txz',
    'tar.xz',
    // '7z',
    // 'rar',
    // 'iso',
    // 'dmg',
    // 'pkg',
  ];

  // Text/Code extensions
  static const List<String> texts = [
    'c',
    'cpp',
    'cs',
    'java',
    'js',
    'ts',
    'py',
    'rb',
    'php',
    'html',
    'css',
    'dart',
    'go',
    'rs',
    'swift',
    'kt',
    'm',
    'sh',
    'xml',
    'json',
    'yaml',
    'yml',
    'ini',
    'cfg',
    'log',
    'tex',
    'txt',
    'md',
    'rst',
    'adoc',
    'asciidoc',
    'markdown',
    'mkdn',
    'mkd',
    'mdown',
  ];

  /// All supported extensions combined
  static List<String> get all => [
        ...documents,
        ...images,
        ...videos,
        ...audios,
        ...archives,
        ...texts,
      ];

  /// Check if an extension is an image type
  static bool isImage(String extension) => images.contains(extension.toLowerCase());

  /// Check if an extension is a video type
  static bool isVideo(String extension) => videos.contains(extension.toLowerCase());

  /// Check if an extension is an audio type
  static bool isAudio(String extension) => audios.contains(extension.toLowerCase());

  /// Check if an extension is a document type
  static bool isDocument(String extension) => documents.contains(extension.toLowerCase());

  /// Check if an extension is an archive type
  static bool isArchive(String extension) => archives.contains(extension.toLowerCase());

  /// Check if an extension is a text/code type
  static bool isText(String extension) => texts.contains(extension.toLowerCase());

  /// Get the file type category for an extension
  static String getFileType(String extension) {
    final ext = extension.toLowerCase();
    if (isDocument(ext)) return 'Document';
    if (isImage(ext)) return 'Image';
    if (isVideo(ext)) return 'Video';
    if (isAudio(ext)) return 'Audio';
    if (isArchive(ext)) return 'Archive';
    if (isText(ext)) return 'Text';
    return 'Other';
  }

  /// Get color associated with file type
  static int getFileTypeColor(String extension) {
    switch (getFileType(extension)) {
      case 'Document':
        return 0xFF4A90E2;
      case 'Image':
        return 0xFF50E3C2;
      case 'Video':
        return 0xFFFF5A5F;
      case 'Audio':
        return 0xFFFFC300;
      case 'Archive':
        return 0xFF9013FE;
      default:
        return 0xFF9B9B9B;
    }
  }
}