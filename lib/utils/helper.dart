import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

class AppHelper{
  Future<void> createDirectories() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final Directory docScannerDirectory= Directory('${appDirectory.path}/Doc Scanner');
    if (!await docScannerDirectory.exists()) {
      await docScannerDirectory.create(recursive: true);
    }
    final Directory documentDirectory = Directory('${docScannerDirectory.path}/Document');
    if (!await documentDirectory.exists()) {
      await documentDirectory.create(recursive: true);
    }
    final Directory idCardDirectory = Directory('${docScannerDirectory.path}/ID Card');
    if (!await idCardDirectory.exists()) {
      await idCardDirectory.create(recursive: true);
    }
    final Directory qrCodeDirectory = Directory('${docScannerDirectory.path}/QR Code');
    if (!await qrCodeDirectory.exists()) {
      await qrCodeDirectory.create(recursive: true);
    }
    final Directory barCodeDirectory = Directory('${docScannerDirectory.path}/Bar Code');
    if (!await barCodeDirectory.exists()) {
      await barCodeDirectory.create(recursive: true);
    }
  }

  Future<File> convertUint8ListToFile(
      {required Uint8List data, String? extension}) async {
    Directory tempDir = await getTemporaryDirectory();
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    if (extension != null) {
      fileName = '$fileName.$extension';
    }
    String tempPath = '${tempDir.path}/$fileName';
    File file = File(tempPath);
    return await file.writeAsBytes(data);
  }
}