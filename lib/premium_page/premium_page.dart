import 'package:carousel_slider/carousel_slider.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../utils/app_assets.dart';
import '../utils/global_variable.dart';

class PremiumPage extends StatefulWidget {
  const PremiumPage({super.key});

  @override
  State<PremiumPage> createState() => _PremiumPageState();
}

class _PremiumPageState extends State<PremiumPage> {
  String? selectedPlan = "Yearly";
  final ValueNotifier<int> _currentIndex = ValueNotifier(0);
  List<String> images = [
    AppAssets.premiumPlan,
    AppAssets.premiumPlan,
    AppAssets.premiumPlan,
    AppAssets.premiumPlan,
    AppAssets.premiumPlan
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CarouselSlider(
                options: CarouselOptions(
                  height: MediaQuery.sizeOf(context).height * 0.33,
                  onPageChanged: (index, reason) {
                    _currentIndex.value = index;
                  },
                  viewportFraction: 1,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 2),
                ),
                items: images.map((i) {
                  return Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                    ),
                    alignment: Alignment.center,
                    child: SvgPicture.asset(AppAssets.premiumPlan),
                  );
                }).toList(),
              ),
              ValueListenableBuilder(
                  valueListenable: _currentIndex,
                  builder: (context, index, _) {
                    return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(images.length, (i) {
                          return Container(
                            height: 20,
                            width: 20,
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: i == index ? AppColor.primaryColor : null,
                              border: i == index
                                  ? Border.all(
                                      color: AppColor.primaryColor,
                                    )
                                  : Border.all(
                                      color: Colors.black,
                                    ),
                              shape: BoxShape.circle,
                            ),
                          );
                        }));
                  }),
              const SizedBox(
                height: 10,
              ),
              Column(
                children: [
                  ...List.generate(GlobalVariable.premiumPlan.length, (index) {
                    final item = GlobalVariable.premiumPlan[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Stack(
                        children: [
                          ListTile(
                            contentPadding:
                                const EdgeInsets.all(0).copyWith(right: 5),
                            onTap: () {
                              setState(() {
                                selectedPlan = item["title"]!;
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                              side: selectedPlan == item["title"]!
                                  ? const BorderSide(
                                      color: AppColor.primaryColor, width: 2.0)
                                  : BorderSide.none,
                            ),
                            tileColor: Colors.grey[200],
                            title: Text(
                              item["title"]!,
                              style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600),
                            ),
                            subtitle: Text(
                              item["description"]!,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black),
                            ),
                            trailing: Text(
                              item["amount"]!,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black),
                            ),
                            leading: Radio<String>(
                              activeColor: AppColor.primaryColor,
                              value: item["title"]!,
                              groupValue: selectedPlan,
                              onChanged: (value) {
                                setState(() {
                                  selectedPlan = value;
                                });
                              },
                            ),
                          ),
                          index == 1
                              ? Align(
                                  alignment: Alignment.topRight,
                                  child: Container(
                                    height: MediaQuery.sizeOf(context).height *
                                        0.022,
                                    width:
                                        MediaQuery.sizeOf(context).width * 0.22,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomLeft: Radius.circular(10)),
                                      color: AppColor.primaryColor,
                                    ),
                                    child: const Text(
                                      "Most Popular",
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                    );
                  }),
                ],
              ),
              SizedBox(
                height: MediaQuery.sizeOf(context).height * 0.015,
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  fixedSize: Size(MediaQuery.sizeOf(context).width, 60),
                  backgroundColor: AppColor.primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Subscribe Now',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.01),
              const Text(
                "No Commitment. Anytime Cancel",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
              TextButton(
                onPressed: () {},
                child: const Text(
                  "Restore Purchase",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: AppColor.primaryColor,
                  ),
                ),
              ),
              SizedBox(height: MediaQuery.sizeOf(context).height * 0.02),
              const Text(
                "*Subscription will automatically renews, unless you unsubscribe at least 24 hours before its end.*",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
