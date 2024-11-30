import 'dart:developer';
import 'dart:io';
import 'package:doc_scanner/home_page/provider/home_page_provider.dart';
import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class DirectoryCreatePage extends StatefulWidget {
  const DirectoryCreatePage({super.key});

  @override
  State<DirectoryCreatePage> createState() => _DirectoryCreatePageState();
}

class _DirectoryCreatePageState extends State<DirectoryCreatePage> {
  Directory? selectedDirectory;
  final TextEditingController _directoryNameController =
      TextEditingController();
  final formKey = GlobalKey<FormState>();
  bool _directoryAlreadyExists = false;

  @override
  Widget build(BuildContext context) {
    final homePageProvider = context.watch<HomePageProvider>();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          translation(context).createDirectory,
          style: const TextStyle(fontSize: 18),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              DropdownButtonFormField(
                value: selectedDirectory,
                items: homePageProvider.directories
                    .map((e) => DropdownMenuItem<Directory>(
                        value: e, child: Text(e.path.split("/").last)))
                    .toList(),
                onChanged: (Directory? value) {
                  setState(() {
                    selectedDirectory = value;
                  });
                },
                hint: Text(translation(context).selectDirectory),
                validator: (value) {
                  if (value == null) {
                    return translation(context).pleaseSelectADirectory;
                  }
                  return null;
                },
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _directoryNameController,
                decoration: InputDecoration(
                  errorText: _directoryAlreadyExists
                      ? 'Directory already exists'
                      : null,
                  hintText: translation(context).enterDirectoryName,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value!.isEmpty) {
                    return translation(context).pleaseEnterADirectoryName;
                  }
                  return null;
                },
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.primaryColor,
                  fixedSize: Size(MediaQuery.sizeOf(context).width, 50),
                ),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    if (_directoryNameController.text.trim().isNotEmpty) {
                      FocusScope.of(context).unfocus();
                      bool created = await createDirectory(
                          targetDirectory: selectedDirectory!,
                          directoryName: _directoryNameController.text);
                      if (created) {
                        Navigator.pop(context);
                      }
                      setState(() {
                        _directoryAlreadyExists = !created;
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            translation(context).pleaseEnterADirectoryName,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  translation(context).createDirectory,
                  style: const TextStyle(color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> createDirectory({
    required Directory targetDirectory,
    required String directoryName,
  }) async {
    Directory rootDirectory = await getApplicationDocumentsDirectory();
    final documentDirectory =
        Directory('${rootDirectory.path}/Doc Scanner/Document');
    final idCardDirectory =
        Directory('${rootDirectory.path}/Doc Scanner/ID Card');
    final qrCodeDirectory =
        Directory('${rootDirectory.path}/Doc Scanner/QR Code');
    final barCodeDirectory =
        Directory('${rootDirectory.path}/Doc Scanner/Bar Code');

    try {
      if (await _directoryExistsWithCaseInsensitive(
              documentDirectory, directoryName) ||
          await _directoryExistsWithCaseInsensitive(
              idCardDirectory, directoryName) ||
          await _directoryExistsWithCaseInsensitive(
              qrCodeDirectory, directoryName) ||
          await _directoryExistsWithCaseInsensitive(
              barCodeDirectory, directoryName)) {
        return false;
      } else {
        final newCreatedDirectory =
            Directory('${targetDirectory.path}/$directoryName');
        await newCreatedDirectory.create(recursive: true);
        return true;
      }
    } catch (e) {
      return false;
    }
  }

  Future<bool> _directoryExistsWithCaseInsensitive(
      Directory parentDirectory, String directoryName) async {
    try {
      final List<FileSystemEntity> entities =
          await parentDirectory.list().toList();
      for (final entity in entities) {
        if (entity is Directory &&
            entity.path.split('/').last.toLowerCase() ==
                directoryName.toLowerCase()) {
          return true;
        }
      }
    } catch (e) {
      log(e.toString());
    }
    return false;
  }
}
