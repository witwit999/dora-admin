import 'dart:io';

import 'package:file_picker/file_picker.dart';

/// Picks an image file from the local file system (desktop-friendly).
///
/// Returns a [File] when the user selects a file, otherwise `null`.
Future<File?> pickImageFileFromSystem() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: false,
  );

  final path = result?.files.single.path;
  if (path == null || path.isEmpty) return null;

  return File(path);
}

