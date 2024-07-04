import 'dart:developer';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:doc_scanner/camera_screen/gallery_permission.dart';
import 'package:doc_scanner/home_page/home_page.dart';
import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:doc_scanner/settings_page/settings_page.dart';
import 'package:doc_scanner/utils/app_assets.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../camera_screen/camera_screen.dart';
import '../camera_screen/model/image_model.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../image_edit/image_preview.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

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

  @override
  Widget build(BuildContext context) {
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
        body: IndexedStack(
          index: _currentIndex,
          children: pages,
        ),
        floatingActionButton: CircleAvatar(
          radius: size.width >= 600 ? 40 : 30,
          backgroundColor: AppColor.primaryColor,
          child: FloatingActionButton(
            elevation: 0,
            onPressed: () async {
              await showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                builder: (context) {
                  return IntrinsicHeight(
                    child: Container(
                        // height: MediaQuery.of(context).size.height * 0.20,
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                            color: Colors.white),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(""),
                                  Text(
                                    translation(context).chooseAnAction,
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  Container(
                                    height: 30,
                                    width: 30,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: Color(0xFFF4F4F4),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(30),
                                        onTap: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10)
                                  .copyWith(
                                bottom: 30,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CameraScreen(),
                                          ),
                                        );
                                      },
                                      child: Container(
                                        height: size.width >= 600 ? 150 : 60,
                                        width: size.width >= 600 ? 210 : 90,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: AppColor.primaryColor,
                                              width: 1),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.camera_alt_outlined,
                                              color: AppColor.primaryColor,
                                              size: size.width >= 600 ? 40 : 30,
                                            ),
                                            Text(
                                              translation(context).camera,
                                              style: const TextStyle(
                                                  color: AppColor.primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () async {
                                        await checkPermission().then((value) async {
                                          if (value) {
                                            final ImagePicker _picker = ImagePicker();
                                            await _picker.pickMultiImage()
                                                .then((image) async {
                                              if (image.isNotEmpty) {
                                                for (int i = 0; i < image.length; i++) {
                                                  String documentName = DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
                                                  if (image[i] != null) {
                                                    cameraProvider.addImage(
                                                      ImageModel(
                                                        imageByte: await image[i].readAsBytes(),
                                                        name: 'Doc-$documentName',
                                                        docType: 'Document',
                                                      ),
                                                    );
                                                  }
                                                }
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ImagePreviewScreen(),
                                                  ),
                                                  (route) => false,
                                                );
                                              }
                                            });
                                            //     .catchError(  (e){
                                            //   Navigator.of(context).pop();
                                            //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("This image is not Supported")));
                                            // });

                                          } else {
                                            Navigator.push(context,
                                                MaterialPageRoute(
                                              builder: (context) {
                                                return const GalleryPermission();
                                              },
                                            ));
                                          }
                                        });
                                      },
                                      child: Container(
                                        height: size.width >= 600 ? 150 : 60,
                                        width: size.width >= 600 ? 210 : 90,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: AppColor.primaryColor,
                                              width: 1),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.photo_outlined,
                                              color: AppColor.primaryColor,
                                              size: size.width >= 600 ? 40 : 30,
                                            ),
                                            Text(
                                              translation(context).gallery,
                                              style: const TextStyle(
                                                  color: AppColor.primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(10),
                                      onTap: () async {
                                        Navigator.pop(context);
                                        FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                          type: FileType.custom,
                                          allowedExtensions: ['pdf'],
                                        );

                                        if (result != null) {
                                          File file = File(result.paths.first!);
                                          int fileSizeInBytes =
                                              await file.length();
                                          double fileSizeInMB =
                                              fileSizeInBytes / (1024 * 1024);
                                          if (fileSizeInMB <= 5) {
                                            cameraProvider
                                                .convertPdfToImage(file)
                                                .then((value) {
                                              if (value) {
                                                BuildContext context =
                                                    _scaffoldKey
                                                        .currentContext!;
                                                Navigator.pushAndRemoveUntil(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ImagePreviewScreen(),
                                                  ),
                                                  (route) => false,
                                                );
                                              }
                                            });
                                          } else {
                                            BuildContext context =
                                                _scaffoldKey.currentContext!;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(const SnackBar(
                                              content: Text(
                                                  'File size exceeds 5 MB. Please select a smaller file.'),
                                            ));
                                          }
                                        }
                                      },
                                      child: Container(
                                        height: size.width >= 600 ? 150 : 60,
                                        width: size.width >= 600 ? 210 : 90,
                                        decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          border: Border.all(
                                              color: AppColor.primaryColor,
                                              width: 1),
                                        ),
                                        alignment: Alignment.center,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.file_present_rounded,
                                              color: AppColor.primaryColor,
                                              size: size.width >= 600 ? 40 : 30,
                                            ),
                                            Text(
                                              translation(context).doc,
                                              style: TextStyle(
                                                  color: AppColor.primaryColor,
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 16),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            )
                          ],
                        )),
                  );
                },
              );
            },
            backgroundColor: AppColor.primaryColor,
            shape: const CircleBorder(),
            child: SvgPicture.asset(AppAssets.floatingCamera,
                width: size.width >= 600 ? 40 : 30,
                height: size.width >= 600 ? 38 : 28),
          ),
        ),
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
