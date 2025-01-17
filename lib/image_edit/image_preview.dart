import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui';
import 'package:doc_scanner/bottom_bar/bottom_bar.dart';
import 'package:doc_scanner/camera_screen/camera_screen.dart';
import 'package:doc_scanner/image_edit/crop_screen.dart';
import 'package:doc_scanner/image_edit/text_recognition_screen.dart';
import 'package:doc_scanner/image_edit/widget/image_edit_button.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:doc_scanner/utils/helper.dart';
import 'package:doc_scanner/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../camera_screen/model/image_model.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';
import '../utils/app_assets.dart';
import 'package:image/image.dart' as img;
import 'add_sgnature_screen.dart';
import 'image_edit_preview.dart';
import 'image_rotation.dart';

class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({super.key});

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  int currentIndex = 0;
  PageController pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    log("image preview screen ${cameraProvider.imageList.length.toString()}");
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop)
    {
      if (cameraProvider.imageList.isEmpty) {
        cameraProvider.clearImageList();
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (context) => const BottomBar(),
            ),
                (route) => false);
      }else{
      showNormalAlertDialogue(
        context: context,
        title: translation(context).discardDocument,
        content: translation(context).ifYouLeaveYourProgressWillBeLost,
        onOkText: translation(context).discard,
        onCancelText: translation(context).keepEditing,
        onOk: () {
          cameraProvider.clearImageList();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const BottomBar(),
              ),
                  (route) => false);
        },
        onCancel: () {
          Navigator.pop(context);
        },
      );
    }
      },
      child: Scaffold(
        backgroundColor: Color(0xFFECECEC),
        appBar: AppBar(
          centerTitle: true,
          leading: IconButton(onPressed: (){

            if(cameraProvider.imageList.isEmpty){
              cameraProvider.clearImageList();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const BottomBar(),
                  ),
                      (route) => false);
            }else{
              showNormalAlertDialogue(
                context: context,
                title: translation(context).discardDocument,
                content: translation(context).ifYouLeaveYourProgressWillBeLost,
                onOkText: translation(context).discard,
                onCancelText: translation(context).keepEditing,
                onOk: () {
                  cameraProvider.clearImageList();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const BottomBar(),
                      ),
                          (route) => false);
                },
                onCancel: () {
                  Navigator.pop(context);
                },
              );
            }

          }, icon: const Icon(Icons.arrow_back,color: Colors.black,)),
          title: cameraProvider.imageList.isEmpty
              ? Text(
                  translation(context).pleaseTakePhoto,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                )
              : Text(
                  cameraProvider.imageList[currentIndex].name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                  ),
                ),
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (cameraProvider.imageList.isNotEmpty) {
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                    builder: (context) {
                      return const EditImagePreview();
                    },
                  ), (route) => true);
                }
              },
              child: Text(
                translation(context).next,
                style:  TextStyle(
                    color: cameraProvider.imageList.isNotEmpty ?AppColor.primaryColor:Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            cameraProvider.imageList.isEmpty
                ? Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(AppAssets.image_not_found),
                          const SizedBox(height: 10),
                          Text(
                            translation(context).noImageFound,
                            style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 20,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  )
                : Expanded(
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: cameraProvider.imageList.length,
                      onPageChanged: (index) {

                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(15),
                          child: Image.memory(
                            cameraProvider.imageList[index].imageByte,
                            fit: BoxFit.contain,
                          ),
                        );
                      },
                    ),
                  ),
                cameraProvider.imageList.isNotEmpty? Container(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3),
              child: Text(
                '${currentIndex + 1}/${cameraProvider.imageList.length}',
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w400),
              ),
            ):const SizedBox.shrink(),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          surfaceTintColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ImageEditButton(
                title: translation(context).retake,
                onTap: () {
                  if (cameraProvider.imageList.isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CameraScreen(
                          initialPage:
                              cameraProvider.imageList[currentIndex].docType ==
                                      "Document"
                                  ? 0
                                  : 1,
                          isComeFromRetake: true,
                          imageIndex: currentIndex,
                          imageModel: cameraProvider.imageList[currentIndex],
                        ),
                      ),
                    );
                  }else{
                    ScaffoldMessenger.of(context).clearSnackBars();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(translation(context).pleaseAddImageFirst),
                      ),
                    );
                  }
                },
                iconPath: AppAssets.retake,
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20))),
                      builder: (context) {
                        return Container(
                          width: MediaQuery.of(context).size.width,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 15),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const CameraScreen(
                                          isComeFromAdd: true,
                                        ),
                                      ));
                                },
                                child: Container(
                                  height: 100,
                                  width: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.camera_alt_outlined,
                                        color: AppColor.primaryColor,
                                      ),
                                      Text(
                                        translation(context).camera,
                                        style: TextStyle(
                                            color: AppColor.primaryColor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () async {
                                  Navigator.pop(context);

                                  final ImagePicker _picker = ImagePicker();
                                  final List<XFile?> image =
                                      await _picker.pickMultiImage(
                                          limit: 5, imageQuality: 50);
                                  if (image.isNotEmpty) {
                                    for (int i = 0; i < image.length; i++) {
                                      String documentName =
                                          DateFormat('yyyyMMdd_SSSS')
                                              .format(DateTime.now());
                                      if (image[i] != null) {
                                        cameraProvider.addImage(
                                          ImageModel(
                                            imageByte:
                                                await image[i]!.readAsBytes(),
                                            name: 'Doc-$documentName',
                                            docType: 'Document',
                                          ),
                                        );
                                      }
                                    }
                                    Navigator.of(context);
                                  }
                                },
                                child: Container(
                                  height: 100,
                                  width: 160,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  alignment: Alignment.center,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      const Icon(
                                        Icons.photo_outlined,
                                        color: AppColor.primaryColor,
                                      ),
                                      Text(
                                        translation(context).gallery,
                                        style: const TextStyle(
                                            color: AppColor.primaryColor),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 30,
                          width: 30,
                          decoration: const BoxDecoration(
                            color: AppColor.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          translation(context).addPage,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () async {
                    if (cameraProvider.imageList.isNotEmpty) {
                      showNormalAlertDialogue(
                        context: context,
                        title: translation(context).deleteImage,
                        content: translation(context).doYouWantToDeleteThisImage,
                        onOkText: translation(context).delete,
                        onCancelText: translation(context).cancel,
                        onOk: () {
                          cameraProvider.deleteImage(currentIndex);
                          setState(() {
                            if(currentIndex>0){
                              currentIndex--;
                            }

                          });
                          Navigator.pop(context);
                        },
                        onCancel: () => Navigator.pop(context),
                      );
                    }else{
                      ScaffoldMessenger.of(context).clearSnackBars();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(translation(context).pleaseAddImageFirst),
                        ),
                      );
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(AppAssets.delete),
                        const SizedBox(height: 5),
                        Text(
                          translation(context).delete,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ImageEditButton(
              //   title: translation(context).rotate,
              //   onTap: () async {
              //     if (cameraProvider.imageList.isNotEmpty) {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => ImageRotation(
              //             imageModel: cameraProvider.imageList[currentIndex],
              //             index: currentIndex,
              //           ),
              //         ),
              //       );
              //     }
              //   },
              //   iconPath: AppAssets.rotate,
              // ),
              // ImageEditButton(
              //   title: translation(context).reframe,
              //   onTap: () async {
              //     if (cameraProvider.imageList.isNotEmpty) {
              //       Navigator.push(
              //         context,
              //         MaterialPageRoute(
              //           builder: (context) => CropScreen(
              //             imageModel: cameraProvider.imageList[currentIndex],
              //             index: currentIndex,
              //           ),
              //         ),
              //       );
              //     }
              //   },
              //   iconPath: AppAssets.reFrame,
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
