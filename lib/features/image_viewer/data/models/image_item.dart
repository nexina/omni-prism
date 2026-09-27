/// Data model representing an image item in the viewer
class ImageItem {
  /// The file path of the image
  String path;

  /// The display title (usually the file name)
  String title;

  /// Formatted creation/modification time
  String creationTime;

  /// File size in bytes (optional)
  int? size;

  /// Constructor
  ImageItem({
    this.path = '',
    this.title = '',
    this.creationTime = '',
    this.size,
  });

  /// Creates an ImageItem from a file
  factory ImageItem.fromFile(String filePath, {DateTime? modified, int? size}) {
    final fileName = filePath.split(RegExp(r'[\\/]')).last;
    final dateTime = modified ?? DateTime.now();
    final formattedTime = _formatDateTime(dateTime);

    return ImageItem(
      path: filePath,
      title: fileName,
      creationTime: formattedTime,
      size: size,
    );
  }

  /// Creates a copy of this ImageItem with optional field updates
  ImageItem copyWith({
    String? path,
    String? title,
    String? creationTime,
    int? size,
  }) {
    return ImageItem(
      path: path ?? this.path,
      title: title ?? this.title,
      creationTime: creationTime ?? this.creationTime,
      size: size ?? this.size,
    );
  }

  /// Converts to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'path': path,
      'title': title,
      'creationTime': creationTime,
      'size': size,
    };
  }

  /// Creates an ImageItem from a map
  factory ImageItem.fromMap(Map<String, dynamic> map) {
    return ImageItem(
      path: map['path'] ?? '',
      title: map['title'] ?? '',
      creationTime: map['creationTime'] ?? '',
      size: map['size'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ImageItem && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;

  @override
  String toString() => 'ImageItem(path: $path, title: $title, creationTime: $creationTime)';

  /// Formats DateTime as "DD MMM YYYY, HH:MM AM/PM"
  static String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final month = months[dateTime.month - 1];
    final hour = dateTime.hour > 12 ? dateTime.hour - 12 : (dateTime.hour == 0 ? 12 : dateTime.hour);
    final minute = dateTime.minute.toString().padLeft(2, '0');
    final period = dateTime.hour >= 12 ? 'PM' : 'AM';
    return '${dateTime.day} $month ${dateTime.year}, $hour:$minute $period';
  }
}