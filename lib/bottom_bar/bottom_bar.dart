import 'dart:developer';
import 'dart:io';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:doc_scanner/home_page/home_page.dart';
import 'package:doc_scanner/home_page/model/camera_item_model.dart';
import 'package:doc_scanner/image_edit/provider/image_edit_provider.dart';
import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:doc_scanner/settings_page/settings_page.dart';
import 'package:doc_scanner/utils/app_assets.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:doc_scanner/utils/helper.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../camera_screen/camera_screen.dart';
import '../camera_screen/model/image_model.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../image_edit/image_preview.dart';

class BottomBar extends StatefulWidget {
  final bool? shouldShowReview;
  const BottomBar({super.key, this.shouldShowReview});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int _currentIndex = 0;
  List<Widget> pages = [const HomePage(), const SettingsPage()];

  void updatePage(int page) {
    setState(() {
      _currentIndex = page;
    });
  }

  GlobalKey _scaffoldKey = GlobalKey();
  late PermissionStatus storage;

  Future<bool> checkPermission() async {
    if (Platform.isAndroid) {
      AndroidDeviceInfo build = await DeviceInfoPlugin().androidInfo;
      if (build.version.sdkInt <= 32) {
        storage = await Permission.storage.status;
      } else {
        storage = await Permission.photos.status;
      }

      if (storage.isDenied) {
        return false;
      } else if (storage.isPermanentlyDenied) {
        return false;
      } else if (storage.isGranted) {
        return true;
      } else {
        return false;
      }
    } else {
      print("Ios");
      storage = await Permission.photos.status;
      if (storage.isDenied) {
        return false;
      } else if (storage.isPermanentlyDenied) {
        return false;
      } else if (storage.isGranted) {
        return true;
      } else {
        return false;
      }
    }
  }

