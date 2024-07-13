import 'package:doc_scanner/camera_screen/camera_screen.dart';
import 'package:doc_scanner/home_page/directory_create_page.dart';
import 'package:doc_scanner/home_page/provider/home_page_provider.dart';
import 'package:doc_scanner/home_page/search_page.dart';
import 'package:doc_scanner/utils/app_assets.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import '../camera_screen/provider/camera_provider.dart';
import '../localaization/language_constant.dart';
import '../utils/utils.dart';
import 'directory_view.dart';
import 'model/camera_item_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomePageProvider>().clearDocumentImageFiles();
      context.read<HomePageProvider>().clearIdCardImageFiles();
      context.read<HomePageProvider>().clearQRCodeFiles();
      context.read<HomePageProvider>().clearBarCodeFiles();
      context.read<HomePageProvider>().loadDocumentImage();
      context.read<HomePageProvider>().loadIdCardImage();
      context.read<HomePageProvider>().loadQRCode();
      context.read<HomePageProvider>().loadBarCode();
      context.read<HomePageProvider>().getDirectoriesForCreate();
    });
    super.initState();
  }

  String getCameraModeName(String name, BuildContext context) {
    switch (name) {
      case "Documents":
        return translation(context).documents;
      case "ID Card":
        return translation(context).idCard;
      case "QR Code":
        return translation(context).qrCode;
      case "Bar Code":
        return translation(context).barCode;
      default:
        return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final homePageProvider = Provider.of<HomePageProvider>(context);
    final cameraProvider = Provider.of<CameraProvider>(context);
    final size =MediaQuery.sizeOf(context);
    return Scaffold(
      appBar: AppBar(
        title:  Text(translation(context).docScanner),
        titleTextStyle: const TextStyle(
            fontSize: 28, color: Colors.black, fontWeight: FontWeight.w500,

        ),
        actions: [
          GestureDetector(
            onTap: (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DirectoryCreatePage(),
                    ),
                  );

            },
              child: SvgPicture.asset(
                AppAssets.create_folder,
                height: 28,
                width: 28,


              )),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: GestureDetector(
              onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SearchPage(),
                      ),
                    );

              },
                child: SvgPicture.asset(
                  AppAssets.search,
                  height: 28,
                  width: 28,


                )),
          ),
          // IconButton(
          //   onPressed: () async {
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const DirectoryCreatePage(),
          //       ),
          //     );
          //
          //   },
          //   icon:  Icon(
          //     Icons.create_new_folder,
          //     color: AppColor.primaryColor,
          //     size: size.width >= 600? 30: 25,
          //   ),
          // ),
          // IconButton(
          //   onPressed: () async {
          //
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const SearchPage(),
          //       ),
          //     );
          //   },
          //   icon:  Icon(
          //     Icons.search,
          //     size: size.width >= 600? 30: 25,
          //   ),
          // ),



        ],
      ),
      body:

      // cameraProvider.pdfConverting
      //     ? const Center(
      //   child: CircularProgressIndicator(),
      // )
      //     :
      Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              width: MediaQuery.sizeOf(context).width,
              alignment: Alignment.center,
              height: size.width >= 600? 120: 100,
              child: Row(
                mainAxisAlignment:size.width >= 600? MainAxisAlignment.spaceAround: MainAxisAlignment.spaceEvenly,

                children: List.generate(cameraItems.length, (index) {
                  final cameraItem = cameraItems[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CameraScreen(
                                    initialPage: index,
                                  ),),);
                    },
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: size.width >= 600? 35: 30,
                          backgroundColor: cameraItem.color,
                          child: SvgPicture.asset(cameraItem.icon,
                              height: size.width >= 600? 30:25, width: size.width >= 600? 30:25),
                        ),
                        SizedBox(
                          width:  size.width >= 600? 100: 60,
                          child: Text(
                            getCameraModeName(cameraItem.name, context),
                            style: const TextStyle(fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,

                          ),
                        )
                      ],
                    ),
                  );
                }),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              width: MediaQuery.sizeOf(context).width,
              height: 100,
              alignment: Alignment.center,
              child: Row(
               mainAxisAlignment:size.width >= 600? MainAxisAlignment.spaceAround: MainAxisAlignment.spaceEvenly,
                children:
                    List.generate(homePageProvider.directories.length, (index) {
                  final directory = homePageProvider.directories[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DirectoryDetailsPage(
                              directoryPath: directory.path,
                            ),
                          ));
                    },
                    child: Container(
                      width:size.width >= 600? 90 :70,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/icons/folder_bg.png'),
                          fit: BoxFit.fill,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                           Icon(
                            Icons.folder,
                            size: size.width >= 600? 50 :40,
                            color: AppColor.primaryColor,
                          ),
                          Text(
                            path.basename(directory.path),
                            style: const TextStyle(
                              color: Colors.black,
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),

            ),
            Expanded(
              child: homePageProvider.isHistoryLoading?
                  Center(child: CircularProgressIndicator(),)
                  :



              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.235,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: homePageProvider.documentImageFiles.length,
                      itemBuilder: (context, index) {
                        final imageFile =
                            homePageProvider.documentImageFiles[index];

                        if (imageFile.path.toLowerCase().endsWith('.jpg') ||
                            imageFile.path.toLowerCase().endsWith('.jpeg') ||
                            imageFile.path.toLowerCase().endsWith('.png')) {
                          return GestureDetector(
                            onTap: () async {

                           await   flutterGenralDialogue(
                                  context: context,
                                  imageFile: imageFile,
                                  );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 90,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade200,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      height: 60,
                                      child: Image.file(
                                        imageFile,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                      child: Text(
                                        path.basename(imageFile.path),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (imageFile.path
                            .toLowerCase()
                            .endsWith('.pdf')) {
                          return GestureDetector(
                            onTap: () async {
                              await OpenFilex.open(imageFile.path);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 90,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade200,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 60,
                                      child: SvgPicture.asset(AppAssets.pdf),
                                    ),
                                    SizedBox(
                                      height: 20,
                                      child: Text(
                                        path.basename(imageFile.path),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return  Text(translation(context).somethingWentWrong);
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.235,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: homePageProvider.idCardImageFiles.length,
                      itemBuilder: (context, index) {
                        final imageFile =
                            homePageProvider.idCardImageFiles[index];

                        if (imageFile.path.toLowerCase().endsWith('.jpg') ||
                            imageFile.path.toLowerCase().endsWith('.jpeg') ||
                            imageFile.path.toLowerCase().endsWith('.png')) {
                          return GestureDetector(
                            onTap: () async {

                              await flutterGenralDialogue(
                                context: context,
                                imageFile: imageFile,
                              );
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade200,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    SizedBox(
                                      height: 60,
                                      child: Image.file(
                                        imageFile,
                                      ),
                                    ),
                                    SizedBox(
                                      height: 20,
                                      child: Text(
                                        path.basename(imageFile.path),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,

                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        } else if (imageFile.path
                            .toLowerCase()
                            .endsWith('.pdf')) {
                          return GestureDetector(
                            onTap: () async {
                              await OpenFilex.open(imageFile.path);
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                width: 90,
                                height: 100,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.grey.shade200,
                                ),
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  children: [
                                    SizedBox(
                                      height: 60,
                                      child: SvgPicture.asset(AppAssets.pdf),
                                    ),
                                    SizedBox(
                                      height: 20,
                                      child: Text(
                                        path.basename(imageFile.path),
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w400,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }
                        return  Text(translation(context).somethingWentWrong);
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.235,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: homePageProvider.qrCodeFiles.length,
                      itemBuilder: (context, index) {
                        final qrCode = homePageProvider.qrCodeFiles[index];
                        return GestureDetector(
                          onTap: () async {
                            showQrAndBarCodeViewDialogue(
                                context: context,
                                text: await homePageProvider
                                    .readTxtFile(qrCode));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 90,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade200,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 60,
                                    child: SvgPicture.asset(AppAssets.txt),
                                  ),
                                  SizedBox(
                                    height: 20,
                                    child: Text(
                                      path.basename(qrCode),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.235,
                    child: ListView.builder(
                      scrollDirection: Axis.vertical,
                      itemCount: homePageProvider.barCodeFiles.length,
                      itemBuilder: (context, index) {
                        final barCode = homePageProvider.barCodeFiles[index];
                        return GestureDetector(
                          onTap: () async {
                            showQrAndBarCodeViewDialogue(
                                context: context,
                                text: await homePageProvider
                                    .readTxtFile(barCode));
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              width: 90,
                              height: 100,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Colors.grey.shade200,
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Column(
                                children: [
                                  SizedBox(
                                    height: 60,
                                    child: SvgPicture.asset(AppAssets.txt),
                                  ),
                                  SizedBox(
                                    height: 20,
                                    child: Text(
                                      path.basename(barCode),
                                      style: const TextStyle(
                                        color: Colors.black,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<CameraItem> cameraItems = [
    CameraItem(
      name: 'Documents',
      color: const Color(0xFFFFF7EB),
      icon: AppAssets.documents,
    ),
    CameraItem(
      name: 'ID Card',
      color: const Color(0xFFFBF3F2),
      icon: AppAssets.idCard,
    ),
    CameraItem(
      name: 'QR Code',
      color: const Color(0xFFFFF1F1),
      icon: AppAssets.qrcode,
    ),
    CameraItem(
      name: 'Bar Code',
      color: const Color(0xFFEEF0FD),
      icon: AppAssets.barCode,
    ),
  ];
}
