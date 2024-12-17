import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:doc_scanner/camera_screen/provider/camera_provider.dart';
import 'package:doc_scanner/core/local_storage.dart';
import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:doc_scanner/utils/app_constant.dart';
import 'package:doc_scanner/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_flip_card/controllers/flip_card_controllers.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
// import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import '../utils/app_assets.dart';
import 'model/image_model.dart';

class CameraScreen extends StatefulWidget {
  final int initialPage;
  final bool? isComeFromRetake;
  final bool? isComeFromAdd;
  final int? imageIndex;
  final ImageModel? imageModel;
  final bool? isComeFromIdCardRetake;
  final bool? isFront;

  const CameraScreen(
      {super.key,
      this.initialPage = 1,
      this.isComeFromRetake,
      this.imageIndex,
      this.imageModel,
      this.isComeFromAdd,
      this.isComeFromIdCardRetake,
      this.isFront});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool flash = false;
  bool gridview = false;
  int activePage = 0;
  late final PageController _pageController;
  late CameraController cameraController;
  bool isCameraReady = false;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  FlipCardController flipCardController = FlipCardController();
  QRViewController? qrController;
  Barcode? result;
  late AudioPlayer audioPlayer;
  bool beepValue = false;
  bool vibrationValue = false;
  bool isCameraPermissionGranted = false;
  final bool _isCapturePressed = false;
  List<String> barCodeList = [
    "CODABAR",
    "CODE_39",
    "CODE_93",
    "CODE_128",
    "EAN_8",
    "EAN_13",
    "ITF",
    "PDF_417",
    "RSS14",
    "RSS_EXPANDED",
    "UPC_A",
    "UPC_EAN_EXTENSION",
  ];
  bool activeDialog = false;

  Future<void> initCamera() async {
    final cameras = await availableCameras();
    cameraController = CameraController(cameras[0], ResolutionPreset.max);
    await cameraController.initialize().then((_) {
      if (!mounted) {
        return;
      }
      cameraController.setFlashMode(FlashMode.off);
      setState(() {
        isCameraReady = true;
      });
    }).catchError((error) {
      log("Error: $error");
    });
  }

  Future checkPermission() async {
    var cameraStatus = await Permission.camera.status;
    var storageStatus = await Permission.microphone.status;
    if (cameraStatus.isGranted && storageStatus.isGranted) {
      initCamera();
      setState(() {
        isCameraPermissionGranted = true;
      });
    } else {
      setState(() {
        isCameraPermissionGranted = false;
      });
    }
  }

  @override
  void initState() {
    checkPermission();
    // WidgetsBinding.instance.addObserver(this);
    activePage = widget.initialPage;

    _pageController =
        PageController(initialPage: activePage, viewportFraction: 1 / 3);
    beepValue = LocalStorage().getBool(AppConstant.BEEP_KEY);
    vibrationValue = LocalStorage().getBool(AppConstant.VIBRATION_KEY);
    audioPlayer = AudioPlayer();
    // if (widget.isComeFromIdCardRetake != null &&
    //     widget.isFront != null &&
    //     widget.initialPage == 1) {
    //   if (!widget.isFront!) {
    //     Future.delayed(const Duration(seconds: 1), () {
    //       flipCardController.flipcard();
    //     });
    //   }
    // }

    super.initState();
  }

