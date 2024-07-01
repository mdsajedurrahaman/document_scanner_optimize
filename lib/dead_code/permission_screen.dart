import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../camera_screen/camera_screen.dart';

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> with WidgetsBindingObserver {

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  Future<void> _requestPermissions() async {
    var results = await [Permission.camera, Permission.microphone].request();
    var cameraResult = results[Permission.camera];
    var microphoneResult = results[Permission.microphone];
    if (cameraResult!.isGranted && microphoneResult!.isGranted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CameraScreen(),));
    }else if (cameraResult.isDenied || microphoneResult!.isDenied) {
      var results = await [Permission.camera, Permission.microphone].request();
      var cameraResult = results[Permission.camera];
      var microphoneResult = results[Permission.microphone];
      if (cameraResult!.isGranted && microphoneResult!.isGranted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => CameraScreen(),));
      }
      else if (cameraResult.isPermanentlyDenied || microphoneResult!.isPermanentlyDenied) {

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return StatefulBuilder(builder: (context, setState) {
              return AlertDialog(
                titleTextStyle: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                title: const Text(
                    'This feature requires camera and microphone permissions'),
                content: const Text(
                    'Open Settings> Permission and allow camera and microphone permissions'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Open Settings'),
                    onPressed: () {
                      openAppSettings();
                    },
                  ),
                  TextButton(
                    child: const Text('Not Now'),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ],
              );
            });
          },
        );
      }
      }else if (cameraResult.isPermanentlyDenied || microphoneResult.isPermanentlyDenied) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              titleTextStyle: const TextStyle(
                color: Colors.black,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              title: const Text(
                  'This feature requires camera and microphone permissions'),
              content: const Text(
                  'Open Settings> Permission and allow camera and microphone permissions'),
              actions: <Widget>[
                TextButton(
                  child: const Text('Open Settings'),
                  onPressed: () {
                    openAppSettings();
                  },
                ),
                TextButton(
                  child: const Text('Not Now'),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          });
        },
      );
    }

  }
  Future<bool> checkPermissions() async {
    var cameraStatus = await Permission.camera.status;
    var microphoneStatus = await Permission.microphone.status;

    if (cameraStatus.isGranted && microphoneStatus.isGranted) {
      return true;
    }
    return false;
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      checkPermissions();
    }
  }
}
