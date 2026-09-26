import 'package:path/path.dart' as p;

class WorkingFile {
  final String path;
  final String workingPath;
  final int? size;

  WorkingFile({required this.path, required this.workingPath, this.size});

  Map<String, dynamic> toMap() {
    return {'path': path, 'workingPath': workingPath, 'size': size};
  }

  factory WorkingFile.fromMap(Map<String, dynamic> map) {
    return WorkingFile(
      path: map['path'] ?? '',
      workingPath: map['workingPath'] ?? '',
      size: map['size'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    if (other is WorkingFile) {
      // If sizes are available, use name + size for equality to handle Android cache path changes
      if (size != null && other.size != null && size! > 0) {
        return p.basename(path) == p.basename(other.path) && size == other.size;
      }
      return other.path == path;
    }
    return false;
  }

  @override
  int get hashCode {
    if (size != null && size! > 0) {
      return p.basename(path).hashCode ^ size.hashCode;
    }
    return path.hashCode ^ workingPath.hashCode;
  }
}
