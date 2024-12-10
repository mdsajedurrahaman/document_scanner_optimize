import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:doc_scanner/bottom_bar/bottom_bar.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:doc_scanner/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:interactive_box/interactive_box.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';

class IdCardImagePreview extends StatefulWidget {
  final bool? isCameFromRetake;
  final int? imageIndex;

  const IdCardImagePreview({super.key, this.isCameFromRetake, this.imageIndex});

  @override
  State<IdCardImagePreview> createState() => _IdCardImagePreviewState();
}

class _IdCardImagePreviewState extends State<IdCardImagePreview> {
  bool isLoading = false;
  List<Map<String, dynamic>> imageProperties = [];

  @override
  void initState() {
    super.initState();
    final cameraProvider = context.read<CameraProvider>();
    imageProperties = cameraProvider.idCardImages.map((imagePath) {
      int index = cameraProvider.idCardImages.indexOf(imagePath);
      return {
        'path': imagePath,
        'position': Offset(25 + (index * 150), 150),
        'size': const Size(150, 150), // Initial size
      };
    }).toList();
  }

  final GlobalKey _globalKey = GlobalKey();

  void showTopSnackbar(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 10.0,
        left: 0,
        right: 0,
        child: TopSnackbar(message: message),
      ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  Future<Uint8List> captureWidgetToImage() async {
    try {
      RenderRepaintBoundary boundary = _globalKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;

      // Determine pixel ratio for high-resolution output
      double pixelRatio =
          1080 / boundary.size.width; // A4 height in pixels / widget height
      var image = await boundary.toImage(
        pixelRatio: pixelRatio,
      );
      ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
      if (byteData == null) {
        throw Exception("Failed to capture widget to image.");
      }
      return byteData.buffer.asUint8List();
    } catch (e) {
      throw Exception("Error capturing image: $e");
    }
  }

  Future<void> exportToPdf(String fileName) async {
    setState(() {
      isLoading = true;
    });
    try {
      // Capture the widget as an image
      Uint8List imageBytes = await captureWidgetToImage();
      // Create a PDF document
      final pdf = pw.Document();
      final image = pw.MemoryImage(imageBytes);
      // Define A4 dimensions with zero margins
      final pageFormat = PdfPageFormat.a4.copyWith(
        marginLeft: 0,
        marginRight: 0,
        marginTop: 0,
        marginBottom: 0,
      );
      // Add an A4 page with the captured image
      pdf.addPage(
        pw.Page(
          pageFormat: pageFormat,
          build: (context) {
            return pw.Center(
              widthFactor: double.infinity,
              child: pw.Image(
                image,
                fit: pw.BoxFit.contain, // Ensures full fit without cropping
              ),
            );
          },
        ),
      );
      // Define file path and save PDF
      final rootDirectory = await getApplicationDocumentsDirectory();
      String path = "${rootDirectory.path}/Doc Scanner/ID Card";
      File file = File("$path/$fileName.pdf");

      // Create directories if they don't exist
      if (!await file.parent.exists()) {
        await file.parent.create(recursive: true);
      }
      await file.writeAsBytes(await pdf.save());
      setState(() {
        isLoading = false;
      });
      // Notify user of successful save
      showTopSnackbar(context, "PDF successfully saved");
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      // Notify user of failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save PDF: $e')),
      );
    }
  }

