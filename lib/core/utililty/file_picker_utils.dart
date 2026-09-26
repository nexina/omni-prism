import 'package:file_selector/file_selector.dart';

Future<XFile?> pickFile() async {
  return await openFile();
}
