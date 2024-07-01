import 'package:doc_scanner/image_edit/widget/color_button.dart';
import 'package:doc_scanner/utils/app_color.dart';
import 'package:flutter/material.dart';
import 'package:hand_signature/signature.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({super.key});

  @override
  State<DrawingScreen> createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  Color currentColor = Colors.black;
  Color currentBackgroundColor = Colors.white;
  double sliderValue = 0.03;
  final control = HandSignatureControl();
  List<CubicPath> undoList = [];
  bool skipNextEvent = false;



  @override
  void initState() {
    control.addListener(() {
      if (control.hasActivePath) return;

      if (skipNextEvent) {
        skipNextEvent = false;
        return;
      }
      undoList = [];
      setState(() {});
    });
    super.initState();
  }
  List<Color> colors = [
    Colors.black,
    Colors.white,
    Colors.blue,
    Colors.green,
    Colors.pink,
    Colors.purple,
    Colors.brown,
    Colors.indigo,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: const Icon(Icons.clear),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: Icon(
              Icons.undo,
              color: control.paths.isNotEmpty
                  ? Colors.black
                  : Colors.black.withAlpha(80),
            ),
            onPressed: () {
              if (control.paths.isEmpty) return;
              skipNextEvent = true;
              undoList.add(control.paths.last);
              control.stepBack();
              setState(() {});
            },
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: Icon(
              Icons.redo,
              color: undoList.isNotEmpty
                  ? Colors.black
                  : Colors.black.withAlpha(80),
            ),
            onPressed: () {
              if (undoList.isEmpty) return;
              control.paths.add(undoList.removeLast());
              setState(() {});
            },
          ),
          IconButton(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            icon: const Icon(Icons.check,color: AppColor.primaryColor,),
            onPressed: () async {
              var res = control.toSvg(
                type: SignatureDrawType.line,
                color: currentColor,
                strokeWidth: sliderValue * 100,
              );
              Navigator.pop(context, res);
            },
          ),
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: currentBackgroundColor,
        ),
        child: HandSignature(
          control: control,
          color: currentColor,
          width: sliderValue * 100,
          maxWidth: 20,
          type: SignatureDrawType.line,
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        height: 160,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          children: [
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.withOpacity(0.5),
                  child: CircleAvatar(
                    radius: sliderValue * 100,
                    backgroundColor: currentColor,
                  ),
                ),
                Slider(
                  activeColor: AppColor.primaryColor,
                  min: 0.0,
                  max: 0.2,
                  value: sliderValue,
                  onChanged: (value) {
                    setState(() {
                      sliderValue = value;
                    });
                  },
                ),
              ],
            ),
            Expanded(
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  for (var color in colors)
                    ColorButton(
                      color: color,
                      onTap: (color) {
                        currentColor = color;
                        setState(() {});
                      },
                      isSelected: color == currentColor,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
