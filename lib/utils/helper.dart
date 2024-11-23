import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class AppHelper {
  Future<void> createDirectories() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final Directory docScannerDirectory =
        Directory('${appDirectory.path}/Doc Scanner');
    if (!await docScannerDirectory.exists()) {
      await docScannerDirectory.create(recursive: true);
    }
    final Directory documentDirectory =
        Directory('${docScannerDirectory.path}/Document');
    if (!await documentDirectory.exists()) {
      await documentDirectory.create(recursive: true);
    }
    final Directory idCardDirectory =
        Directory('${docScannerDirectory.path}/ID Card');
    if (!await idCardDirectory.exists()) {
      await idCardDirectory.create(recursive: true);
    }
    final Directory qrCodeDirectory =
        Directory('${docScannerDirectory.path}/QR Code');
    if (!await qrCodeDirectory.exists()) {
      await qrCodeDirectory.create(recursive: true);
    }
    final Directory barCodeDirectory =
        Directory('${docScannerDirectory.path}/Bar Code');
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

  static Future<bool> handlePermissions() async {
    bool permission = false;
    try {
      await _requestCameraPermission().then((cameraPermission) async {
        permission = cameraPermission;
        await _requestGalleryPermission().then((galleryPermission) {
          permission = galleryPermission;
        });
      });
    } catch (e) {
      log(e.toString());
    }
    return permission;
  }

  static Future<bool> _requestCameraPermission() async {
    PermissionStatus status = await Permission.camera.request();

    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }

  static Future<bool> _requestGalleryPermission() async {
    bool permission = false;
    if (Platform.isAndroid) {
      AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;

      if (build.version.sdkInt >= 34) {
        await Permission.photos.request().then((status) async {
          if (status.isGranted) {
            permission = true;
          } else if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
        });
      }
      /*
      * <!-- Devices running Android 13 (API level 33) or higher -->
      * */
      else if (build.version.sdkInt >= 33) {
        await Permission.photos.request().then((status) async {
          if (status.isGranted) {
            permission = true;
          } else if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
        });
      }
      /*
    * Devices running Android 12L (API level 32) or lower
    * -------But using Permission handler--------------
    * Devices running Android 12L (API level 32) or lower
    * - Below Android 13 (API 33), the `READ_EXTERNAL_STORAGE` and
    * `WRITE_EXTERNAL_STORAGE` permissions are requested (depending on the
    *  definitions in the AndroidManifest.xml) file.
    *
    * */
      else {
        await Permission.storage.request().then((status) async {
          if (status.isGranted) {
            permission = true;
          } else if (status.isPermanentlyDenied) {
            await openAppSettings();
          }
        });
      }
      return permission;
    } else if (Platform.isIOS) {
      await Permission.photos.request().then((status) async {
        if (status.isGranted) {
          permission = true;
        } else if (status.isPermanentlyDenied) {
          await openAppSettings();
        }
      });
    }
    return permission;
  }
}
