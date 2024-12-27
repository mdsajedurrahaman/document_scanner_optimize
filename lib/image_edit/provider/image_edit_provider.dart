import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class ImageEditProvider extends ChangeNotifier {
  List<Uint8List> _history = [];
  int currentIndex = -1;
  Uint8List get currentState => _history[currentIndex];

  void addState(Uint8List imageData) {
    if (currentIndex < _history.length - 1) {
      _history = _history.sublist(0, currentIndex + 1);
    }
    _history.add(imageData);
    currentIndex++;
    notifyListeners();
  }

  void undo() {
    if (currentIndex > 0) {
      currentIndex--;
      notifyListeners();
    }
  }

  void clearState() {
    _history.clear();
    currentIndex = -1;
  }

  bool get canUndo => currentIndex > 0;
}
