import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';

Future<void> saveFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  await FilePicker.saveFile(
    dialogTitle: 'Simpan File',
    fileName: fileName,
    bytes: bytes,
  );
}
