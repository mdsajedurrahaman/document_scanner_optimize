import 'dart:developer';
import 'dart:io';
import 'package:doc_scanner/home_page/provider/home_page_provider.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../utils/utils.dart';
import 'directory_view.dart';
import 'fixed_size_delegate_grid.dart';





class CustomSearchDelegate extends SearchDelegate<String> {
  final Size size;
  CustomSearchDelegate({required this.size});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => Navigator.of(context).pop(),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    log("buildResult called");

    final homeProvider = Provider.of<HomePageProvider>(context);
    final suggestionList = homeProvider.searchPaths(query);

    return GridView.builder(
      itemCount: suggestionList.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        crossAxisCount: 3,
        height: 100,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        String filePath = suggestionList[index];
        if (Directory(filePath).existsSync()) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectoryDetailsPage(
                    directoryPath: filePath,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.folder,size: 50,color: AppColor.primaryColor,),
                  Text(filePath.split('/').last),
                ],
              ),
            ),
          );
        }
        else if (filePath.toLowerCase().endsWith('.jpg') ||
            filePath.toLowerCase().endsWith('.jpeg') ||
            filePath.toLowerCase().endsWith('.png')) {
          return GestureDetector(
            onTap: () async {
              await showGeneralDialog(
                context: context,
                barrierColor: Colors.black12.withOpacity(0.6),
                barrierDismissible: false,
                barrierLabel: 'Dialog',
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, __, ___) {
                  return Expanded(child: Image.file(File(filePath)));
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.file(
                    File(
                      filePath,
                    ),
                    width: 100,
                    height: 60,
                  ),
                  Text(
                    filePath.split('/').last,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          );
        } else if (filePath.toLowerCase().endsWith('.txt')) {
          return FutureBuilder(
              future: homeProvider.readTxtFile(filePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return GestureDetector(
                      onTap: ()async{
                        showQrAndBarCodeViewDialogue ( context: context, text: snapshot.data.toString() );
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          snapshot.data.toString(),
                        ),
                      ),
                    );
                  }
                }
                return Text(File(filePath).readAsString().toString());
              });
        } else if (filePath.toLowerCase().endsWith('.pdf')) {
          return GestureDetector(
            onTap: () async {
              await OpenFilex.open(filePath);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/pdf.svg",
                    width: 100,
                    height: 60,
                  ),
                  Text(
                    filePath.split('/').last,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          );
        } else {
          return const Text('Something went wrong');
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    final homeProvider = Provider.of<HomePageProvider>(context);
    final suggestionList = homeProvider.searchPaths(query);
    return homeProvider.allFileLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        :

      GridView.builder(
      itemCount: suggestionList.length,
      gridDelegate:
           SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
        crossAxisCount: size.width>=600?4: 3,
             height:size.width>=600? 110:100,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (context, index) {
        String filePath = suggestionList[index];
        if (Directory(filePath).existsSync()) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DirectoryDetailsPage(
                    directoryPath: filePath,
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(Icons.folder,size: 50,color: AppColor.primaryColor,),
                  Text(filePath.split('/').last,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,

                  ),
                ],
              ),
            ),
          );
        } else if (filePath.toLowerCase().endsWith('.jpg') ||
            filePath.toLowerCase().endsWith('.jpeg') ||
            filePath.toLowerCase().endsWith('.png')) {
          return GestureDetector(
            onTap: () async {
              await showGeneralDialog(
                context: context,
                barrierColor: Colors.black12.withOpacity(0.6),
                barrierDismissible: false,
                barrierLabel: 'Dialog',
                transitionDuration: const Duration(milliseconds: 400),
                pageBuilder: (context, __, ___) {
                  return Image.file(File(filePath));
                },
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Image.file(
                    File(
                      filePath,
                    ),
                    width: 100,
                    height: 60,
                  ),
                  Text(
                    filePath.split('/').last,
                    style: TextStyle(
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          );
        } else if (filePath.toLowerCase().endsWith('.txt')) {
          return FutureBuilder(
              future: homeProvider.readTxtFile(filePath),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else if (snapshot.connectionState == ConnectionState.done) {
                  if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (snapshot.hasData) {
                    return GestureDetector(
                      onTap: (){
                        showQrAndBarCodeViewDialogue(context: context, text: snapshot.data.toString());
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          snapshot.data.toString(),
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    );
                  }
                }
                return Text(File(filePath).readAsString().toString());
              });
        } else if (filePath.toLowerCase().endsWith('.pdf')) {
          return GestureDetector(
            onTap: () async {
              await OpenFilex.open(filePath);
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    "assets/icons/pdf.svg",
                    width: 100,
                    height: 60,
                  ),
                  Text(
                    filePath.split('/').last,
                    overflow: TextOverflow.ellipsis,
                  )
                ],
              ),
            ),
          );
        } else {
          return const Text('Something went wrong');
        }
      },
    );
  }
}
