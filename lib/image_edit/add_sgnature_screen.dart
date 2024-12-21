import 'dart:developer';
import 'dart:ui' as ui;
import 'package:doc_scanner/camera_screen/model/image_model.dart';
import 'package:doc_scanner/image_edit/widget/image_edit_button.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:interactive_box/interactive_box.dart';
import 'package:provider/provider.dart';

import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';
import '../utils/app_assets.dart';
import 'drawing.dart';

class AddSignature extends StatefulWidget {
  final ImageModel imageModel;
  final int imageIndex;

  const AddSignature({
    super.key,
    required this.imageModel,
    required this.imageIndex,
  });

  @override
  State<AddSignature> createState() => _AddSignatureState();
}

class _AddSignatureState extends State<AddSignature> {
  String? signaturePath;
  bool drawSignature = false;
  final GlobalKey _globalKey = GlobalKey();
  bool initialShowActionIcons = true;

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    return Scaffold(
      backgroundColor: const Color(0xFF131314),
      appBar: AppBar(
        backgroundColor: const Color(0xff1E1F20),
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xffffffff),
            )),
        title: Text(
          translation(context).addSignature,
          style: const TextStyle(
              fontWeight: FontWeight.w500, fontSize: 20, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                initialShowActionIcons = false;
              });

              Future.delayed(const Duration(milliseconds: 500), () async {
                var image = await captureImage();
                if (image != null) {
                  cameraProvider.updateImage(
                      image: ImageModel(
                          imageByte: image,
                          name: widget.imageModel.name,
                          docType: widget.imageModel.docType),
                      index: widget.imageIndex);
                  Navigator.pop(context);
                }
              });
            },
            child: Text(
              translation(context).done,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: AppColor.primaryColor,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: RepaintBoundary(
          key: _globalKey,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Center(
                child: Image.memory(
                  widget.imageModel.imageByte,
                  fit: BoxFit.cover,
                ),
              ),
              if (signaturePath != null)
                InteractiveBox(
                  initialPosition: const Offset(50, 200),
                  includedScaleDirections: const [
                    ScaleDirection.topRight,
                    ScaleDirection.bottomRight,
                    ScaleDirection.bottomLeft,
                    ScaleDirection.topLeft,
                  ],
                  initialSize: const Size(250, 150),
                  includedActions: const [
                    ControlActionType.move,
                    ControlActionType.scale,
                    ControlActionType.rotate,
                    ControlActionType.delete,
                  ],
                  onActionSelected: (ControlActionType controlActionType,
                      InteractiveBoxInfo interactiveBoxInfo) {
                    if (controlActionType == ControlActionType.delete) {
                      setState(() {
                        signaturePath = null;
                      });
                    }
                  },
                  initialShowActionIcons: initialShowActionIcons,
                  rotateIndicatorSpacing: 10,
                  child: drawSignature == true
                      ? SvgPicture.string(signaturePath!, fit: BoxFit.cover)
                      : Image.memory(
                          Uint8List.fromList(signaturePath!.codeUnits),
                          fit: BoxFit.cover,
                        ),
                ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        color: const Color(0xff1E1F20),
        height: 70,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ImageEditButton(
              title: translation(context).draw,
              onTap: () async {
                var signature = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DrawingScreen(),
                  ),
                );
                if (signature != null) {
                  setState(() {
                    signaturePath = signature;
                    drawSignature = true;
                  });
                }
              },
              iconPath: AppAssets.sign,
            ),
            ImageEditButton(
              title: translation(context).gallery,
              onTap: () async {
                await importFromGallery();
                drawSignature = false;
              },
              iconPath:
                  AppAssets.gallery, // Replace with your desired gallery icon
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List?> captureImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      log(boundary.size.toString());
      double pixelRatio = MediaQuery.of(context).devicePixelRatio;
      ui.Image image = await boundary.toImage(pixelRatio: pixelRatio);
      ByteData? byteData =
          await image.toByteData(format: ui.ImageByteFormat.png);

      return byteData!.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }

  Future<void> importFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        signaturePath =
            null; // Clear any SVG path (optional, if only one image at a time is allowed)
      });

      // Display the imported image using InteractiveBox
      setState(() {
        signaturePath = String.fromCharCodes(bytes);
      });
    }
  }
}
