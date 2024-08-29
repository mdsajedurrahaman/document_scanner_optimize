import 'dart:io';
import 'package:doc_scanner/home_page/provider/home_page_provider.dart';
import 'package:doc_scanner/localaization/language_constant.dart';
import 'package:doc_scanner/utils/app_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:open_filex/open_filex.dart';
import 'package:provider/provider.dart';
import '../utils/app_color.dart';
import '../utils/utils.dart';
import 'directory_view.dart';
import 'fixed_size_delegate_grid.dart';


class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {


  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
   WidgetsBinding.instance.addPostFrameCallback((timeStamp) {

     context.read<HomePageProvider>().getAllFileList();
   });
    super.initState();
  }

  @override
  void setState(VoidCallback fn) {
   if(mounted){
     super.setState(fn);
   }
  }

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomePageProvider>();
    final screenSize = MediaQuery.sizeOf(context);
    return Scaffold(
      body: homeProvider.allFileLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
            child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        homeProvider.filteredItems.clear();
                        Navigator.pop(context);

                      },
                      icon: const Icon(Icons.arrow_back),
                    ),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: translation(context).searchHere,
                          filled: true,
                          fillColor: const Color(0xFFF5F5F5),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 15),
                          suffixIcon: IconButton(
                              onPressed: () {
                                homeProvider.clearFilteredItems();
                                _searchController.clear();
                              },
                              icon: const Icon(Icons.close)),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(100)),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          homeProvider.onSearchChanged(value);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                  child: homeProvider.filteredItems.isEmpty
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        AppAssets.search_not_found,
                      ),
                      const SizedBox(height: 10,),
                       Text(translation(context).noResultFound,

                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold
                      ),
                      )
                    ],
                  ):
                  GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    itemCount: homeProvider.filteredItems.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCountAndFixedHeight(
                    crossAxisCount: 3,
                    height: screenSize.width>=600 ? 130: 100,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                ),
                itemBuilder: (context, index) {
                  String filePath = homeProvider.filteredItems[index];
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
                            const Icon(
                              Icons.folder,
                              size: 50,
                              color: AppColor.primaryColor,
                            ),
                            Text(filePath.split('/').last),
                          ],
                        ),
                      ),
                    );
                  } else if (filePath.toLowerCase().endsWith('.jpg') ||
                      filePath.toLowerCase().endsWith('.jpeg') ||
                      filePath.toLowerCase().endsWith('.png')) {
                    return GestureDetector(
                      onTap: () async {
                        await flutterGenralDialogue(
                          context: context,
                          imageFile: File(filePath),
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
                    return GestureDetector(
                      onTap: () async {
                            showQrAndBarCodeViewDialogue(
                                context: context,
                                text: await homeProvider
                                    .readTxtFile(filePath));
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
                              AppAssets.txt,
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
                             AppAssets.pdf,
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
              ))
            ],
                        ),
          ),
    );
  }
}