  Future<void> saveImageToFile(Uint8List imageBytes) async {
    try {
      final rootDirectory = await getApplicationDocumentsDirectory();
      String path = "${rootDirectory.path}/Doc Scanner/ID Card";
      Directory directory = Directory(path);

      // Ensure the directory exists
      if (!directory.existsSync()) {
        directory.createSync(recursive: true);
      }

      // Save the file as JPG
      File file = File('$path/exported_image.jpg');
      await file.writeAsBytes(imageBytes);
      print('Image saved at ${file.path}');
    } catch (e) {
      print("Error saving image: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    final size = MediaQuery.sizeOf(context);
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
          builder: (context) {
            return const BottomBar();
          },
        ), (route) => false)
            .then((value) => cameraProvider.clearIdCardImages());
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xff1E1F20),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Colors.white,
            ),
            onPressed: () async {
              cameraProvider.clearIdCardImages();
              await Navigator.pushAndRemoveUntil(context, MaterialPageRoute(
                builder: (context) {
                  return const BottomBar();
                },
              ), (route) => false);
            },
          ),
          title: Text(
            translation(context).idCardImagePreview,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white),
          ),
          actions: [
            GestureDetector(
              onTap: () async {
                await showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return Container(
                      height: MediaQuery.sizeOf(context).height * 0.3,
                      width: MediaQuery.sizeOf(context).width,
                      decoration: const BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          color: Colors.white),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10)
                                .copyWith(top: 20, bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(''),
                                Text(
                                  translation(context).documentFiles,
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Container(
                                  height: size.width >= 600 ? 40 : 30,
                                  width: size.width >= 600 ? 40 : 30,
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
                                      child: Icon(
                                        Icons.close_rounded,
                                        size: size.width >= 600 ? 30 : 20,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey[200],
                            thickness: 1,
                            // indent: MediaQuery.sizeOf(context).width * 0.15,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                showNormalAlertDialogue(
                                  context: context,
                                  title: translation(context).saveImages,
                                  content: translation(context)
                                      .doYouWantSaveAllImages,
                                  onOkText: translation(context).save,
                                  onCancelText: translation(context).cancel,
                                  onOk: () async {
                                    try {
                                      Uint8List imageBytes =
                                          await captureWidgetToImage();
                                      await saveImageToFile(imageBytes);
                                      Navigator.pop(context);
                                    } catch (e) {
                                      print("Error: $e");
                                    }
                                  },
                                  onCancel: () => Navigator.pop(context),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.ios_share_outlined,
                                      color: Colors.black,
                                      size: size.width >= 600 ? 30 : 20,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      translation(context).exportImages,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.grey[200],
                            thickness: 1,
                            // indent: MediaQuery.sizeOf(context).width * 0.15,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () async {
                                await showDialog(
                                  context: context,
                                  builder: (context) {
                                    // final cameProvider =
                                    //     context.watch<CameraProvider>();
                                    TextEditingController renameController =
                                        TextEditingController();
                                    return StatefulBuilder(
                                      builder: (context, setState) {
                                        return AlertDialog(
                                          title: Text(
                                              translation(context).savePdf),
                                          content: cameraProvider
                                                  .isCreatingPDFLoader
                                              ? ConstrainedBox(
                                                  constraints:
                                                      const BoxConstraints(
                                                          maxHeight: 40,
                                                          maxWidth: 40),
                                                  child: const Center(
                                                    child:
                                                        CircularProgressIndicator(
                                                      color:
                                                          AppColor.primaryColor,
                                                    ),
                                                  ),
                                                )
                                              : TextFormField(
                                                  controller: renameController,
                                                  keyboardType:
                                                      TextInputType.text,
                                                  textInputAction:
                                                      TextInputAction.done,
                                                  autofocus: true,
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return translation(
                                                              context)
                                                          .pleaseEnterFileName;
                                                    }
                                                    return null;
                                                  },
                                                  decoration: InputDecoration(
                                                    hintText:
                                                        translation(context)
                                                            .enterFileName,
                                                    border:
                                                        const OutlineInputBorder(
                                                      borderSide: BorderSide(
                                                          color: AppColor
                                                              .primaryColor),
                                                    ),
                                                    contentPadding:
                                                        const EdgeInsets
                                                            .symmetric(
                                                            horizontal: 10),
                                                  ),
                                                ),
                                          actions: [
                                            TextButton(
                                              onPressed: () async {
                                                if (renameController
                                                    .text.isNotEmpty) {
                                                  await exportToPdf(
                                                      renameController.text
                                                          .trim());
                                                  cameraProvider
                                                      .clearIdCardImages();

                                                  Navigator.pushAndRemoveUntil(
                                                      context,
                                                      MaterialPageRoute(
                                                    builder: (context) {
                                                      return const BottomBar(
                                                        shouldShowReview: true,
                                                      );
                                                    },
                                                  ), (route) => false);
                                                  // showTopSnackbar(context,
                                                  //     "PDF successfully saved");
                                                }
                                              },
                                              child:
                                                  Text(translation(context).ok),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text(
                                                  translation(context).cancel),
                                            )
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 5),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.picture_as_pdf_outlined,
                                      color: Colors.black,
                                      size: size.width >= 600 ? 30 : 20,
                                    ),
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    Text(
                                      translation(context).exportAsPdf,
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Text(
                translation(context).option,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColor.primaryColor,
                ),
              ),
            ),
          ],
        ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RepaintBoundary(
                key: _globalKey, // Assign the global key
                child: Center(
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      children: imageProperties.asMap().entries.map((entry) {
                        final index = entry.key;
                        final imageProps = entry.value;

                        return InteractiveBox(
                          initialPosition: imageProps['position'],
                          initialSize: imageProps['size'],
                          includedScaleDirections: const [
                            ScaleDirection.topRight,
                            ScaleDirection.bottomRight,
                            ScaleDirection.bottomLeft,
                            ScaleDirection.topLeft,
                          ],
                          includedActions: const [
                            ControlActionType.move,
                            ControlActionType.scale,
                            ControlActionType.rotate,
                          ],
                          onActionSelected: (ControlActionType actionType,
                              InteractiveBoxInfo info) {
                            setState(() {
                              if (actionType == ControlActionType.delete) {
                                imageProperties.removeAt(index);
                              } else {
                                imageProperties[index]['position'] =
                                    info.position;
                                imageProperties[index]['size'] = info.size;
                              }
                            });
                          },
                          child: Image.file(
                            File(imageProps['path']),
                            fit: BoxFit.contain,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}
