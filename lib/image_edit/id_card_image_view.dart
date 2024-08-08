import 'dart:io';
import 'package:doc_scanner/bottom_bar/bottom_bar.dart';
import 'package:doc_scanner/camera_screen/camera_screen.dart';
import 'package:doc_scanner/camera_screen/model/image_model.dart';
import 'package:doc_scanner/image_edit/image_preview.dart';
import 'package:doc_scanner/utils/app_assets.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:merge_image/merge_image.dart';
import 'package:provider/provider.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';
import 'id_card_crop.dart';

class IdCardImagePreview extends StatefulWidget {
  final bool? isCameFromRetake;
  final int? imageIndex;

  const IdCardImagePreview({super.key, this.isCameFromRetake, this.imageIndex});

  @override
  State<IdCardImagePreview> createState() => _IdCardImagePreviewState();
}

class _IdCardImagePreviewState extends State<IdCardImagePreview> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async{
       await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
          return const BottomBar();
        },), (route) => false).then((value) =>   cameraProvider.clearIdCardImages());
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () async{
              await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) {
                return const BottomBar();
              },), (route) => false).then((value) =>   cameraProvider.clearIdCardImages());
            },
          ),
          centerTitle: true,
          title: Text(
            translation(context).idCardImagePreview,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                var imageFront = await MergeImageHelper.loadImageFromFile(
                    File(cameraProvider.idCardImages.first),
                );
                var imageBack = await MergeImageHelper.loadImageFromFile(
                    File(cameraProvider.idCardImages.last));
                await MergeImageHelper.margeImages([imageFront, imageBack],
                        fit: true,
                        direction: Axis.vertical,
                        backgroundColor: Colors.transparent)
                    .then((image) async {
                  await MergeImageHelper.imageToUint8List(image).then((imageFile) async{
                    var result = await FlutterImageCompress.compressWithList(
                      imageFile!,
                      quality: 50,
                    );

                    String idCardName = DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
                    if (widget.isCameFromRetake == true &&
                        widget.isCameFromRetake != null &&
                        widget.imageIndex != null) {
                      cameraProvider.updateImage(
                          index: widget.imageIndex!,
                          image: ImageModel(
                              imageByte: result,
                              name: "IDCard-$idCardName",
                              docType: 'ID Card'),
                      );
                    } else {
                      cameraProvider.addImage(
                          ImageModel(
                          imageByte: result!,
                          name: "IDCard-$idCardName",
                          docType: 'ID Card'),
                      );
                    }
                    cameraProvider.clearIdCardImages();
                    setState(() {
                      isLoading = false;
                    });
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ImagePreviewScreen(
                           isCameFromIdCard: true,
                          ),
                        ),
                        (route) => false);
                  });
                });
              },
              child: Text(
                translation(context).done,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: List.generate(
                  cameraProvider.idCardImages.length,
                  (index) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 10, right: 10, top: 5, bottom: 20),
                          child: Image.file(
                              File(cameraProvider.idCardImages[index])),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 10,
                          child: IconButton(
                            icon: const Icon(
                              Icons.crop,
                              color: AppColor.primaryColor,
                              size: 30,
                            ),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ImageCropping(
                                      imageFile: File(
                                          cameraProvider.idCardImages[index]),
                                      index: index),
                                ),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 10,
                          child: IconButton(
                            icon: SvgPicture.asset(
                              AppAssets.retake,
                              color: AppColor.primaryColor,
                              height: 30,
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder:
                              (context) {
                                return  CameraScreen(
                                  initialPage: 1,
                                  isComeFromIdCardRetake: true,
                                  isFront: index == 0 ? true : false,
                                );
                              },));
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
      ),
    );
  }
}
