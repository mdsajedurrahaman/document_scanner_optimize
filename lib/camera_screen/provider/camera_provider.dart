import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:gal/gal.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:doc_scanner/home_page/provider/home_page_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:provider/provider.dart';
import 'package:pdf_render/pdf_render.dart' as pdfRender;
import '../model/image_model.dart';

class CameraProvider extends ChangeNotifier {
  final List<String> _documentType = ['QR Code', 'Bar Code'];
  List<String> get documentTypes => _documentType;

  final List<ImageModel> _imageList = [];
  List<ImageModel> get imageList => _imageList;

  void addImage(ImageModel image) {
    _imageList.add(image);
    notifyListeners();
  }

  void addImageSpecipicIndex(List<ImageModel> image, int index) {
    _imageList.insertAll(index, image);
    notifyListeners();
  }

  void updateImage({required int index, required ImageModel image}) {
    _imageList[index] = image;
    notifyListeners();
  }

  void deleteImage(int index) {
    _imageList.removeAt(index);
    notifyListeners();
  }

  void clearImageList() {
    _imageList.clear();
    notifyListeners();
  }

  List<String> _idCardImages = [];
  List<String> get idCardImages => _idCardImages;

  void addIdCardImage(String imagePath) {
    _idCardImages.add(imagePath);
    notifyListeners();
  }

  void updateIdCardImage({required int index, required String imagePath}) {
    _idCardImages[index] = imagePath;
    notifyListeners();
  }

  void reverseIdCardImages() {
    _idCardImages = _idCardImages.reversed.toList();
    notifyListeners();
  }

  void clearIdCardImages() {
    _idCardImages.clear();
    notifyListeners();
  }

  void replaceIdCardImage({required int index, required String imagePath}) {
    _idCardImages[index] = imagePath;
    notifyListeners();
  }

  Future<void> exportAllImages() async {
    final Directory appDirectory = await getApplicationDocumentsDirectory();
    final String documentDirectoryPath =
        '${appDirectory.path}/Doc Scanner/Document';

    for (int i = 0; i < _imageList.length; i++) {
      final Uint8List bytes = _imageList[i].imageByte;

      // Base file path
      String imagePath = '$documentDirectoryPath/${_imageList[i].name}.jpg';
      File imageFile = File(imagePath);

      // Check if file exists and generate a unique file name
      int duplicateCount = 1;
      while (await imageFile.exists()) {
        imagePath =
            '$documentDirectoryPath/${_imageList[i].name}_$duplicateCount.jpg';
        imageFile = File(imagePath);
        duplicateCount++;
      }

      // Write the file and add to the gallery
      await imageFile.writeAsBytes(bytes);
      Gal.putImage(imageFile.path);
    }
  }

  Future<void> saveQRCodeText(String text, BuildContext context) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    final fileName = DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
    String filePath = '${appDir.path}/Doc Scanner/QR Code/QrCode-$fileName.txt';
    File file = File(filePath);
    await file.writeAsString(text);
    context.read<HomePageProvider>().addQrCodeFile(filePath);
  }

  Future<void> saveBarCodeText(String text, BuildContext context) async {
    Directory appDir = await getApplicationDocumentsDirectory();
    final fileName = DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
    String filePath =
        '${appDir.path}/Doc Scanner/Bar Code/BarCode$fileName.txt';
    File file = File(filePath);
    await file.writeAsString(text);
    context.read<HomePageProvider>().addBarCodeFile(filePath);
  }

  Future<File?> createPDFFromByte({
    required BuildContext context,
    required String fileName,
  }) async {
    try {
      _isCreatingPDFLoader = true;
      notifyListeners();
      String directoryPath;
      final List<Uint8List> images =
          _imageList.map((e) => e.imageByte).toList();
      final Directory appDirectory = await getApplicationDocumentsDirectory();

      directoryPath = '${appDirectory.path}/Doc Scanner/Document';

      final pdf = pw.Document();

      for (var imageData in images) {
        final pdfImage = pw.MemoryImage(imageData);
        pdf.addPage(
          pw.Page(
            clip: false,
            pageFormat: PdfPageFormat.a4,
            margin: const pw.EdgeInsets.all(0),
            build: (pw.Context context) {
              return pw.Center(
                child: pw.Image(
                  pdfImage,
                  fit: pw.BoxFit.fill,
                ),
              );
            },
          ),
        );
      }
      int index = 1;
      String newFileName = fileName;
      while (File('$directoryPath/$newFileName.pdf').existsSync()) {
        newFileName = '$fileName($index)';
        index++;
      }
      final File file = File('$directoryPath/$newFileName.pdf');
      final bytes = await pdf.save();
      final pdfFile = await file.writeAsBytes(bytes, flush: true);
      if (Platform.isIOS) {
        Directory iosDocumentsDirectory =
            await getApplicationDocumentsDirectory();
        File iOSExternalFile = File(
            "${iosDocumentsDirectory.path}/Doc Scanner/Document/$fileName.pdf");

        final pdfBytes = await pdf.save();
        await iOSExternalFile.writeAsBytes(pdfBytes);
        debugPrint("PDF saved to iOS: ${iOSExternalFile.path}");
      } else if (Platform.isAndroid) {
        final externalStorageDirectory =
            Directory('/storage/emulated/0/Documents/Document');
        if (!await externalStorageDirectory.exists()) {
          await externalStorageDirectory.create(recursive: true);
        }
        File externalFile =
            File("${externalStorageDirectory.path}/$newFileName.pdf");

        // Write to both locations
        final pdfBytes = await pdf.save();
        await externalFile.writeAsBytes(pdfBytes);
      }

      _isCreatingPDFLoader = false;
      notifyListeners();
      return pdfFile;
    } catch (e) {
      _isCreatingPDFLoader = false;
      notifyListeners();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating PDF: $e'),
        ),
      );
      return null;
    }
  }

  bool isSavePDFLoader = false;

  bool _isCreatingPDFLoader = false;
  bool get isCreatingPDFLoader => _isCreatingPDFLoader;

  bool _pdfConverting = false;
  bool get pdfConverting => _pdfConverting;

  Future<bool> convertPdfToImage(File pdfFile) async {
    try {
      _pdfConverting = true;
      notifyListeners();
      final doc = await pdfRender.PdfDocument.openFile(pdfFile.path);
      final totalPages = doc.pageCount;

      for (int i = 1; i <= totalPages; i++) {
        final page = await doc.getPage(i);
        final pageImage = await page.render();
        final pngBytes = await pageImage.createImageIfNotAvailable();
        final byteData = await pngBytes.toByteData(format: ImageByteFormat.png);
        final imageByte = byteData!.buffer.asUint8List();
        final fileName = DateFormat('yyyyMMdd_SSSS').format(DateTime.now());
        _imageList.add(
          ImageModel(
            imageByte: imageByte,
            name: "Doc-$fileName",
            docType: 'Document',
          ),
        );
        pageImage.dispose();
      }
      await doc.dispose();
      _pdfConverting = false;
      notifyListeners();
      return true;
    } catch (e) {
      log(e.toString());
      _pdfConverting = false;
      notifyListeners();
      return false;
    }
  }
}
