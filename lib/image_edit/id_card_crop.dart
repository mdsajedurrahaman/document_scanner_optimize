import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_editor/image_editor.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';
import '../utils/app_color.dart';

class ImageCropping extends StatefulWidget {
  final int index;
  final File imageFile;

  const ImageCropping(
      {super.key, required this.imageFile, required this.index});

  @override
  State<ImageCropping> createState() => _ImageCroppingState();
}

class _ImageCroppingState extends State<ImageCropping> {
  final GlobalKey<ExtendedImageEditorState> _controller =
      GlobalKey<ExtendedImageEditorState>();

  @override
  Widget build(BuildContext context) {
    final cameraPageProvider = context.watch<CameraProvider>();
    return Scaffold(
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        width: MediaQuery.of(context).size.width,
        color: Colors.white,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: CupertinoButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.close,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      translation(context).cancel,
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),
            const VerticalDivider(thickness: 2),
            Expanded(
              flex: 1,
              child: CupertinoButton(
                onPressed: () async {
                  var state = _controller.currentState;
                  if (state == null || state.getCropRect() == null) {
                    Navigator.pop(context);
                  } else {
                    final Uint8List img = state.rawImageData;
                    Rect cropRect = state.getCropRect()!;
                    final ImageEditorOption option = ImageEditorOption();
                    option.addOption(ClipOption.fromRect(cropRect));
                    final Uint8List? cropImage = await ImageEditor.editImage(
                      image: img,
                      imageEditorOption: option,
                    );

                    var random = Random();
                    int randomNumber = 1000 + random.nextInt(90000);
                    Directory tempDir = await getTemporaryDirectory();
                    File file = File('${tempDir.path}/$randomNumber.png');
                    File cropResult = await file.writeAsBytes(cropImage!);
                    cameraPageProvider.replaceIdCardImage(
                        index: widget.index, imagePath: cropResult.path);
                    Navigator.pop(context);
                  }

                  // final scale = cropKey.currentState!.scale;
                  // final area = cropKey.currentState!.area;
                  // final sample = await ImageCrop.sampleImage(
                  //   file: widget.imageFile,
                  //   preferredSize: (2000 / scale).round(),
                  // );
                  // final file = await ImageCrop.cropImage(file: sample, area: area!);
                  // sample.delete(recursive: true);
                  // cameraPageProvider.replaceIdCardImage(index: widget.index, imagePath: file.path);
                  // Navigator.pop(context);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check,
                      color: Colors.grey,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      translation(context).done,
                      style: const TextStyle(color: Colors.grey),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.black,
      body: ExtendedImage.file(
        widget.imageFile,
        cacheRawData: true,
        fit: BoxFit.contain,
        extendedImageEditorKey: _controller,
        mode: ExtendedImageMode.editor,
        initEditorConfigHandler: (state) {
          return EditorConfig(
            cornerColor: AppColor.primaryColor,
          );
        },
      ),
    );
  }
}
