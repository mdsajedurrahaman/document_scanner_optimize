import 'dart:typed_data';

import 'package:flutter/cupertino.dart';

class ImageEditProvider extends ChangeNotifier{

  List<Uint8List> _history = [];
  int _currentIndex = -1;
  Uint8List get currentState => _history[_currentIndex];

  void addState(Uint8List imageData) {
    if (_currentIndex < _history.length - 1) {
      _history = _history.sublist(0, _currentIndex + 1);
    }
    _history.add(imageData);
    _currentIndex++;
    notifyListeners();
  }

  void undo() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
    }
  }

  void clearState() {
    _history.clear();
    _currentIndex = -1;
  }

  bool get canUndo => _currentIndex > 0;


}