  @override
  void dispose() {
    cameraController.dispose();
    _pageController.dispose();
    qrController?.dispose();
    // WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  //
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.resumed) {
  //     checkPermission();
  //   }
  // }
  void _openBrowserWithSearch(String query) async {
    // Encode the query to make it URL-safe
    final encodedQuery = Uri.encodeComponent(query);
    // Form the Google search URL
    final url = 'https://www.google.com/search?q=$encodedQuery';

    // Check if the URL can be launched
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    final size = MediaQuery.sizeOf(context);

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (widget.isComeFromRetake == true ||
            widget.isComeFromIdCardRetake == true) {
          return;
        } else if (widget.isComeFromAdd != null &&
            widget.isComeFromAdd == true) {
          return;
        } else {
          cameraProvider.clearImageList();
          return;
        }
      },
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: isCameraPermissionGranted == false
              ? Container(
                  height: MediaQuery.sizeOf(context).height,
                  width: MediaQuery.sizeOf(context).width,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 30,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          final permissions = [
                            Permission.camera,
                            Permission.microphone
                          ];
                          var status = await permissions.request();
                          var cameraStatus = status[Permission.camera];
                          var microphoneStatus = status[Permission.microphone];

                          if (cameraStatus!.isGranted &&
                              microphoneStatus!.isGranted) {
                            setState(() {
                              isCameraPermissionGranted = true;
                              initCamera();
                            });
                          } else if ((microphoneStatus!.isPermanentlyDenied ||
                                  cameraStatus.isPermanentlyDenied) ||
                              (microphoneStatus.isDenied ||
                                  cameraStatus.isDenied)) {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title:
                                    Text(translation(context).permissionDenied),
                                content: Text(translation(context)
                                    .pleaseAllowCameraMicrophonePermissionToUseThisFeature),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text(translation(context).cancel)),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                      openAppSettings();
                                    },
                                    child:
                                        Text(translation(context).openSettings),
                                  ),
                                ],
                              ),
                            );
                          }
                        },
                        child: Text(translation(context).allowCameraPermission),
                      ),
                    ],
                  ),
                )
              : !isCameraReady
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : SafeArea(
                      child: Column(
                        children: [
                          Container(
                            width: MediaQuery.sizeOf(context).width,
                            height: 40,
                            decoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                IconButton(
                                  onPressed: () {
                                    setState(() {
                                      flash = !flash;
                                    });

                                    if (activePage == 0 || activePage == 1) {
                                      if (flash) {
                                        cameraController
                                            .setFlashMode(FlashMode.torch);
                                      } else {
                                        cameraController
                                            .setFlashMode(FlashMode.off);
                                      }
                                    } else {
                                      if (flash) {
                                        qrController!.toggleFlash();
                                      } else {
                                        qrController!.toggleFlash();
                                      }
                                    }
                                  },
                                  icon: Icon(
                                    flash ? Icons.flash_on : Icons.flash_off,
                                    color: Colors.white,
                                  ),
                                ),
                                activePage == 0
                                    ? IconButton(
                                        onPressed: () {
                                          setState(() {
                                            gridview = !gridview;
                                          });
                                        },
                                        icon: Icon(
                                          gridview
                                              ? Icons.grid_on
                                              : Icons.grid_off,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const SizedBox.shrink()
                              ],
                            ),
                          ),
                          Expanded(
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // activePage == 0
                                //     ? CameraPreview(cameraController)
                                //     : activePage == 1
                                //         ? FlipCard(
                                //             animationDuration:
                                //                 const Duration(seconds: 2),
                                //             rotateSide: RotateSide.left,
                                //             controller: flipCardController,
                                //             axis: FlipAxis.vertical,
                                //             frontWidget: CameraPreview(
                                //               cameraController,
                                //               child: Container(
                                //                   alignment:
                                //                       Alignment.bottomCenter,
                                //                   padding:
                                //                       const EdgeInsets.only(
                                //                           bottom: 40),
                                //                   decoration: ShapeDecoration(
                                //                     color: Colors.red,
                                //                     shape:
                                //                         CustomCutoutShapeBorder(
                                //                       CutoutScreenArea(
                                //                         borderColor: Colors.red,
                                //                         borderWidth: 3.0,
                                //                         overlayColor:
                                //                             const Color
                                //                                 .fromRGBO(
                                //                                 0, 0, 0, 80),
                                //                         borderRadius: 10.0,
                                //                         borderLength: 40.0,
                                //                         cutOutHeight: 250.0,
                                //                         cutOutWidth:
                                //                             MediaQuery.sizeOf(
                                //                                     context)
                                //                                 .width,
                                //                       ),
                                //                     ),
                                //                   ),
                                //                   child: Text(
                                //                     translation(context)
                                //                         .frontPart,
                                //                     style: const TextStyle(
                                //                         color: Colors.grey,
                                //                         fontSize: 20),
                                //                   )),
                                //             ),
                                //             backWidget: CameraPreview(
                                //               cameraController,
                                //               child: Container(
                                //                   alignment:
                                //                       Alignment.bottomCenter,
                                //                   decoration: ShapeDecoration(
                                //                     color: Colors.blue,
                                //                     shape:
                                //                         CustomCutoutShapeBorder(
                                //                       CutoutScreenArea(
                                //                         borderColor: Colors.red,
                                //                         borderWidth: 3.0,
                                //                         overlayColor:
                                //                             const Color
                                //                                 .fromRGBO(
                                //                                 0, 0, 0, 80),
                                //                         borderRadius: 10.0,
                                //                         borderLength: 40.0,
                                //                         cutOutHeight: 250.0,
                                //                         cutOutWidth:
                                //                             MediaQuery.sizeOf(
                                //                                     context)
                                //                                 .width,
                                //                       ),
                                //                     ),
                                //                   ),
                                //                   padding:
                                //                       const EdgeInsets.only(
                                //                           bottom: 40),
                                //                   child: Text(
                                //                     translation(context)
                                //                         .backPart,
                                //                     style: const TextStyle(
                                //                         color: Colors.grey,
                                //                         fontSize: 20),
                                //                   )),
                                //             ),
                                //           )
                                //         :
                                activePage == 0 || activePage == 1
                                    ? Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          QRView(
                                            key: qrKey,
                                            onQRViewCreated: (controller) {
                                              qrController = controller;
                                              controller.scannedDataStream
                                                  .listen(
                                                (event) async {
                                                  setState(() {
                                                    result = event;
                                                  });
                                                  if (result != null &&
                                                      activePage == 1 &&
                                                      barCodeList.contains(
                                                          result!.format
                                                              .formatName)) {
                                                    if (beepValue) {
                                                      await audioPlayer.play(
                                                          AssetSource(
                                                              'audio/beep_sound.mp3'));
                                                    }
                                                    if (vibrationValue) {
                                                      Vibration.vibrate(
                                                          duration: 100);
                                                    }
                                                    await qrController!
                                                        .pauseCamera();
                                                    if (activeDialog == false) {
                                                      setState(() {
                                                        activeDialog = true;
                                                      });
                                                      await showQrAndBarCodeDialogue(
                                                        context: context,
                                                        title: translation(
                                                                context)
                                                            .barCodeDetected,
                                                        content: result!.code!,
                                                        browserView: () {
                                                          _openBrowserWithSearch(
                                                              result!.code!);
                                                        },
                                                        onCopy: () async {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: result!
                                                                      .code!));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .clearSnackBars();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(SnackBar(
                                                                  content: Text(
                                                                      translation(
                                                                              context)
                                                                          .copiedToClipboard)));
                                                          Navigator.pop(
                                                              context);
                                                          await controller
                                                              .resumeCamera();
                                                          setState(() {
                                                            activeDialog =
                                                                false;
                                                          });
                                                        },
                                                        onSave: () async {
                                                          cameraProvider
                                                              .saveBarCodeText(
                                                                  result!.code!,
                                                                  context);
                                                          Navigator.pop(
                                                              context);
                                                          await controller
                                                              .resumeCamera();
                                                          setState(() {
                                                            activeDialog =
                                                                false;
                                                          });
                                                        },
                                                        cancle: () async {
                                                          setState(() {
                                                            activeDialog =
                                                                false;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                          await controller
                                                              .resumeCamera();
                                                        },
                                                      );
                                                    }
                                                  } else if (result != null &&
                                                      activePage == 0 &&
                                                      !barCodeList.contains(
                                                          result!.format
                                                              .formatName)) {
                                                    if (beepValue) {
                                                      await audioPlayer.play(
                                                          AssetSource(
                                                              'audio/beep_sound.mp3'));
                                                    }
                                                    if (vibrationValue) {
                                                      Vibration.vibrate(
                                                          duration: 100);
                                                    }

                                                    await qrController!
                                                        .pauseCamera();
                                                    if (activeDialog == false) {
                                                      setState(() {
                                                        activeDialog = true;
                                                      });
                                                      await showQrAndBarCodeDialogue(
                                                        context: context,
                                                        title:
                                                            translation(context)
                                                                .qrCodeDetected,
                                                        content: result!.code!,
                                                        browserView: () {
                                                          _openBrowserWithSearch(
                                                              result!.code!);
                                                        },
                                                        onCopy: () async {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text: result!
                                                                      .code!));
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .clearSnackBars();
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  SnackBar(
                                                                      content:
                                                                          Text(
                                                            translation(context)
                                                                .copiedToClipboard,
                                                          )));
                                                          Navigator.pop(
                                                              context);
                                                          await controller
                                                              .resumeCamera();
                                                          setState(() {
                                                            activeDialog =
                                                                false;
                                                          });
                                                        },
                                                        onSave: () async {
                                                          cameraProvider
                                                              .saveQRCodeText(
                                                                  result!.code!,
                                                                  context);
                                                          Navigator.pop(
                                                              context);
                                                          await controller
                                                              .resumeCamera();
                                                          setState(() {
                                                            activeDialog =
                                                                false;
                                                          });
                                                        },
                                                        cancle: () async {
                                                          setState(() {
                                                            activeDialog =
                                                                false;
                                                          });
                                                          Navigator.pop(
                                                              context);
                                                          await controller
                                                              .resumeCamera();
                                                        },
                                                      );
                                                    }
                                                  }
                                                },
                                                onError: (error) {
                                                  log("Error: $error");
                                                },
                                              );
                                            },
                                            overlay: QrScannerOverlayShape(
                                              borderColor: Colors.red,
                                              borderLength: 30,
                                              borderWidth: 3,
                                              cutOutWidth: activePage == 1
                                                  ? MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.95
                                                  : MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.72,
                                              cutOutHeight: activePage == 1
                                                  ? MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.66
                                                  : MediaQuery.sizeOf(context)
                                                          .width *
                                                      0.72,
                                            ),
                                            onPermissionSet: (ctrl, p) {},
                                          ),
                                          !activeDialog
                                              ? Lottie.asset(
                                                  AppAssets.scanning,
                                                  width: activePage == 1
                                                      ? MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.95
                                                      : MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.72,
                                                  height: activePage == 1
                                                      ? MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.66
                                                      : MediaQuery.sizeOf(
                                                                  context)
                                                              .width *
                                                          0.72,
                                                  fit: BoxFit.fill,
                                                )
                                              : const SizedBox.shrink(),
                                        ],
                                      )
                                    : Container(
                                        color: Colors.blue,
                                      ),
                                gridview
                                    ? const Stack(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              VerticalDivider(),
                                              VerticalDivider(),
                                            ],
                                          ),
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            children: [
                                              Divider(),
                                              Divider(),
                                              Divider(),
                                            ],
                                          )
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          Container(
                            decoration: const BoxDecoration(
                              color: Colors.black,
                            ),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            height: size.width >= 600 ? 170 : 140,
                            width: MediaQuery.sizeOf(context).width,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const CircleAvatar(
                                  radius: 5,
                                  backgroundColor: AppColor.primaryColor,
                                ),
                                Expanded(
                                  child: PageView.builder(
                                    itemCount:
                                        cameraProvider.documentTypes.length,
                                    controller: _pageController,
                                    scrollDirection: Axis.horizontal,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    onPageChanged: (index) async {
                                      cameraProvider.idCardImages.clear();
                                      cameraProvider.imageList.clear();

                                      setState(() {
                                        activePage = index;
                                      });

                                      if (vibrationValue) {
                                        Vibration.vibrate(duration: 100);
                                      }

                                      // if (index == 0 || index == 1) {
                                      //   initCamera();
                                      //   setState(() {
                                      //     flash = false;
                                      //   });
                                      // }
                                      // if (index == 1) {
                                      //   cameraProvider.clearIdCardImages();
                                      // }

                                      if (index == 0 || index == 1) {
                                        setState(() {
                                          gridview = false;
                                        });
                                      }
                                    },
                                    itemBuilder: (context, index) {
                                      return TextButton(
                                        onPressed: () {
                                          log("onPress Detected");
                                          _pageController.animateToPage(index,
                                              duration: const Duration(
                                                  milliseconds: 500),
                                              curve: Curves.easeIn);
                                        },
                                        child: Text(
                                            getCameraModeName(
                                                cameraProvider
                                                    .documentTypes[index],
                                                context),
                                            style: TextStyle(
                                                color: activePage == index
                                                    ? AppColor.primaryColor
                                                    : Colors.white,
                                                fontSize: 14)),
                                      );
                                    },
                                  ),
                                ),
                                // Padding(
                                //   padding: const EdgeInsets.symmetric(
                                //       horizontal: 10),
                                //   child: Row(
                                //     mainAxisAlignment:
                                //         MainAxisAlignment.spaceBetween,
                                //     children: [
                                // GestureDetector(
                                //   onTap: () {
                                //     if (widget.isComeFromRetake != null &&
                                //         widget.isComeFromRetake == true) {
                                //       Navigator.pop(context);
                                //     } else if (widget.isComeFromAdd !=
                                //             null &&
                                //         widget.isComeFromAdd == true) {
                                //       Navigator.pop(context);
                                //     } else if (widget
                                //                 .isComeFromIdCardRetake !=
                                //             null &&
                                //         widget.isComeFromIdCardRetake ==
                                //             true) {
                                //       Navigator.pop(context);
                                //     } else {
                                //       cameraProvider.clearImageList();
                                //       cameraProvider.clearIdCardImages();
                                //       Navigator.pop(context);
                                //     }
                                //   },
                                //   child: Text(
                                //     translation(context).cancel,
                                //     style: const TextStyle(
                                //         color: Colors.white),
                                //   ),
                                // ),
                                // Visibility(
                                //   maintainSize: true,
                                //   maintainAnimation: true,
                                //   maintainState: true,
                                //   visible:
                                //       activePage == 0 || activePage == 1
                                //           ? true
                                //           : false,
                                //   child: GestureDetector(
                                //     onTap: () async {
                                //       if (activePage == 0) {
                                //         if (widget.isComeFromRetake ==
                                //             true) {
                                //           // XFile documentCapture =

                                //           if (Platform.isAndroid) {
                                //             if (beepValue) {
                                //               await audioPlayer.play(
                                //                   AssetSource(
                                //                       "audio/sound.mp3"));
                                //             }
                                //           }

                                //           await cameraController
                                //               .takePicture()
                                //               .then((value) async {
                                //             cameraProvider.updateImage(
                                //               index: widget.imageIndex!,
                                //               image: ImageModel(
                                //                 imageByte: await value
                                //                     .readAsBytes(),
                                //                 name: widget
                                //                     .imageModel!.name,
                                //                 docType: "Document",
                                //               ),
                                //             );
                                //           });
                                //           //Navigator.push(context,  MaterialPageRoute(builder: (context)=>const ImagePreviewScreen(),),);

                                //           Navigator.pop(context);
                                //         } else if (widget.isComeFromAdd ==
                                //             true) {
                                //           if (Platform.isAndroid) {
                                //             if (beepValue) {
                                //               await audioPlayer.play(
                                //                   AssetSource(
                                //                       "audio/sound.mp3"));
                                //             }
                                //           }

                                //           XFile documentCapture =
                                //               await cameraController
                                //                   .takePicture();
                                //           String imageName =
                                //               DateFormat('yyyyMMdd_SSSS')
                                //                   .format(DateTime.now());
                                //           cameraProvider
                                //               .addImageSpecipicIndex([
                                //             ImageModel(
                                //               imageByte:
                                //                   await documentCapture
                                //                       .readAsBytes(),
                                //               name: "Doc-$imageName",
                                //               docType: "Document",
                                //             )
                                //           ], widget.imageIndex! + 1);
                                //           Navigator.pop(context,
                                //               widget.imageIndex! + 1);
                                //         } else {
                                //           if (Platform.isAndroid) {
                                //             if (beepValue) {
                                //               await audioPlayer.play(
                                //                   AssetSource(
                                //                       "audio/sound.mp3"));
                                //             }
                                //           }
                                //           XFile documentCapture =
                                //               await cameraController
                                //                   .takePicture();
                                //           String imageName =
                                //               DateFormat('yyyyMMdd_SSSS')
                                //                   .format(DateTime.now());
                                //           cameraProvider.addImage(
                                //             ImageModel(
                                //               imageByte:
                                //                   await documentCapture
                                //                       .readAsBytes(),
                                //               name: "Doc-$imageName",
                                //               docType: "Document",
                                //             ),
                                //           );
                                //         }
                                //       } else if (activePage == 1) {
                                //         if (Platform.isAndroid) {
                                //           if (beepValue) {
                                //             await audioPlayer.play(
                                //                 AssetSource(
                                //                     "audio/sound.mp3"));
                                //           }
                                //         }
                                //         XFile idCardCapture =
                                //             await cameraController
                                //                 .takePicture();

                                //         if (widget.isComeFromIdCardRetake !=
                                //                 null &&
                                //             widget.isComeFromIdCardRetake ==
                                //                 true) {
                                //           if (widget.isFront != null &&
                                //               widget.isFront == true) {
                                //             cameraProvider
                                //                 .updateIdCardImage(
                                //                     index: 0,
                                //                     imagePath:
                                //                         idCardCapture
                                //                             .path);
                                //             Navigator.push(
                                //               context,
                                //               MaterialPageRoute(
                                //                 builder: (context) =>
                                //                     const IdCardImagePreview(),
                                //               ),
                                //             );
                                //           } else {
                                //             cameraProvider
                                //                 .updateIdCardImage(
                                //                     index: 1,
                                //                     imagePath:
                                //                         idCardCapture
                                //                             .path);
                                //             flipCardController.flipcard();
                                //             Navigator.push(
                                //               context,
                                //               MaterialPageRoute(
                                //                 builder: (context) =>
                                //                     const IdCardImagePreview(),
                                //               ),
                                //             );
                                //           }
                                //         } else {
                                //           cameraProvider.addIdCardImage(
                                //               idCardCapture.path);
                                //           flipCardController.flipcard();
                                //           if (cameraProvider
                                //                   .idCardImages.length ==
                                //               2) {
                                //             Navigator.push(
                                //               context,
                                //               MaterialPageRoute(
                                //                 builder: (context) =>
                                //                     IdCardImagePreview(
                                //                   isCameFromRetake:
                                //                       widget.isComeFromRetake !=
                                //                                   null &&
                                //                               widget.isComeFromRetake ==
                                //                                   true
                                //                           ? true
                                //                           : null,
                                //                   imageIndex:
                                //                       widget.imageIndex,
                                //                 ),
                                //               ),
                                //             );
                                //           }
                                //         }
                                //       }
                                //     },
                                //     onTapDown: (details) {
                                //       setState(() {
                                //         _isCapturePressed = true;
                                //       });
                                //     },
                                //     onTapUp: (details) {
                                //       setState(() {
                                //         _isCapturePressed = false;
                                //       });
                                //     },
                                //     onTapCancel: () {
                                //       setState(() {
                                //         _isCapturePressed = false;
                                //       });
                                //     },
                                //     child: SvgPicture.asset(
                                //       AppAssets.cameraCaptureButton,
                                //       color: _isCapturePressed
                                //           ? AppColor.primaryColor
                                //           : Colors.white,
                                //       width: size.width >= 600 ? 70 : 55,
                                //       height: size.width >= 600 ? 70 : 55,
                                //     ),
                                //   ),
                                // ),
                                // Visibility(
                                //   maintainSize: true,
                                //   maintainAnimation: true,
                                //   maintainState: true,
                                //   visible: activePage == 0 ? true : false,
                                //   child: GestureDetector(
                                //     onTap: () {
                                //       if (cameraProvider
                                //           .imageList.isNotEmpty) {
                                //         Navigator.pushAndRemoveUntil(
                                //           context,
                                //           MaterialPageRoute(
                                //             builder: (context) =>
                                //                 const ImagePreviewScreen(),
                                //           ),
                                //           (route) => false,
                                //         );
                                //       }
                                //     },
                                //     child: badges.Badge(
                                //       badgeContent: Text(
                                //           cameraProvider.imageList.length
                                //               .toString(),
                                //           style: const TextStyle(
                                //             color: Colors.black,
                                //             fontSize: 12,
                                //           )),
                                //       badgeStyle: const badges.BadgeStyle(
                                //         badgeColor: Colors.white,
                                //       ),
                                //       showBadge: cameraProvider
                                //           .imageList.isNotEmpty,
                                //       child: Container(
                                //         height:
                                //             size.width >= 600 ? 50 : 40,
                                //         width:
                                //             size.width >= 600 ? 50 : 40,
                                //         decoration: BoxDecoration(
                                //           borderRadius:
                                //               BorderRadius.circular(10),
                                //           border: Border.all(
                                //             color: Colors.white,
                                //             width: 2,
                                //           ),
                                //         ),
                                //         child: cameraProvider
                                //                 .imageList.isEmpty
                                //             ? Icon(
                                //                 Icons.image_rounded,
                                //                 color: Colors.white,
                                //                 size: size.width >= 600
                                //                     ? 40
                                //                     : 30,
                                //               )
                                //             : Image.memory(
                                //                 cameraProvider.imageList
                                //                     .last.imageByte,
                                //               ),
                                //       ),
                                //     ),
                                //   ),
                                //       // ),
                                //     ],
                                //   ),
                                // ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
        ),
      ),
    );
  }

  String getCameraModeName(String name, BuildContext context) {
    switch (name) {
      case "QR Code":
        return translation(context).qrCode;
      case "Bar Code":
        return translation(context).barCode;
      default:
        return "";
    }
  }
}
