import 'dart:io';

// Get the list of all the images in the folder
Future<List<FileSystemEntity>> getImageFiles(String path) async {
  final imageDirectory = Directory(path);
  final imageFiles = imageDirectory.listSync();
  return imageFiles;
}

// Get the image folder path
String getImagePath(String path) {
  return path.split('\\').sublist(0, path.split('\\').length - 1).join('\\');
}
