import 'package:doc_scanner/camera_screen/model/image_model.dart';
import 'package:doc_scanner/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../camera_screen/provider/camera_provider.dart';
import '../image_edit/widget/image_edit_button.dart';

class EditScreen extends StatefulWidget {
  final int currentIndex;
  final PageController pageController;
  const EditScreen({super.key, required this.currentIndex, required this.pageController, });

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen> {

  late int currentPageIndex;
  @override
  void initState() {
    currentPageIndex = widget.currentIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cameraProvider = context.watch<CameraProvider>();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        centerTitle: true,
        title:  Text(
          cameraProvider.imageList[currentPageIndex].name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: SvgPicture.asset(AppAssets.editFile),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: widget.pageController,
              itemCount: cameraProvider.imageList.length,
              onPageChanged: (index) {
                setState(() {
                  currentPageIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.memory(
                  cameraProvider.imageList[currentPageIndex].imageByte,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
          Container(
            padding:
            const EdgeInsets.symmetric(horizontal: 20.0, vertical: 3),
            child: Text(
              cameraProvider.imageList.isEmpty
                  ? '$currentPageIndex/${cameraProvider.imageList.length}'
                  : '${currentPageIndex + 1}/${cameraProvider.imageList.length}',
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  fontWeight: FontWeight.w400),
            ),
          ),
          Container(
            height: 60,
            width: MediaQuery.sizeOf(context).width,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                children: [
                  ImageEditButton(
                    title: "Share",
                    onTap: () {},
                    iconPath: AppAssets.share,
                  ),
                  const Spacer(),
                  ImageEditButton(
                    title: "Edit",
                    onTap: () {},
                    iconPath: AppAssets.edit,
                  ),
                  const Spacer(),
                  ImageEditButton(
                      title: "Add Page",
                      onTap: () {},
                      iconPath: AppAssets.addPage,
                  ),
                  const Spacer(),
                  ImageEditButton(
                      title: "Convert",
                      onTap: () {},
                      iconPath: AppAssets.ocr,),
                  const Spacer(),
                  ImageEditButton(
                      title: "Sign",
                      onTap: () {


                      },
                      iconPath: AppAssets.sign),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
