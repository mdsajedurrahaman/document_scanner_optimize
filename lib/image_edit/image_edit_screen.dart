import 'package:doc_scanner/camera_screen/model/image_model.dart';
import 'package:doc_scanner/camera_screen/provider/camera_provider.dart';
import 'package:doc_scanner/image_edit/provider/image_edit_provider.dart';
import 'package:doc_scanner/image_edit/image_size_screen.dart';
import 'package:doc_scanner/image_edit/widget/image_edit_button.dart';
import 'package:doc_scanner/image_edit/widget/image_filter_screen.dart';
import 'package:doc_scanner/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../localaization/language_constant.dart';
import '../utils/app_color.dart';
import 'crop_screen.dart';
import 'image_rotation.dart';




class ImageEditScreen extends StatefulWidget {
  final ImageModel image;
  final int imageIndex;

  const ImageEditScreen(
      {super.key, required this.image, required this.imageIndex});

  @override
  State<ImageEditScreen> createState() => _ImageEditScreenState();
}

class _ImageEditScreenState extends State<ImageEditScreen> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      context.read<ImageEditProvider>().addState(widget.image.imageByte);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageEditProvider = context.watch<ImageEditProvider>();
    final cameraProvider = context.watch<CameraProvider>();
    return PopScope(
      canPop: true,
       onPopInvoked: (didPop) {
         imageEditProvider.clearState();
       },
      child: Scaffold(
        backgroundColor: const Color(0xFFECECEC),
        appBar: AppBar(
          centerTitle: true,
          title: Text(widget.image.name),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
          actions: [
            TextButton(
              onPressed: () {
                cameraProvider.updateImage(
                    index: widget.imageIndex,
                    image: ImageModel(
                      imageByte: imageEditProvider.currentState,
                      name: widget.image.name,
                      docType: widget.image.docType,
                    ));
                imageEditProvider.clearState();
                Navigator.pop(context);
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
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Image.memory(
              imageEditProvider.currentState,
              fit: BoxFit.cover,
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          surfaceTintColor: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageEditButton(
                title:  translation(context).crop,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return CropScreen(
                        imageModel: widget.image,
                        index: widget.imageIndex,
                        cameFromEdit: true,
                      );
                    },
                  ));
                },
                iconPath: AppAssets.crop,
              ),
              ImageEditButton(
                title:  translation(context).filters,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const ImageFilters();
                    },
                  ));
                },
                iconPath: AppAssets.filter,
              ),
              ImageEditButton(
                title:  translation(context).size,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return const ImageSizeScreen();
                    },
                  ));
                },
                iconPath: AppAssets.size,
              ),
              ImageEditButton(
                title:  translation(context).rotate,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(
                    builder: (context) {
                      return ImageRotation(
                        imageModel: widget.image,
                        index: widget.imageIndex,
                        cameFromEdit: true,
                      );
                    },
                  ));
                },
                iconPath: AppAssets.rotate,
              ),
              ImageEditButton(
                title:  translation(context).undo,
                onTap: () {
                  if (imageEditProvider.canUndo) {
                    imageEditProvider.undo();
                  } else {
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                       SnackBar(
                        content: Text( translation(context).cannotUndoAnymore),
                      ),
                    );
                  }
                },
                iconPath: AppAssets.undo,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