  final InAppReview inAppReview = InAppReview.instance;

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (widget.shouldShowReview != null && widget.shouldShowReview == true) {
        if (await inAppReview.isAvailable()) {
          inAppReview.requestReview();
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final imageEditProvider = context.watch<ImageEditProvider>();

    final cameraProvider = context.watch<CameraProvider>();
    final size = MediaQuery.sizeOf(context);
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text(translation(context).alert),
              content: Text(translation(context).areYouSureYouWantToExitApp),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(translation(context).no),
                ),
                TextButton(
                  onPressed: () {
                    SystemNavigator.pop();
                  },
                  child: Text(translation(context).yes),
                )
              ],
            );
          },
        );

        false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: pages[_currentIndex],
        // key: _scaffoldKey,
        // body: IndexedStack(
        //   index: _currentIndex,
        //   children: pages,
        // ),
        // floatingActionButton: CircleAvatar(
        //   radius: size.width >= 600 ? 40 : 30,
        //   backgroundColor: AppColor.primaryColor,
        //   child: FloatingActionButton(
        //     elevation: 0,
        //     onPressed: () async {
        //       await showModalBottomSheet(
        //         context: context,
        //         backgroundColor: Colors.transparent,
        //         builder: (context) {
        //           return IntrinsicHeight(
        //             child: Container(
        //                 height: size.width >= 600 ? 270 : 220,
        //                 width: MediaQuery.of(context).size.width,
        //                 decoration: const BoxDecoration(
        //                     borderRadius: BorderRadius.only(
        //                       topLeft: Radius.circular(20),
        //                       topRight: Radius.circular(20),
        //                     ),
        //                     color: Colors.white),
        //                 child: Column(
        //                   mainAxisAlignment: MainAxisAlignment.start,
        //                   children: [
        //                     Padding(
        //                       padding:
        //                           const EdgeInsets.symmetric(horizontal: 10)
        //                               .copyWith(top: 10, bottom: 5),
        //                       child: Row(
        //                         mainAxisAlignment:
        //                             MainAxisAlignment.spaceBetween,
        //                         children: [
        //                           const Text(""),
        //                           Text(
        //                             translation(context).chooseAnAction,
        //                             style: const TextStyle(
        //                                 color: Colors.black,
        //                                 fontSize: 20,
        //                                 fontWeight: FontWeight.w500),
        //                           ),
        //                           Container(
        //                             height: size.width >= 600 ? 40 : 30,
        //                             width: size.width >= 600 ? 40 : 30,
        //                             alignment: Alignment.center,
        //                             decoration: const BoxDecoration(
        //                               color: Color(0xFFF4F4F4),
        //                               shape: BoxShape.circle,
        //                             ),
        //                             child: Material(
        //                               color: Colors.transparent,
        //                               child: InkWell(
        //                                 borderRadius: BorderRadius.circular(30),
        //                                 onTap: () {
        //                                   Navigator.pop(context);
        //                                 },
        //                                 child: Icon(
        //                                   Icons.close_rounded,
        //                                   size: size.width >= 600 ? 30 : 20,
        //                                 ),
        //                               ),
        //                             ),
        //                           ),
        //                         ],
        //                       ),
        //                     ),
        //                     Divider(
        //                       color: Colors.grey.withOpacity(0.3),
        //                     ),
        //                     Padding(
        //                       padding: const EdgeInsets.symmetric(vertical: 10)
        //                           .copyWith(bottom: 30),
        //                       child:const Row(
        //                         mainAxisAlignment:
        //                             MainAxisAlignment.spaceEvenly,
        //                         crossAxisAlignment: CrossAxisAlignment.center,
        //                         children: [
        //       Material(
        //         color: Colors.transparent,
        //         child: InkWell(
        //           borderRadius: BorderRadius.circular(10),
        //           onTap: () {
        //             Navigator.push(
        //               context,
        //               MaterialPageRoute(
        //                 builder: (context) =>
        //                     const CameraScreen(),
        //               ),
        //             );
        //           },
        //           child: Container(
        //             height: size.width >= 600 ? 150 : 110,
        //             width: size.width >= 600 ? 150 : 110,
        //             decoration: BoxDecoration(
        //               borderRadius:
        //                   BorderRadius.circular(10),
        //               border: Border.all(
        //                   color: Colors.black, width: 1),
        //             ),
        //             alignment: Alignment.center,
        //             child: Column(
        //               mainAxisAlignment:
        //                   MainAxisAlignment.center,
        //               crossAxisAlignment:
        //                   CrossAxisAlignment.center,
        //               children: [
        //                 SvgPicture.asset(AppAssets.camera),
        //                 // Icon(
        //                 //   Icons.camera_alt_outlined,
        //                 //   color: AppColor.primaryColor,
        //                 //   size: size.width >= 600 ? 40 : 50,
        //                 // ),
        //                 Text(
        //                   translation(context).camera,
        //                   style: const TextStyle(
        //                       color: Colors.black,
        //                       fontWeight: FontWeight.w500,
        //                       fontSize: 20),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ),
        //       ),
        //       Material(
        //         color: Colors.transparent,
        //         child: InkWell(
        //           borderRadius: BorderRadius.circular(10),
        //           onTap: () async {
        //             await checkPermission()
        //                 .then((value) async {
        //               if (value) {
        //                 final ImagePicker _picker =
        //                     ImagePicker();
        //                 await _picker
        //                     .pickMultiImage()
        //                     .then((image) async {
        //                   if (image.isNotEmpty) {
        //                     for (int i = 0;
        //                         i < image.length;
        //                         i++) {
        //                       String documentName =
        //                           DateFormat(
        //                                   'yyyyMMdd_SSSS')
        //                               .format(
        //                                   DateTime.now());
        //                       cameraProvider.addImage(
        //                         ImageModel(
        //                           imageByte: await image[i]
        //                               .readAsBytes(),
        //                           name: 'Doc-$documentName',
        //                           docType: 'Document',
        //                         ),
        //                       );
        //                     }
        //                     Navigator.pushAndRemoveUntil(
        //                       context,
        //                       MaterialPageRoute(
        //                         builder: (context) =>
        //                             const ImagePreviewScreen(),
        //                       ),
        //                       (route) => false,
        //                     );
        //                   }
        //                 });
        //               } else {
        //                 Navigator.push(context,
        //                     MaterialPageRoute(
        //                   builder: (context) {
        //                     return const GalleryPermission();
        //                   },
        //                 ));
        //               }
        //             });
        //           },
        //           child: Container(
        //             height: size.width >= 600 ? 150 : 110,
        //             width: size.width >= 600 ? 150 : 110,
        //             decoration: BoxDecoration(
        //               borderRadius:
        //                   BorderRadius.circular(10),
        //               border: Border.all(
        //                   color: Colors.black, width: 1),
        //             ),
        //             alignment: Alignment.center,
        //             child: Column(
        //               mainAxisAlignment:
        //                   MainAxisAlignment.center,
        //               crossAxisAlignment:
        //                   CrossAxisAlignment.center,
        //               children: [
        //                 SvgPicture.asset(AppAssets.gallery),
        //                 // Icon(
        //                 //   Icons.photo_outlined,
        //                 //   color: AppColor.primaryColor,
        //                 //   size: size.width >= 600 ? 40 : 50,
        //                 // ),
        //                 Text(
        //                   translation(context).gallery,
        //                   style: const TextStyle(
        //                       color: Colors.black,
        //                       fontWeight: FontWeight.w500,
        //                       fontSize: 20),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ),
        //       ),
        //       Material(
        //         color: Colors.transparent,
        //         child: InkWell(
        //           borderRadius: BorderRadius.circular(10),
        //           onTap: () async {
        //             // await FilePicker.platform.pickFiles(
        //             //   type: FileType.custom,
        //             //   allowedExtensions: ['pdf'],
        //             // ).then((value) async{
        //             //   File pdfFile=File(value!.paths.first!);
        //             //       cameraProvider.convertPdfToImage(pdfFile).then((value) {
        //             //              Navigator.pushAndRemoveUntil(
        //             //                   context,
        //             //                   MaterialPageRoute(
        //             //                     builder: (context) =>
        //             //                         const ImagePreviewScreen(),
        //             //                   ),
        //             //                   (route) => false,
        //             //                 );
        //             //
        //             //
        //             //       });
        //             // });
        //             //

        //             Navigator.of(context).pop();
        //             FilePickerResult? result =
        //                 await FilePicker.platform.pickFiles(
        //               type: FileType.custom,
        //               allowedExtensions: ['pdf'],
        //             );
        //             if (result != null) {
        //               File file = File(result.paths.first!);
        //               // int fileSizeInBytes = await file.length();
        //               // double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
        //               // if (fileSizeInMB <= 5) {
        //               cameraProvider
        //                   .convertPdfToImage(file)
        //                   .then((value) {
        //                 if (value) {
        //                   BuildContext context =
        //                       _scaffoldKey.currentContext!;
        //                   Navigator.pushAndRemoveUntil(
        //                     context,
        //                     MaterialPageRoute(
        //                       builder: (context) =>
        //                           const ImagePreviewScreen(),
        //                     ),
        //                     (route) => false,
        //                   );
        //                 }
        //               });
        //               // }
        //               // else {
        //               //     BuildContext context =
        //               //         _scaffoldKey.currentContext!;
        //               //     ScaffoldMessenger.of(context)
        //               //         .showSnackBar(const SnackBar(
        //               //       content: Text('File size exceeds 5 MB. Please select a smaller file.'),
        //               //     ));
        //               //   }
        //             } else {
        //               BuildContext context =
        //                   _scaffoldKey.currentContext!;
        //               ScaffoldMessenger.of(context)
        //                   .showSnackBar(const SnackBar(
        //                       content: Text(
        //                           "Something Went Wrong")));
        //             }
        //           },
        //           child: Container(
        //             height: size.width >= 600 ? 150 : 110,
        //             width: size.width >= 600 ? 150 : 110,
        //             decoration: BoxDecoration(
        //               borderRadius:
        //                   BorderRadius.circular(10),
        //               border: Border.all(
        //                   color: Colors.black, width: 1),
        //             ),
        //             alignment: Alignment.center,
        //             child: Column(
        //               mainAxisAlignment:
        //                   MainAxisAlignment.center,
        //               crossAxisAlignment:
        //                   CrossAxisAlignment.center,
        //               children: [
        //                 SvgPicture.asset(AppAssets.pdf),
        //                 // Icon(
        //                 //   Icons.file_present_rounded,
        //                 //   color: AppColor.primaryColor,
        //                 //   size: size.width >= 600 ? 40 : 50,
        //                 // ),
        //                 Text(
        //                   translation(context).pdf,
        //                   style: TextStyle(
        //                       color: Colors.black,
        //                       fontWeight: FontWeight.w500,
        //                       fontSize: 20),
        //                 )
        //               ],
        //             ),
        //           ),
        //         ),
        // )
        //                         ],
        //                       ),
        //                     )
        //                   ],
        //                 )),
        //           );
        //         },
        //       );
        //     },
        //     backgroundColor: AppColor.primaryColor,
        //     shape: const CircleBorder(),
        // child: SvgPicture.asset(AppAssets.floatingCamera,
        //     width: size.width >= 600 ? 40 : 30,
        //     height: size.width >= 600 ? 38 : 28),
        //   ),
        // ),
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        floatingActionButton: SpeedDial(
            elevation: 0,
            childrenButtonSize: const Size(200, 60),
            buttonSize:
                size.width >= 600 ? const Size(70, 70) : const Size(55, 55),
            backgroundColor: AppColor.primaryColor,
            activeIcon: Icons.close,
            iconTheme: const IconThemeData(color: Colors.white),
            children: [
              // SpeedDialChild(
              //   backgroundColor: const Color(0xFFF95658),
              //   child: const Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Icon(
              //         Icons.camera_alt,
              //         color: Colors.white,
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Text(
              //         'DL License',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     ],
              //   ),
              //   onTap: () async {
              //     await AppHelper.handlePermissions().then((_) async {
              //       await CunningDocumentScanner.getPictures(
              //               isGalleryImportAllowed: true)
              //           .then((pictures) {
              //         if (pictures!.isNotEmpty) {
              //           pictures.forEach((element) async {
              //             String imageName =
              //                 DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
              //             imageEditProvider.addImage(ImageModel(
              //                 docType: 'License',
              //                 imageByte: File(element).readAsBytesSync(),
              //                 name: "License-$imageName"));
              //           });
              //
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (context) => const ImagePreviewScreen(),
              //               ));
              //         }
              //       });
              //     });
              //   },
              // ),

              //visting card
              SpeedDialChild(
                backgroundColor: const Color(0xFFFBF3F2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AppAssets.idCard,
                        height: size.width >= 600 ? 30 : 25,
                        width: size.width >= 600 ? 30 : 25),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'ID Card',
                      // style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                onTap: () async {
                  await AppHelper.handlePermissions().then((_) async {
                    await CunningDocumentScanner.getPictures(
                            noOfPages: 2, isGalleryImportAllowed: true)
                        .then((pictures) {
                      if (pictures!.isEmpty) {
                      } else {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => BusinessCardPreview(
                        //       imagesPath: pictures,
                        //     ),
                        //   ),
                        // );
                      }
                    });
                  });
                },
              ),

              SpeedDialChild(
                backgroundColor: const Color(0xFFFFF7EB),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(AppAssets.documents,
                        height: size.width >= 600 ? 30 : 25,
                        width: size.width >= 600 ? 30 : 25),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      'Document',
                      // style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                onTap: () async {
                  await AppHelper.handlePermissions().then((_) async {
                    await CunningDocumentScanner.getPictures(
                            isGalleryImportAllowed: true)
                        .then((pictures) {
                      if (pictures!.isNotEmpty) {
                        pictures.forEach((element) async {
                          String imageName = DateFormat('yyyyMMdd_SSSS')
                              .format(DateTime.now());
                          cameraProvider.addImage(ImageModel(
                              docType: 'Document',
                              imageByte: File(element).readAsBytesSync(),
                              name: "Document-$imageName"));
                        });

                        Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ImagePreviewScreen(),
                            ));
                      }
                    });
                  });
                },
              ),
              // SpeedDialChild(
              //   backgroundColor: const Color(0xFF008000),
              //   child: const Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Icon(
              //         Icons.camera_alt,
              //         color: Colors.white,
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Text(
              //         'Passport',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     ],
              //   ),
              //   onTap: () async {
              //     await AppHelper.handlePermissions().then((_) async {
              //       await CunningDocumentScanner.getPictures(
              //               isGalleryImportAllowed: true)
              //           .then((pictures) {
              //         if (pictures!.isNotEmpty) {
              //           pictures.forEach((element) async {
              //             String imageName =
              //                 DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
              //             imageEditProvider.addImage(ImageModel(
              //                 docType: 'Passport',
              //                 imageByte: File(element).readAsBytesSync(),
              //                 name: "Passport-$imageName"));
              //           });
              //
              //           Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (context) => const ImagePreviewScreen(),
              //               ));
              //         }
              //       });
              //     });
              //   },
              // ),
              // SpeedDialChild(
              //   backgroundColor: const Color(0xFFFDAB35),
              //   child: const Row(
              //     mainAxisAlignment: MainAxisAlignment.center,
              //     crossAxisAlignment: CrossAxisAlignment.center,
              //     children: [
              //       Icon(
              //         Icons.camera_alt,
              //         color: Colors.white,
              //       ),
              //       SizedBox(
              //         width: 10,
              //       ),
              //       Text(
              //         'ID Card',
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     ],
              //   ),
              //   onTap: () async {
              //     await AppHelper.handlePermissions().then((_) async {
              //       await CunningDocumentScanner.getPictures(
              //               isGalleryImportAllowed: true, noOfPages: 2)
              //           .then((pictures) {
              //         if (pictures!.isNotEmpty) {
              //
              //           if(pictures.length==1){
              //             String imageName = DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
              //             imageEditProvider.addImage(
              //                 ImageModel(docType: 'ID Card', imageByte:  File(pictures.first).readAsBytesSync(),name: "ID card-$imageName" )
              //             );
              //             Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (context) => const ImagePreviewScreen(),
              //               ),
              //             );
              //           }else{
              //             pictures.forEach((element) async {
              //               imageEditProvider.addIdCardImage(element);
              //
              //             });
              //
              //             Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (context) => const ImagePreviewScreen(
              //                   isComeFromIdCard: true,
              //                 ),
              //               ),
              //             );
              //           }
              //         }
              //       });
              //     });
              //   },
              // ),
            ],
            child: SvgPicture.asset(AppAssets.floatingCamera,
                width: size.width >= 600 ? 40 : 30,
                height: size.width >= 600 ? 38 : 28)),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

        bottomNavigationBar: BottomAppBar(
          surfaceTintColor: Colors.grey,
          shape: const CircularNotchedRectangle(),
          notchMargin: 10.0,
          clipBehavior: Clip.antiAlias,
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              labelTextStyle: MaterialStateProperty.all(
                const TextStyle(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ),
            child: NavigationBarTheme(
              data: NavigationBarThemeData(
                labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>(
                  (Set<MaterialState> states) =>
                      states.contains(MaterialState.selected)
                          ? const TextStyle(color: AppColor.primaryColor)
                          : const TextStyle(color: Colors.black),
                ),
              ),
              child: NavigationBar(
                surfaceTintColor: Colors.grey,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
                indicatorColor: Colors.transparent,
                elevation: 5,
                onDestinationSelected: (int index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                selectedIndex: _currentIndex,
                destinations: [
                  Padding(
                    padding: const EdgeInsets.only(right: 40.0),
                    child: NavigationDestination(
                      icon: SvgPicture.asset(
                        AppAssets.homeOutline,
                        width: size.width >= 600 ? 30 : 30,
                        height: size.width >= 600 ? 30 : 30,
                        color: Colors.black,
                      ),
                      selectedIcon: SvgPicture.asset(AppAssets.homeFill,
                          width: size.width >= 600 ? 30 : 25,
                          height: size.width >= 600 ? 30 : 25),
                      label: translation(context).home,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: NavigationDestination(
                      icon: SvgPicture.asset(AppAssets.settingOutline,
                          width: size.width >= 600 ? 30 : 25,
                          height: size.width >= 600 ? 30 : 25,
                          color: Colors.black),
                      selectedIcon: SvgPicture.asset(AppAssets.settingFill,
                          width: size.width >= 600 ? 30 : 25,
                          height: size.width >= 600 ? 30 : 25),
                      label: translation(context).settings,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
