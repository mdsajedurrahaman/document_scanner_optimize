import 'dart:io';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../localaization/language_constant.dart';

class TextRecognitionScreen extends StatefulWidget {
  final String recognisedText;
  const TextRecognitionScreen({super.key, required this.recognisedText});

  @override
  State<TextRecognitionScreen> createState() => _TextRecognitionScreenState();
}

class _TextRecognitionScreenState extends State<TextRecognitionScreen> {
  TextEditingController textEditingController = TextEditingController();

  @override
  void initState() {
    textEditingController.text = widget.recognisedText;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          translation(context).recognizeText,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) {
                  TextEditingController renameController =
                      TextEditingController();
                  return AlertDialog(
                    title: const Text("PDF"),
                    content: TextFormField(
                      controller: renameController,
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.done,
                      autofocus: true,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return translation(context).pleaseEnterFileName;
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        hintText: translation(context).enterFileName,
                        focusedBorder: const OutlineInputBorder(
                          borderSide: BorderSide(color: AppColor.primaryColor),
                        ),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(translation(context).cancel),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (renameController.text.isNotEmpty) {
                            Navigator.pop(context);
                            final pdf = pw.Document();
                            pdf.addPage(
                              pw.Page(
                                build: (pw.Context context) => pw.Center(
                                  child: pw.Text(textEditingController.text),
                                ),
                              ),
                            );
                            final applicationDirectory =
                                await getApplicationDocumentsDirectory();
                            final savePath =
                                '${applicationDirectory.path}/Doc Scanner/Document/${renameController.text}.pdf';
                            final file = File(savePath);
                            await file
                                .writeAsBytes(await pdf.save(), flush: true)
                                .then((value) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                      translation(context)
                                          .pdfFileSavedAtDocumentDirectory,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            });
                          } else {
                            ScaffoldMessenger.of(context).clearSnackBars();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                duration: const Duration(seconds: 1),
                                content: Text(
                                  translation(context).pleaseEnterFileName,
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(translation(context).ok),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text(
              translation(context).save,
              style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: AppColor.primaryColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: TextField(
          controller: textEditingController,
          maxLines: null,
          decoration: const InputDecoration(
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
