import 'dart:typed_data';

import 'package:doc_scanner/image_edit/provider/image_edit_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:screenshot/screenshot.dart';
import '../localaization/language_constant.dart';
import '../utils/app_assets.dart';
import '../utils/app_color.dart';

class ImageSizeScreen extends StatefulWidget {
  const ImageSizeScreen({
    super.key,
  });

  @override
  State<ImageSizeScreen> createState() => _ImageSizeScreenState();
}

class _ImageSizeScreenState extends State<ImageSizeScreen> {
  ScreenshotController screenshotController = ScreenshotController();

  List<SizeOption> availableSizeOption = const [
    SizeOption(title: 'Original', radio: 1),
    SizeOption(title: 'A4', radio: 1 / 1.4),
    SizeOption(title: 'A5', radio: 1 / 1.5),
    SizeOption(title: 'ID Card', radio: 3 / 2),
    SizeOption(title: 'Legal', radio: 8.5 / 14),
  ];

  double _selectedRatio = 1;
  @override
  Widget build(BuildContext context) {
    final imageEditProvider = context.watch<ImageEditProvider>();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(translation(context).resize),
        titleTextStyle: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Uint8List? data = await screenshotController.capture();
              if (data != null) {
                imageEditProvider.addState(data);
                Navigator.pop(context);
              }
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
        child: Screenshot(
          controller: screenshotController,
          child: AspectRatio(
            aspectRatio: _selectedRatio,
            child: Image.memory(
              imageEditProvider.currentState,
              fit: BoxFit.fill,
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
          child: Container(
        padding: const EdgeInsets.symmetric(vertical: 4),
        height: 80,
        decoration: const BoxDecoration(color: Colors.white),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            for (var size in availableSizeOption)
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _selectedRatio = size.radio!;
                    setState(() {});
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AppAssets.size_preview,
                          color: _selectedRatio == size.radio
                              ? Colors.black
                              : Colors.grey,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Text(
                            getTitle(size, context),
                            style: TextStyle(
                              color: _selectedRatio == size.radio
                                  ? Colors.black
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
          ],
        ),
      )),
    );
  }

  String getTitle(SizeOption size, BuildContext context) {
    switch (size.title) {
      case "Original":
        return translation(context).original;
      case "A4":
        return "A4";
      case "A5":
        return "A5";
      case "ID Card":
        return translation(context).idCard;
      case "Legal":
        return translation(context).legal;
      default:
        return "";
    }
  }
}

class SizeOption {
  final String? title;
  final double? radio;

  const SizeOption({this.title, this.radio});
}
